#!/usr/bin/env bash
set -x


function createDependencyCheckFolder {
  echo "delete dependency check folder (if exists)"
  if [ -d "dependency-check" ]
  then
    rm -rf "dependency-check"
  fi
  echo "create dependency check folder"
  wget https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.0/dependency-check-8.4.0-release.zip
  unzip dependency-check-8.4.0-release.zip
}

function uploadToS3 {
    echo "uploading html $1 to "
    local zipPath="$1"
    local target="$2"
    cd ${WORKSPACE}
    cmd="mvn -B -P dependency-check -Dmaven.repo.local=${WORKSPACE}/.m2_dependency_check/repository com.gigaspaces:xap-build-plugin:deploy-native -Dput.source=${zipPath} -Dput.target=${target}"
    echo "Executing cmd: $cmd"
    eval "$cmd"
    local r="$?"
    if [ "$r" -eq 1 ]
    then
        echo "[ERROR] failed to upload $1 , exit code:$r"
        exit 1
    fi
}


function cleanUp {
  echo "clean up"
  rm -r -f ${WORKSPACE}/build/${GS_VERSION}
  rm -r -f ${WORKSPACE}/build/gigaspaces-*
}
function getProductBucket {
	if [ ${GS_PRODUCT} == 'xap' ]
	then
	    echo 'xap'
	else
	    echo 'smart-cache'
	fi
}


function downloadingProductZip {
  echo "downloading zip"
  rm -r -f gigaspaces-*
  local gs_version=${GS_VERSION}
  local version=${gs_version%%-*}

  wget https://gs-releases-us-east-1.s3.amazonaws.com/${GS_PRODUCT}/${version}/gigaspaces-${GS_PRODUCT}-enterprise-${GS_VERSION}.zip

  echo "unzipping product"
  unzip gigaspaces-*.zip
  rm -r gigaspaces-*.zip
}



GS_VERSION=$1
GS_PRODUCT=$2
TIMESTAMPP=$(date +%Y%m%d-%H%M)
export TIMESTAMP=${TIMESTAMPP}
createDependencyCheckFolder
downloadingProductZip

FOLDER_NAME=$(echo gigaspace*/)
mkdir -p ${GS_VERSION}

./dependency-check/bin/dependency-check.sh --project "${FOLDER_NAME}" --scan "${WORKSPACE}/build/${FOLDER_NAME}" --out ${WORKSPACE}/build/${GS_VERSION}/

DEPENDENCY_BUCKET="dependency-check-results"
uploadToS3 ${WORKSPACE}/build/${GS_VERSION}/ ${DEPENDENCY_BUCKET}/${GS_PRODUCT}


cleanUp