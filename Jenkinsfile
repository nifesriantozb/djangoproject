pipeline {
    agent any

    environment {
        IMAGE_NAME = "nifesriantozb/django-testing"
        IMAGE_TAG = "v${BUILD_NUMBER}" // Tanpa 'env.' karena sudah dalam block environment
        DOCKERHUB_CREDENTIALS_ID = "b897d5f3-dcbd-424e-a4b7-bd4679e2e7ba"
        TOKEN_CREDENTIALS_ID = "de4f6c2b-2ab7-4965-8335-90d710918931"
        SERVER_CREDENTIALS_ID = "https://api.rm1.0a51.p1.openshiftapps.com:6443"
        
        OPENSHIFT_NAMESPACE = "deployment-cicd-jenkins-django" // ganti dengan project-mu
        MANIFEST_PATH = "django-with-config-and-secret-and-hpa.yml"  
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Login to Docker Hub and Push Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKERHUB_CREDENTIALS_ID,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy to OpenShift') {
            steps {
                withCredentials([string(credentialsId: TOKEN_CREDENTIALS_ID, variable: 'OC_TOKEN')]) {
                    sh '''
                    oc login --token=$OC_TOKEN --server=https://api.rm1.0a51.p1.openshiftapps.com:6443
                    oc apply -f django-with-config-and-secret-and-hpa.yml
                    oc get route django
                    '''
                }
            }
            
            }
        }
    }
    
    post {
        success {
            echo "✅ Image successfully pushed to Docker Hub as ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Build or push failed!"
        }
    }
}