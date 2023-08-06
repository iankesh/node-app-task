pipeline {
    agent any

    stages {
        stage('Git Checkout') {
            steps {
                retry(3){
                    git branch: "main", url: "https://github.com/iankesh/node-app-task.git", credentialsId: 'github-creds-555'
                }
            }
        }
        
        stage('Build Docker image and push to ECR') {
            steps {
                sh 'docker build -t ecr-555 .'
                sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 281751793541.dkr.ecr.us-east-1.amazonaws.com'
                sh 'docker tag ecr-555:latest 281751793541.dkr.ecr.us-east-1.amazonaws.com/ecr-555:latest'
                sh 'docker push 281751793541.dkr.ecr.us-east-1.amazonaws.com/ecr-555:latest'
            }
        }

        stage('Deploy to App Host') {
            steps {
                sh '''ssh -i ~/.ssh/app root@10.10.4.240 <<EOF
                aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 281751793541.dkr.ecr.us-east-1.amazonaws.com
                docker pull 281751793541.dkr.ecr.us-east-1.amazonaws.com/ecr-555:latest
                docker stop app-host-555 || true
                docker rm app-host-555 || true
                docker run -d -p 8080:8081 --name app-host-555 281751793541.dkr.ecr.us-east-1.amazonaws.com/ecr-555:latest
EOF
            '''
            }
        }
    }
}