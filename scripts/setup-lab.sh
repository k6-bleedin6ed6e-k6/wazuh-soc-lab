#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$LAB_DIR/terraform"
ANSIBLE_DIR="$LAB_DIR/ansible"
KEY="$HOME/.ssh/py-bite.pem"

echo ""
echo "[ wazuh-lab ] setup starting"
echo "──────────────────────────────────────"

# --- 1. get admin IP ---
ADMIN_IP=$(curl -s https://checkip.amazonaws.com)/32
echo "  admin IP:  $ADMIN_IP"

# --- 2. terraform apply ---
echo ""
echo "[ terraform ] provisioning c7i-flex.large..."
cd "$TF_DIR"
terraform init -upgrade -input=false
terraform apply -auto-approve \
  -var "admin_ip=$ADMIN_IP"

WAZUH_IP=$(terraform output -raw wazuh-server-public-ip)
WAZUH_PRIVATE_IP=$(terraform output -raw wazuh-server-private-ip)
SSH_CMD=$(terraform output -raw ssh-command)

echo ""
echo "[ terraform ] done — wazuh server: $WAZUH_IP (private: $WAZUH_PRIVATE_IP)"

# --- 3. write ansible inventory ---
# private_ip is separate from ansible_host on purpose: ansible_host is the
# public IP (needed for Ansible's own SSH from outside the VPC), private_ip
# is what agents must use to reach the manager (1514/1515 are security-group-
# restricted to the VPC CIDR only — the public IP times out even from another
# instance in the same VPC).
mkdir -p "$ANSIBLE_DIR/inventory"
cat > "$ANSIBLE_DIR/inventory/hosts.ini" <<EOF
[wazuh_server]
wazuh ansible_host=$WAZUH_IP private_ip=$WAZUH_PRIVATE_IP

[honeypot]
honeypot-ec2 ansible_host=34.225.113.167

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=$KEY
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

echo "[ ansible ] inventory written"

# --- 4. wait for SSH ---
echo "[ ansible ] waiting for server to be SSH-ready..."
sleep 30

# --- 5. install wazuh manager ---
echo "[ ansible ] installing Wazuh (5-10 min)..."
cd "$ANSIBLE_DIR"
ansible-playbook playbooks/install-wazuh-manager.yml

# --- 6. install wazuh agent on honeypot ---
echo "[ ansible ] wiring honeypot as Wazuh agent..."
ansible-playbook playbooks/install-wazuh-agent.yml

echo ""
echo "──────────────────────────────────────"
echo "[ wazuh-lab ] done"
echo ""
echo "  dashboard:  https://$WAZUH_IP"
echo "  ssh:        $SSH_CMD"
echo "  creds:      check ansible output above for admin password"
echo ""
