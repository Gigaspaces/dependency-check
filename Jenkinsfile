String getMajorVersion (versionString) {
    return versionString.replaceAll('-(.*)','')
}

pipeline {
    agent {
        label 'gs-builder-large-ng'
    }
    options {
        timestamps()
        durabilityHint('PERFORMANCE_OPTIMIZED')
    }
    environment {
        M2 = "$WORKSPACE/.m2_dependency_check"
        MVN_JENKINSID = "xapbuilder-settings"
        MVN_JAVA_OPTS = "-Xmx8192m -Xms4096m -Djava.io.tmpdir=${WORKSPACE_TMP}"
        MVN_JAVA = 'Java8'
        GS_VERSION = "${GS_VERSION}"
        GS_PRODUCT = "${GS_PRODUCT}"
        GS_BASE_VERSION = getMajorVersion(GS_VERSION)
        GS_RELEASE_DIR = "gigaspaces-${GS_PRODUCT}-enterprise-${GS_VERSION}"
        GS_RELEASE_FILE = "${GS_RELEASE_DIR}.zip"
        S3_REGION = 'us-east-1'
        S3_CREDS = 'xap-ops-automation'
        S3_RELEASE_BUCKET = 'gs-releases-us-east-1'
        S3_RELEASE_PREFIX = "${GS_PRODUCT}/${GS_BASE_VERSION}"
        S3_RELEASE_FILE = "${S3_RELEASE_PREFIX}/${GS_RELEASE_FILE}"
        DEPCHECK_DIR = "dependency-check"
    }
    stages {
        stage ('prepare') {
            steps {
                script {
                    if (fileExists(DEPCHECK_DIR)) {
                        echo "Deleting stale dependency-check directory"
                        sh "rm -rf ${DEPCHECK_DIR}"
                    }
                }
                echo "Downloading latest dependency-check release"
                sh '''
                    VERSION=$(curl -s https://jeremylong.github.io/DependencyCheck/current.txt)
                    curl -Ls "https://github.com/jeremylong/DependencyCheck/releases/download/v$VERSION/dependency-check-$VERSION-release.zip" --output dependency-check.zip
                    unzip dependency-check.zip
                '''
                withAWS(region: S3_REGION, credentials: S3_CREDS) {
                    script {
                        if (s3DoesObjectExist(bucket: S3_RELEASE_BUCKET, path: S3_RELEASE_FILE )) {
                            s3Download(bucket: S3_RELEASE_BUCKET, path: S3_RELEASE_FILE, file: GS_RELEASE_FILE)
                            unzip(zipFile: GS_RELEASE_FILE)
                        } else {
                            echo "Could not find file ${S3_RELEASE_FILE} in bucket ${S3_RELEASE_BUCKET}"
                        }
                    }
                }
            }
        }
        stage ('run') {
            steps {
                dependencyCheck(additionalArguments: "--project "${GS_FOLDER_NAME}" --scan "${WORKSPACE}/build/${GS_FOLDER_NAME}" --out ${WORKSPACE}/build/${GS_VERSION}/")
            }
        }
        /*
        stage('run') {
            steps {
                withMaven(mavenSettingsConfig: MVN_JENKINSID, mavenOpts: MVN_JAVA_OPTS, jdk: MVN_JAVA, traceability: true) {
                    dir('build') {
                        echo "GS_VERSION: ${GS_VERSION}"
                        sh "./run.sh ${GS_VERSION} ${GS_PRODUCT}"
                    }
                }
            }
        }
        */
    }
    post {
        always {
            echo 'Finished'
        }
    }
}
