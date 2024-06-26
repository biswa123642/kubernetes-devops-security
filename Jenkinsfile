@Library('slacklibrary') _

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
    imageName = "${registry}/devsecops:$TAG"
  }
  
  stages {
    stage('Build Artifact - Maven') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archiveArtifacts 'target/*.jar'
      }
    }
    stage('Unit Tests - JUnit And Jacoco') {
      steps {
        sh "mvn test"
      }
    }
    stage('Mutation Tests - PIT') {
      steps {
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
    }
   // stage('Dependency Scan') {
   //   steps {
   //     sh "mvn dependency-check:check"
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
    //stage('Vulnerability Kubernetes Scan') {
    //  steps {
    //    sh "bash trivy-k8s-scan.sh"
    //    sh "sudo rm -rf trivy"
    //  }
    //}
    stage('Deploy Image') {
      steps {
        dir('deploy') {
          sh "kustomize edit set image devsecops=*:$TAG"
          sh "kustomize build . | kubectl apply -f -"
        }
      }
    }
    stage('K8S CIS Benchmark') {
      steps {
        sh "bash cis-kubelet.sh"
      }
    }
  }
  post {
    always {
      junit 'target/surefire-reports/*.xml'
      jacoco execPattern: 'target/jacoco.exec'
      pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
      //dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
      sendNotification currentBuild.result
    }
  }
}
