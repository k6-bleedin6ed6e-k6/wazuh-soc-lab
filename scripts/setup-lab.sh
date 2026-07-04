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
echo "[ terraform ] provisioning t3.small..."
cd "$TF_DIR"
terraform init -upgrade -input=false
terraform apply -auto-approve \
  -var "admin_ip=$ADMIN_IP"

WAZUH_IP=$(terraform output -raw wazuh-server-public-ip)
SSH_CMD=$(terraform output -raw ssh-command)

echo ""
echo "[ terraform ] done — wazuh server: $WAZUH_IP"

# --- 3. write ansible inventory ---
cat > "$ANSIBLE_DIR/inventory/hosts.ini" <<EOF
[wazuh_server]
wazuh ansible_host=$WAZUH_IP

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
