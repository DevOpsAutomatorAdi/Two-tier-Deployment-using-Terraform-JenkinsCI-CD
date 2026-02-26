# Generate SSH key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save pem locally
resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/jenkins-key.pem"
  file_permission = "0400"
}

# Create AWS key pair
resource "aws_key_pair" "generated" {
  key_name   = "jenkins-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Security Group
resource "aws_security_group" "jenkins_sg" {
  name_prefix = "jenkins-sg-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

# Jenkins EC2
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.generated.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = "jenkins-server"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/install_jenkins.sh"
    destination = "/home/ubuntu/install_jenkins.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "chmod +x /home/ubuntu/install_jenkins.sh",
      "sudo bash /home/ubuntu/install_jenkins.sh"
    ]
  }

  # Download credentials locally
  provisioner "local-exec" {
  command = "scp -o StrictHostKeyChecking=no -i ${path.module}/jenkins-key.pem ubuntu@${self.public_ip}:/home/ubuntu/jenkins-login.txt ./jenkins-login.txt"
}
}