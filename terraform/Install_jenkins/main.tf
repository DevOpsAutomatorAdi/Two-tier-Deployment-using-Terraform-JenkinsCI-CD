provider "aws" {
  region = var.region
}

module "jenkins" {
  source = "../modules/jenkins"

  instance_type    = var.instance_type
  allowed_ssh_cidr = var.allowed_ssh_cidr
}