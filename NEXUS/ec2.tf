# configured aws provider with proper credentials
provider "aws" {
  region    = var.region
  profile   = var.profile
}


# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

  tags    = {
    Name  = "default vpc"
  }
}


# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create default subnet if one does not exit
resource "aws_default_subnet" "subnet" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags   = {
    Name = "nexus subnet"
  }
}


# create security group for the ec2 instance
resource "aws_security_group" "nexus_sg" {
  name        = "Nexus security group"
  description = "allow access on ports 8081 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  # allow access on port 8081
  ingress {
    description      = "nexus access"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # ingress {
  #   description      = "http proxy access"
  #   from_port        = 8082
  #   to_port          = 8082
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  # }

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
    Name = "nexus server security group"
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

  owners = ["099720109477"] # Canonical
}

# launch the ec2 instance and install website
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_default_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.nexus_sg.id]
  key_name               = var.kp
  user_data = file("install_nexus.sh")

  tags = {
    Name = "nexus_server"
  }
}


# print the url of the jenkins server
output "nexus" {
  value     = join ("", ["http://", aws_instance.ec2_instance.public_dns, ":", "8081"])
}
