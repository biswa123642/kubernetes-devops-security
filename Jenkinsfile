pipeline {
  agent any
  tools {
    maven 'maven'
    jdk 'java'
  }
  
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
   // stage('Dependency Scan') {
   //   steps {
   //     sh "mvn dependency-check:check"
   //   }
   //   post {
   //     always {
   //       dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
   //     }
   //   }
   // }
    stage('Docker Trivy Scan') {
      steps {
        script {
          docker.withRegistry( '', registryCredential ) {
            sh "bash trivy-docker-image-scan.sh"
          }
        }
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
        sh "docker rmi $registry/devsecops:$TAG"
      }
    }
    stage('Deploy Image') {
      steps {
        script {
          dir('sitecore') {
            kubeconfig(credentialsId: 'kubeid') {
              sh "kustomize edit set image devsecops=*:$TAG"
              sh "kustomize build . | kubectl apply -f -"
            }
          }
        }
      }
    }
  }
}
