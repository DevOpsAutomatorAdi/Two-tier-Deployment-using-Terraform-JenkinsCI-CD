# Generate TLS key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key as .pem file
resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/two-tier-key.pem"
  file_permission = "0400"
}

# Create AWS key pair
resource "aws_key_pair" "generated" {
  key_name   = "two-tier-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Get latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical official account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group
resource "aws_security_group" "two-tier_sg" {
  name = "two-tier-sg"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "two-tier"
    from_port   = 8085
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    description = "two-tier"
    from_port   = 5432
    to_port     = 5432
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

# EC2 instance
resource "aws_instance" "two-tier" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.generated.key_name
  vpc_security_group_ids = [aws_security_group.two-tier_sg.id]
  root_block_device {
    volume_size = 15
    volume_type = "gp3"
    delete_on_termination = true
  }


  tags = {
    Name = "two-tier-server"
  }
   # SSH connection details
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
    host        = self.public_ip
  }

  # Install Docker using provisioner
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt-get update -y",
  #     "sudo apt-get install -y docker.io",
  #     "sudo systemctl enable docker",
  #     "sudo systemctl start docker",
  #     "sudo usermod -aG docker ubuntu && newgrp docker",
  #      "sudo apt-get update -y",
  #      "sudo apt-get install -y docker-compose",
  #      "git clone --branch postgres https://github.com/DevOpsAutomatorAdi/loginflask.git",
  #      "docker-compose up -d"

  #   ]
  # }
 provisioner "file" {
  source      = "${path.module}/setup.sh"
  destination = "/home/ubuntu/setup.sh"
}

provisioner "remote-exec" {
  inline = [
    "chmod +x /home/ubuntu/setup.sh",
    "sudo bash /home/ubuntu/setup.sh"
  ]
}


}
# Security Group for Jenkins
