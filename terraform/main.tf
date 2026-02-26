provider "aws" {
  region = var.region
}

module "ec2" {
  source = "./modules/ec2"

  instance_type    = var.instance_type
  allowed_ssh_cidr = var.allowed_ssh_cidr


}
# module "jenkins" {
#   source = "./modules/jenkins"
#   instance_type    = var.instance_type
#   allowed_ssh_cidr = var.allowed_ssh_cidr
# }

