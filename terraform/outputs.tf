output "wazuh-server-public-ip" {
  value = aws_eip.wazuh-server.public_ip
}

output "wazuh-server-private-ip" {
  # Agent enrollment/event ports (1514/1515) are security-group-restricted to
  # 172.31.0.0/16 only (VPC-internal) — agents must connect via this private
  # IP, not the public IP. Confirmed 2026-07-07: connecting via the public IP
  # times out even between two instances in the same VPC, since that traffic
  # doesn't match the private-CIDR-only ingress rule.
  value = aws_instance.wazuh-server.private_ip
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
