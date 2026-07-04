output "wazuh-server-public-ip" {
  value = aws_eip.wazuh-server.public_ip
}

output "wazuh-server-instance-id" {
  value = aws_instance.wazuh-server.id
}

output "wazuh-dashboard-url" {
  value = "https://${aws_eip.wazuh-server.public_ip}"
}

output "ssh-command" {
  value = "ssh -i ~/.ssh/py-bite.pem ubuntu@${aws_eip.wazuh-server.public_ip}"
}
