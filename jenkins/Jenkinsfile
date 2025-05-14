pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                pwd
                ls
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}