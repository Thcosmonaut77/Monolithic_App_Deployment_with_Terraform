# Monolithic Application Deployment with Terraform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4?logo=terraform&logoColor=white)
![Jenkins](https://img.shields.io/badge/Jenkins-CI/CD-D24939?logo=jenkins&logoColor=white)
![SonarQube](https://img.shields.io/badge/SonarQube-Code%20Quality-4E9BCD?logo=sonarqube&logoColor=white)
![Nexus](https://img.shields.io/badge/Nexus-Artifact%20Repo-2E4E7E?logo=sonatype&logoColor=white)
![Tomcat](https://img.shields.io/badge/Tomcat-Web%20Server-F8DC75?logo=apache-tomcat&logoColor=black)
![Maven](https://img.shields.io/badge/Maven-Build%20Tool-C71A36?logo=apachemaven&logoColor=white)

This repository demonstrates the deployment of a **monolithic application stack** using **Infrastructure as Code (IaC)** with Terraform.  

The stack integrates:
- **Jenkins** → Continuous Integration / Continuous Delivery (CI/CD)
- **Maven** → Build tool
- **Nexus** → Artifact repository
- **SonarQube** → Code quality and vulnerability scanning
- **Tomcat** → Web application server  
- **Sample Web Application** → A demo app packaged and deployed via Jenkins pipeline  

Each component is provisioned on its own EC2 instance in AWS.  
Terraform code for each service resides in separate directories.

---

## Architecture Overview

```mermaid
flowchart LR
    Developer((Developer)) -->|Push Code| Jenkins
    Jenkins -->|Build with Maven| Nexus
    Jenkins -->|Code Scan| SonarQube
    Nexus -->|Deploy Artifact (WAR)| Tomcat
    SonarQube -->|Report| Jenkins
    Tomcat -->|Serve App| User((End User))
```    

## Repository Structure
```bash
.
├── JENKINS/ # Terraform configs for Jenkins server
├── SONARQUBE/ # Terraform configs for SonarQube server
├── NEXUS/ # Terraform configs for Nexus repository
├── TOMCAT/ # Terraform configs for Tomcat server
├── SampleWebApp/ # Example Java web application (Maven project)
└── Jenkinsfile # Declarative pipeline for building, testing, and deploying the SampleWebApp
```

---

## Prerequisites
Before deployment, ensure you have:
- An **AWS account** with permissions to create VPC, EC2, Security Groups
- **Terraform** installed locally
- An existing **SSH key pair** in AWS
- Ubuntu **22.04 AMI** available in your target AWS region
- Basic knowledge of **Maven** and **Jenkins Pipelines**

---

## Deployment
Each infrastructure component is deployed independently from its directory.  

Example (for Jenkins):
```bash
cd JENKINS
terraform init
terraform apply --auto-approve

cd SONARQUBE
terraform init
terraform apply --auto-approve

cd NEXUS
terraform init
terraform apply --auto-approve

cd TOMCAT
terraform init
terraform apply --auto-approve

```


## CI/CD Pipeline (Jenkinsfile)

• The provided Jenkinsfile defines a declarative pipeline that:

• Pulls code from the repository

• Builds the SampleWebApp using Maven

• Runs unit tests and performs static code analysis with SonarQube

• Uploads artifacts to Nexus

• Deploys the application to Tomcat 

## Component Details
### Jenkins

• Network: Default VPC, subnet, and availability zone

• Ingress:

   • Port 8080: From admin IP + SonarQube server IP(update after SonarQube server is running)

   • Port 22: From admin IP

   • Ports 80, 443: From anywhere

• Egress: All traffic (-1)

• AMI: Ubuntu 22.04

• User data installs: Java 21, Maven, Jenkins

• Notes:

   • Setup time: ~3–5 minutes

   • Initial admin password: /var/lib/jenkins/secrets/initialAdminPassword

   • After first login → set username/password + install suggested plugins

### SonarQube

• Network: Default VPC, subnet, and availability zone

• Ingress:

   • Ports 8080, 9000: From anywhere

   • Port 22: From admin IP

• Egress: All traffic (-1)

• AMI: Ubuntu 22.04

• User data installs:

   • Java 21

   • PostgreSQL 16 (creates user + DB)

   • SonarQube (persistent env vars, systemd service, firewall rules)

• Default login:

   • Username: admin

   • Password: admin (must be changed after first login)

### Nexus

• Network: Default VPC, subnet, and availability zone

• Ingress:

   • Port 8081: From anywhere

   • Port 22: From admin IP

• Egress: All traffic (-1)

• AMI: Ubuntu 22.04

• User data installs:

   • Java 8 + dependencies

   • Nexus (dedicated user, directories, systemd service)

• Initial password: /opt/nexus/sonatype-work/nexus3/admin.password

### Tomcat

• Network: Default VPC, subnet, and availability zone

• Ingress:

   • Ports 8080, 80, 443: From anywhere

   • Port 22: From admin IP

• Egress: All traffic (-1)

• AMI: Ubuntu 22.04

• User data installs:

   • Java 21

   • Tomcat 9 (user config, removed RemoteAddrValve restriction, JAVA_HOME setup, firewall rule)

### Sample Web Application

• Located in the SampleWebApp/ directory

• Standard Maven Java web project (pom.xml included)

• Packaged into a .war file during Jenkins pipeline build

• Deployed to Tomcat automatically

## Notes

• Each server is deployed separately with terraform init && terraform apply in its respective directory.

• Ensure your key pair name matches an existing AWS key pair.

• If a service isn’t accessible immediately after provisioning, wait a few minutes for installation scripts to complete.

## License

- This project is licensed under the MIT License — See the 'LICENSE' file for full details.