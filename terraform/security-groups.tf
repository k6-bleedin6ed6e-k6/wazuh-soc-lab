resource "aws_security_group" "wazuh-server" {
  name        = "wazuh-server"
  description = "Wazuh manager + dashboard"
  vpc_id      = var.vpc_id

  # SSH — admin only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  # Dashboard HTTPS — admin only
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  # Wazuh agent enrollment — VPC (EC2 agents) + admin_ip (local workstation agent)
  ingress {
    from_port   = 1515
    to_port     = 1515
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16", var.admin_ip]
  }

  # Wazuh agent event forwarding — VPC (EC2 agents) + admin_ip (local workstation agent)
  ingress {
    from_port   = 1514
    to_port     = 1514
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16", var.admin_ip]
  }

  # Wazuh API — admin only
  ingress {
    from_port   = 55000
    to_port     = 55000
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "wazuh-server-sg"
    Project = "wazuh-soc-lab"
  }
}
