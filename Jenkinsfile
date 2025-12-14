pipeline {
    agent any

    tools {
        jdk 'JAVA_HOME'
        maven 'M2_HOME'
    }

    environment {
        DOCKER_IMAGE = 'kenzabaccar/student-management'
        KUBECONFIG = '/home/vagrant/.kube/config'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/kenza-22/Projet_Devops.git'
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .'
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_TOKEN = credentials('sonarqube-token')
            }
            steps {
                withSonarQubeEnv('SonarQubeServer') {
                    sh 'mvn sonar:sonar -Dsonar.login=$SONAR_TOKEN'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo '☸️ Déploiement sur Kubernetes...'
                sh """
                    echo "🔄 Déploiement MySQL..."
                    kubectl apply -f mysql-deployment.yaml -n devops

                    echo "🚀 Déploiement Spring Boot..."
                    kubectl apply -f spring-deployment.yaml -n devops

                    echo "✅ Vérification des pods..."
                    kubectl get pods -n devops

                    echo "📊 Services disponibles :"
                    kubectl get services -n devops
                """
            }
        }
    }

    post {
        success {
            emailext(
                subject: "✅ Build Success: ${currentBuild.fullDisplayName}",
                body: """
Bonjour,

Le pipeline Jenkins pour le projet student-management s'est exécuté avec SUCCÈS 🎉

📋 Détails :
- Projet : ${env.JOB_NAME}
- Build # : ${env.BUILD_NUMBER}
- Durée : ${currentBuild.durationString}
- Date : ${new Date()}

✅ Étapes :
✔ Git Checkout
✔ Build Maven
✔ Docker Build & Push
✔ Analyse SonarQube
✔ Déploiement Kubernetes

🔗 ${env.BUILD_URL}
🐳 Image : ${DOCKER_IMAGE}:${BUILD_NUMBER}

Cordialement,
Jenkins CI/CD
""",
                to: 'kenzabaccar6@gmail.com'
            )
        }

        failure {
            emailext(
                subject: "❌ Build Failed: ${currentBuild.fullDisplayName}",
                body: """
Bonjour,

❌ Le pipeline Jenkins a ÉCHOUÉ.

📋 Détails :
- Projet : ${env.JOB_NAME}
- Build # : ${env.BUILD_NUMBER}
- Durée : ${currentBuild.durationString}

🔍 Voir les logs :
${env.BUILD_URL}console

Merci de corriger les erreurs et relancer le build.

Jenkins CI/CD
""",
                to: 'kenzabaccar6@gmail.com'
            )
        }
    }
}
