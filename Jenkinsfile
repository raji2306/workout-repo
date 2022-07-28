pipeline {
    agent any 
    tools {
        terraform 'terraform'
    }
    stages{
        stage ('Github Checkout') {
            steps {
                git credentialsId: 'raji2306', url: 'https://github.com/raji2306/workout-repo'
            }
        }
        stage ('Terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage ('Terraform apply') {
            steps {
                sh 'terraform apply --auto-approve'
            }
        }
    }
}   
