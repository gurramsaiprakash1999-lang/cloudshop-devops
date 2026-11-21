provider "aws" {
  region = "ap-south-2"
}

# Dynamic fetch for Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_security_group" "app_sg" {
  name        = "cloudshop-app-sg"
  description = "Allow SSH and HTTP ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami                  = data.aws_ami.al2023.id
  instance_type        = "t3.micro"
  key_name             = "devops-kp" # Match your AWS key name
  security_groups      = [aws_security_group.app_sg.name]
  associate_public_ip_address = true

  tags = {
    Name = "CloudShop-App-Server"
  }
}

output "app_server_public_ip" {
  value = aws_instance.app_server.public_ip
}
