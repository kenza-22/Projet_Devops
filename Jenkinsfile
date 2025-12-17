pipeline {
    agent any

    tools {
        jdk 'JAVA_HOME'
        maven 'M2_HOME'
    }

    environment {
        DOCKER_IMAGE = 'kenzabaccar/student-management'
        KUBECONFIG = '/home/vagrant/.kube/config'
        GRAFANA_URL = 'http://192.168.50.4:3000'

    }

    stages {

        stage('✅ Checkout & Build') {
            parallel {
                stage('Git Checkout') {
                    steps {
                        echo "📥 Clonage du dépôt..."
                        git branch: 'master',
                            url: 'https://github.com/kenza-22/Projet_Devops.git'
                    }
                }

                stage('Maven Build') {
                    steps {
                        echo "⚙️ Compilation Maven..."
                        sh 'mvn clean package -DskipTests'
                    }
                }
            }
        }

        stage('🐳 Docker Build') {
            steps {
                echo "🔨 Construction de l'image Docker..."
                sh 'docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .'
            }
        }

        stage('🐳 Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    echo "📤 Push de l'image Docker vers Docker Hub..."
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('🔍 SonarQube Analysis') {
            environment {
                SONAR_TOKEN = credentials('sonarqube-token')
            }
            steps {
                echo "📊 Analyse SonarQube..."
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn sonar:sonar -Dsonar.login=${SONAR_TOKEN}'
                }
            }
        }

        stage('☸️ Deploy Kubernetes') {
            steps {
                echo "🚀 Déploiement sur Kubernetes..."
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
 stage('Grafana Dashboards Update') {
            environment { GRAFANA_API_KEY = credentials('grafana-api-key') }
            steps {
                sh '''
                    if [ -d "grafana/dashboards" ]; then
                        for file in grafana/dashboards/*.json; do
                            payload="{\\"dashboard\\": $(cat $file), \\"overwrite\\": true}"
                            curl -X POST "${GRAFANA_URL}/api/dashboards/db" \
                                 -H "Authorization: Bearer ${GRAFANA_API_KEY}" \
                                 -H "Content-Type: application/json" \
                                 -d "$payload"
                        done
                    fi
                '''
            }
        }

        stage('📄 Reports') {
            steps {
                echo "📊 Publication des rapports..."
                publishHTML(target: [
                    reportName: 'Rapport Maven Test',
                    reportDir: 'target/site',
                    reportFiles: 'index.html',
                    keepAll: true,
                    alwaysLinkToLastBuild: true,
                    allowMissing: true
                ])
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
