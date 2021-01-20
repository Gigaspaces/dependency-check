#!/usr/bin/env sh
set -x
function uploadToS3 {
    echo "uploading html $1 to "
    local zipPath="$1"
    local target="$2"
    cmd="mvn -B -P dependency-check -Dmaven.repo.local=/home/jenkins/.m2_dependency_check/repository com.gigaspaces:xap-build-plugin:deploy-native -Dput.source=${zipPath} -Dput.target=${target}"
    echo "Executing cmd: $cmd"
    eval "$cmd"
    local r="$?"
    if [ "$r" -eq 1 ]
    then
        echo "[ERROR] failed to upload $1 , exit code:$r"
        exit 1
    fi
}


GS_VERSION=$1
GS_URL=$2

if [ ! -e "dependency-check-6.0.5-release" ]
then
    if [ ! -e "dependency-check-6.0.5-release.zip" ]
    then
      wget https://github.com/jeremylong/DependencyCheck/releases/download/v6.0.5/dependency-check-6.0.5-release.zip
    fi
	unzip dependency-check-6.0.5-release.zip
fi

rm -r gigaspaces-*
wget ${GS_URL}
unzip gigaspaces-*.zip
rm -r gigaspaces-*.zip
FOLDER_NAME=$(echo gigaspace*/)

mkdir -p ${GS_VERSION}

cd dependency-check/bin
./dependency-check.sh --project "xap-${GS_VERSION}" --scan "../../${FOLDER_NAME}" --out ${GS_VERSION}/

cd ${WORKSPACE}
DEPENDENCY_BUCKET="dependency-check-results"
uploadToS3 /var/workspaces/Metric/Spotinst/Dependency-Check/build/dependency-check/bin/${GS_VERSION}/ ${DEPENDENCY_BUCKET}


rm -r ${WORKSPACE}/build/${GS_VERSION}
rm -r ${WORKSPACE}/build/gigaspaces-*