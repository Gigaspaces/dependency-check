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
        MVN_JENKINSID = 'xapbuilder-settings'
        MVN_JAVA_OPTS = '-Xmx8192m -Xms4096m'
        MVN_JAVA = 'Java8'
        S3_REGION = 'us-east-1'
        S3_CREDS = 'xap-ops-automation'
        GS_VERSION = "${GS_VERSION}"
        GS_PRODUCT = "${GS_PRODUCT}"
    }
    stages {
        stage('run') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'xap-ops-automation',
                    accessKeyVariable: 'user',
                    secretKeyVariable: 'key'
                ]]) {
                    dir('build') {
                        echo "GS_VERSION: ${GS_VERSION}"
                        sh "./run.sh ${GS_VERSION} ${GS_PRODUCT}"
                    }
                }
            }
        }
    }
    post {
        always {
            echo 'Finished'
        }
    }
}
