#!/usr/bin/env sh
set -x

GS_VERSION=$1
#wget https://github.com/jeremylong/DependencyCheck/releases/download/v6.0.5/dependency-check-6.0.5-release.zip
unzip dependency-check-6.0.5-release.zip

#wget https://gigaspaces-releases-eu.s3.amazonaws.com/xap/16.0.0/gigaspaces-xap-enterprise-${GS_VERSION}.zip
unzip gigaspaces-xap-enterprise-16.0.0-m1-ci-7.zip

cd dependency-check/bin
./dependency-check.sh --project "xap-${GS_VERSION}" --scan "../../gigaspaces-xap-enterprise-16.0.0-m1-ci-7" --out .
