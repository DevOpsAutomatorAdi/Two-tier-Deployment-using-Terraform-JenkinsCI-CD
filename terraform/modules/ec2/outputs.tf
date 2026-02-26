output "instance_public_ip" {
  value = aws_instance.two-tier.public_ip
}

output "instance_id" {
  value = aws_instance.two-tier.id
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
# output "jenkins_public_ip" {
#   value = aws_instance.jenkins_server.public_ip
# }

# output "jenkins_url" {
#   value = "http://${aws_instance.jenkins_server.public_ip}:8080"
# }

# output "ssh_command" {
#   value = "ssh -i jenkins-key.pem ubuntu@${aws_instance.jenkins_server.public_ip}"
# }

# output "jenkins_credentials_file" {
#   value = "jenkins_credentials.txt"
# }