terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  required_version = ">= 1.4"
}

provider "aws" {
  region = var.aws_region
}

# Get latest Ubuntu 22.04 AMI (Canonical)
data "aws_ami" "ubuntu" {
  owners      = ["099720109477"] # Canonical
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "sg" {
  name        = "${var.name_prefix}-sg"
  description = "Allow SSH, HTTP ports for logging stack"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip_cidr]
  }

  ingress {
    description = "Kibana"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = [var.allow_cidr]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.allow_cidr]
  }

  ingress {
    description = "Elasticsearch"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = [var.allow_cidr]
  }

  ingress {
    description = "Kafka"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [var.allow_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-sg"
  }
}

# Default VPC look up
data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "node" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  user_data = <<-EOF
  #!/usr/bin/env bash
  set -xe

  # Update packages
  apt-get update -y

  # Install dependencies
  apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release git

  # Install Docker
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io

  # Install latest Docker Compose v2 (always compatible with latest Docker)
  curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
      -o /usr/local/bin/docker-compose

  chmod +x /usr/local/bin/docker-compose

  # Add ubuntu to docker group
  usermod -aG docker ubuntu || true

  # Clone repo
  cd /home/ubuntu
  if [ ! -d "distributed-logging" ]; then
    git clone ${var.repo_url} distributed-logging
  fi

  cd distributed-logging

  # Run compose stack
  /usr/local/bin/docker-compose up -d --build

  EOF


  tags = {
    Name = "${var.name_prefix}-node"
  }

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
  }
}

# If you want to change ownership of the repo dir for ubuntu user, add a small null_resource (optional)
resource "null_resource" "fix_permissions" {
  depends_on = [aws_instance.node]
  provisioner "local-exec" {
    command = "echo 'Instance created: ${aws_instance.node.public_ip}'"
  }
}

output "instance_public_ip" {
  value = aws_instance.node.public_ip
}

output "ssh_command" {
  value = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.node.public_ip}"
}
