output "instance_public_ip" {
  value = module.ec2.instance_public_ip
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "two-tier_url" {
  value = "http://${module.ec2.instance_public_ip}:8085"
}

output "private_key" {
  value     = module.ec2.private_key
  sensitive = true
}
