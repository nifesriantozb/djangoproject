pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "megumismine/kelompok5-django:${BUILD_NUMBER}"
        PROJECT_DIR = 'Challenge/kelompok5'
        MANIFEST_FILE = '.deployment/kelompok5-django.yml'
        
    }
    
    stages {
        
        stage ('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Fansqiee/try-openshift.git'
            }
        }
        
        stage ('Build Docker Image') {
            steps {
                dir ("${PROJECT_DIR}") {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }
        
        stage ('Push Docker Image Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDS', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]){
                    sh """
                    echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                    docker push ${DOCKER_IMAGE}
                    docker logout
                    """
                }
            }
        }
        
        stage ('Update Manifest YAML') {
            steps {
                dir ("${PROJECT_DIR}") {
                    script {
                        def manifestContent = readFile(env.MANIFEST_FILE)

                        // Replace the image tag in the manifest
                        manifestContent = manifestContent.replaceAll(/image: .*/, "image: ${DOCKER_IMAGE}")

                        // Write the updated content back to the file
                        writeFile(file: env.MANIFEST_FILE, text: manifestContent)
                    }
                }
            }
        }

        stage ('Apply ke OpenShift'){
            steps {
                dir ("${PROJECT_DIR}") {
                    script {
                    withCredentials([string(credentialsId: 'OC_LOGIN_TOKEN', variable: 'OC_TOKEN')]){
                        sh """
                        oc login --token=$OC_TOKEN --server=https://api.rm1.0a51.p1.openshiftapps.com:6443
                        oc apply -f ${env.MANIFEST_FILE}
                        oc get route django
                        """
                        }
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo 'Application deployed successfully! ✅'
        }
        failure {
            echo 'Deployment failed. Please check the logs. ❌'
        }
    }
}