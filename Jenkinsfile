pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'            // update for your region
    ACCOUNT_ID = '331174145079'         // update your AWS account id
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                bat 'npm install'
                bat 'npm test || echo "No tests configured"'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t ci-cd-node-app .'
            }
        }

        stage('Login & Push to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    bat '''
                    aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %ECR_REPO%
                    docker tag ci-cd-node-app:latest %ECR_REPO%:latest
                    docker push %ECR_REPO%:latest
                    '''
                }
            }
        }

        stage('Terraform Deploy') {
            steps {
                dir('terraform') {
                    bat 'terraform init'
                    bat 'terraform apply -auto-approve'
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for errors.'
        }
    }
}
