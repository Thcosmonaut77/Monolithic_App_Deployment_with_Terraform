pipeline {
    agent any
    environment {
      MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED"   
    }    

    stages {   
        stage('Build with maven') {
            steps {
                sh 'cd SampleWebApp && mvn clean install'
            }
        }
        
             stage('Test') {
            steps {
                sh 'cd SampleWebApp && mvn test'
            }
        
            }
        stage('Code Qualty Scan') {

           steps {
                  withSonarQubeEnv('sonar') {
 

             sh "mvn -f SampleWebApp/pom.xml sonar:sonar"      
               }
            }
       }
        stage('Quality Gate') {
          steps {
                 waitForQualityGate abortPipeline: true
              }
        }
        stage('push to nexus') {
            steps {
             nexusArtifactUploader artifacts: [[artifactId: 'SampleWebApp', classifier: '', file: 'SampleWebApp/target/SampleWebApp.war', type: 'war']], credentialsId: '', groupId: 'SampleWebApp', nexusUrl: 'ec2-54-226-147-87.compute-1.amazonaws.com:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-snapshots', version: '1.0-SNAPSHOT'
            
        }
        }    
        stage('deploy to tomcat') {
          steps {
            deploy adapters: [tomcat9(alternativeDeploymentContext: '', credentialsId: 'tomcat_server', path: '', url: 'http://23.22.147.233:8080')], contextPath: 'myapp', war: '**/*.war'
              
          }
            
        }
            
        }
    }
