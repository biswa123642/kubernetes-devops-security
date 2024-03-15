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
        archiveArtifacts 'target/*.jar'
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
    stage('Docker Vulnerability Scan') {
      steps {
        parallel(
          "Trivy Scan": {
            sh "bash trivy-docker-image-scan.sh"
            sh "sudo rm -rf trivy"
          },
          "OPA Conftest": {
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy dockerfile-security.rego Dockerfile'
          }
        )
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
        dir('deploy') {
          sh "kustomize edit set image devsecops=*:$TAG"
          sh "kustomize build . | kubectl apply -f -"
        }
      }
    }
  }
}
