provider "aws" {
  region  = var.region
  profile = var.profile
}

# DEFAULT VPC
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default_vpc"
  }
}

# Get all availability zones
data "aws_availability_zones" "available_zones" {}

# Create default subnet in the first AZ
resource "aws_default_subnet" "subnet" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "default subnet"
  }
}

# create security group for the ec2 instance
resource "aws_security_group" "sonar_sg" {
  name        = "Sonarqube sg"
  description = "allow access on ports 9000 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  # allow access on port 9000
  ingress {
    description      = "sonarqube access"
    from_port        = 9000
    to_port          = 9000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http proxy access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # allow access on port 22
  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "sonarqube server security group"
  }
}

# UBUNTU AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"]
}

data "template_file" "sonar" {
  template = file("install_sonarqube.sh")

  vars = {
    user = var.user
    password = var.password
  }
}

# EC2 INSTANCE 
resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_default_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.sonar_sg.id]
  key_name                    = var.kp
  user_data                   = data.template_file.sonar.rendered

  tags = {
    Name = "Sonarqube-Server"
  }
}

# print the url of the sonarqube server
output "sonar" {
  value     = join ("", ["http://", aws_instance.ec2_instance.public_dns, ":", "9000"])
}