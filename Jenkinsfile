pipeline {
  agent any
  
  environment {
    DATE = new Date().format('yyyy.MM.dd')
    TAG = "${DATE}.${BUILD_NUMBER}"
    registry = credentials('DOCKER_ID')
    registryCredential = 'dockerhub'
  }
  
  stages {
    stage('Build Artifact - Maven') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archive 'target/*.jar'
      }
    }
    stage('Build And Push Image') {
      steps{
        script {
          docker.withRegistry( '', registryCredential ) {
            def dockerImage = docker.build("${registry}/devsecops:$TAG")
            dockerImage.push()
          }  
        }
      }
    }
    stage('Clean Image') {
      steps {
        bat "docker rmi $registry/devsecops:$TAG"
      }
    }
    stage('Deploy Image') {
      steps {
        script {
          dir('sitecore') {
            kubeconfig(credentialsId: 'kubeid') {
              bat "kustomize edit set image devsecops=*:$TAG"
              bat "kustomize build . | kubectl apply -f -"
            }
          }
        }
      }
    }
  }
}
