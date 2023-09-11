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
        S3_REGION = 'us-east-1'
        S3_CREDS = 'xap-ops-automation'
        GS_VERSION = "${GS_VERSION}"
        GS_PRODUCT = "${GS_PRODUCT}"
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
