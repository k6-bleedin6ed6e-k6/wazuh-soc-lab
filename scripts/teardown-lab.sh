#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$LAB_DIR/terraform"
ANSIBLE_DIR="$LAB_DIR/ansible"

echo ""
echo "[ wazuh-lab ] teardown"
echo "──────────────────────────────────────"
echo "  this will TERMINATE the wazuh-server instance and release its EIP."
echo "  the t3.micro honeypot is NOT affected."
echo ""
read -rp "  confirm teardown? [yes/no]: " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "  aborted."
  exit 0
fi

# remove agent config from honeypot before destroying manager
echo "[ ansible ] stopping Wazuh agent on honeypot..."
if [[ -f "$ANSIBLE_DIR/inventory/hosts.ini" ]]; then
  cd "$ANSIBLE_DIR"
  ansible honeypot -m systemd -a "name=wazuh-agent state=stopped enabled=no" || true
fi

# destroy infrastructure
echo "[ terraform ] destroying wazuh-server..."
cd "$TF_DIR"
ADMIN_IP=$(curl -s https://checkip.amazonaws.com)/32
terraform destroy -auto-approve \
  -var "admin_ip=$ADMIN_IP"

# clean up inventory
rm -f "$ANSIBLE_DIR/inventory/hosts.ini"

echo ""
echo "──────────────────────────────────────"
echo "[ wazuh-lab ] torn down — no billing on wazuh-server"
echo ""
