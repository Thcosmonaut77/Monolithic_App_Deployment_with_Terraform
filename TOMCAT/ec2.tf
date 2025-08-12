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

# SECURITY GROUP for EC2
resource "aws_security_group" "ec2_sg_tomcat" {
  name        = "ec2-security-group-tomcat"
  description = "Allow access on ports 8080, 22, 80, and 443"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "HTTP proxy access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["3.80.98.215/32"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Tomcat server security group"
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

data "template_file" "tomcat" {
  template = file("install_tomcat.sh")

  vars = {
    script_user            = var.script_user
    script_password        = var.script_password
    gui_user               = var.gui_user
    gui_password           = var.gui_password
   
  }
}

# EC2 INSTANCE 
resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_default_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg_tomcat.id]
  key_name                    = var.kp
  user_data                   = data.template_file.tomcat.rendered

  tags = {
    Name = "Tomcat-Server"
  }
}

# print the url of the jenkins server
output "tomcat" {
  value     = join("", ["http://", aws_instance.ec2_instance.public_ip, ":", "8080"])
}
