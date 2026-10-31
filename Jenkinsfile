pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
        timestamps()
    }

    // Checks GitHub for changes about every five minutes.
    // Click "Build Now" to trigger the training demo immediately.
    triggers {
        pollSCM('H/5 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test') {
            steps {
                sh 'python3 -m unittest discover -s tests -v'
            }
        }

        stage('Build') {
            steps {
                sh '''
                    mkdir -p dist
                    rm -f dist/webapp.zip
                    cd site
                    zip -q -r ../dist/webapp.zip .
                '''
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'dist/webapp.zip', fingerprint: true
            }
        }

        stage('Deploy') {
            steps {
                // Ubuntu Nginx default web root, not the Amazon Linux path.
                sh '''
                    unzip -oq dist/webapp.zip \
                      -d /var/www/html/devops-demo
                '''
            }
        }

        stage('Verify') {
            steps {
                sh '''
                    curl -fsS http://127.0.0.1/devops-demo/ \
                      | grep -Fq '<h1>DevOps Fast Track</h1>'
                '''
            }
        }
    }
}
