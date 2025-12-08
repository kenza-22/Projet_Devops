pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                 checkout scm
            }
        }
        stage('Build') {
            steps {
                sh 'mvn package'
            }
        }
        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }
}
