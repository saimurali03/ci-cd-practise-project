pipeline {
  agent any
  environment {
    AWS_REGION = 'ap-south-1'            // update for your region
    ACCOUNT_ID = '331174145079'         // update your AWS account id
    ECR_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/ci-cd-example"
    IMAGE_TAG = "${env.GIT_COMMIT ?: env.BUILD_ID}"
  }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Build & Test') {
      steps {
        dir('app') {
          sh 'npm ci'
          sh 'npm test || true'
        }
      }
    }
    stage('Build Docker Image') {
      steps {
        dir('app') {
          sh "docker build -t ${ECR_REPO}:${IMAGE_TAG} ."
        }
      }
    }
    stage('Login & Push to ECR') {
      steps {
        // assumes AWS CLI available and credentials configured on Jenkins
        sh '''
          aws ecr get-login-password --region ${AWS_REGION} | \
            docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
        '''
        sh "docker push ${ECR_REPO}:${IMAGE_TAG}"
      }
    }
    stage('Terraform Deploy') {
      steps {
        dir('infra') {
          withCredentials([string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'), string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
            sh 'terraform init -input=false'
            sh "terraform plan -var='image_tag=${IMAGE_TAG}' -out=tfplan -input=false"
            sh 'terraform apply -auto-approve tfplan'
          }
        }
      }
    }
  }
}
