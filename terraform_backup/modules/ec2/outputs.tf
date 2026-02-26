output "instance_public_ip" {
  value = aws_instance.directus.public_ip
}

output "instance_id" {
  value = aws_instance.directus.id
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
