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
        GS_BASE_VERSION = getMajorVersion(GS_VERSION)
        GS_RELEASE_DIR = "gigaspaces-${GS_PRODUCT}-enterprise-${GS_VERSION}"
        GS_RELEASE_FILE = "${GS_RELEASE_DIR}.zip"
        S3_REGION = 'us-east-1'
        S3_CREDS = 'xap-ops-automation'
        S3_RELEASE_BUCKET = 'gs-releases-us-east-1'
        S3_RELEASE_PREFIX = "${GS_PRODUCT}/${GS_BASE_VERSION}"
        S3_RELEASE_FILE = "${S3_RELEASE_PREFIX}/${GS_RELEASE_FILE}"
        S3_CHECK_BUCKET = "gspaces-dependency-check"
        S3_CHECK_PREFIX = "${S3_RELEASE_PREFIX}"
        CHECK_FILENAME = "dependency-check-report-${BUILD_NUMBER}.html"
        S3_CHECK_URL = "https://${S3_CHECK_BUCKET}.s3.amazonaws.com/${S3_CHECK_PREFIX}/${REPORT_NAME}"
        BUILD_LABEL = "${GS_VERSION}-${BUILD_NUMBER}"
        REPORT_NAME = "${BUILD_LABEL}.html"
    }
    stages {
        stage ('prepare') {
            steps {
                script {
                    sh 'printenv'
                }
                withAWS(region: S3_REGION, credentials: S3_CREDS) {
                    script {
                        if (s3DoesObjectExist(bucket: S3_RELEASE_BUCKET, path: S3_RELEASE_FILE )) {
                            s3Download(bucket: S3_RELEASE_BUCKET, path: S3_RELEASE_FILE, file: GS_RELEASE_FILE, force: true)
                            unzip(zipFile: GS_RELEASE_FILE)
                        } else {
                            echo "Could not find file ${S3_RELEASE_FILE} in bucket ${S3_RELEASE_BUCKET}"
                        }
                    }
                }
            }
        }
        stage ('label') {
            steps {
                script {
                    currentBuild.displayName = "${BUILD_LABEL}"
                }
            }
        }
        stage ('run') {
            steps {
                dependencyCheck(odcInstallation: 'dependency-check-v8.4.0', additionalArguments: "--project ${GS_RELEASE_DIR} --scan './**/*.jar' --out './' --format ALL --prettyPrint")
                dependencyCheckPublisher(pattern: 'dependency-check-report.xml')
                sh "cp dependency-check-report.html ${REPORT_NAME}"
            }
        }
        stage ('upload') {
            steps {
                withAWS(region: S3_REGION, credentials: S3_CREDS) {
                    echo "Uploading check file."
                    echo "Source: ${WORKSPACE}/${REPORT_NAME}"
                    echo "Bucket: ${S3_CHECK_BUCKET}"
                    echo "Path:   ${S3_CHECK_PREFIX}"
                    s3Upload(file:"${WORKSPACE}/${REPORT_NAME}", bucket:"${S3_CHECK_BUCKET}", path:"${S3_CHECK_PREFIX}/", acl: 'PublicRead')
                }
            }
        }
    }
    post {
        success {
            echo "The dependency result can be viewed here: ${S3_CHECK_URL}"
        }
        always {
            echo 'Finished'
        }
    }
}
