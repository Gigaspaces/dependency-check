#!/usr/bin/env sh
set -x


function upload_artifact {
# $1 = zipPath
# $2 = target
    echo "uploading zip $1 to "
    local zipPath="$1"
    local target="$2"


    cmd="mvn -B -Dmaven.repo.local=/var/m2_dependency_check com.gigaspaces:xap-build-plugin:deploy-native -Dput.source=${zipPath} -Dput.target=${target}"

    echo "****************************************************************************************************"
    echo "uploading $1"
    echo "Executing cmd: $cmd"
    echo "****************************************************************************************************"
    eval "$cmd"
    local r="$?"
    if [ "$r" -eq 1 ]
    then
        echo "[ERROR] failed to upload $1 , exit code:$r"
        exit 1
    fi
}

GS_VERSION=$1
echo "test"
echo ${GS_VERSION}
echo $M2

ls -l /var/m2_check

##wget https://github.com/jeremylong/DependencyCheck/releases/download/v6.0.5/dependency-check-6.0.5-release.zip
#unzip dependency-check-6.0.5-release.zip
#wget https://gigaspaces-releases-eu.s3.amazonaws.com/xap/16.0.0/gigaspaces-xap-enterprise-${GS_VERSION}.zip
#unzip gigaspaces-xap-enterprise-${GS_VERSION}.zip
#
mkdir -p ${GS_VERSION}
#cd dependency-check/bin

#./dependency-check.sh --project "xap-${GS_VERSION}" --scan "../../gigaspaces-xap-enterprise-${GS_VERSION}" --out ${GS_VERSION}/

DEPENDENCY_BUCKET="dependency-check-results"

upload_artifact ${GS_VERSION}/ ${DEPENDENCY_BUCKET}

rm -r ${GS_VERSION}
