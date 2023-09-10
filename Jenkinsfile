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
        GS_VERSION = "${GS_VERSION}"
        GS_PRODUCT = "${GS_PRODUCT}"
    }
    stages {
        stage('run') {
            steps {
                dir('build') {
                    echo "GS_VERSION: ${GS_VERSION}"
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
