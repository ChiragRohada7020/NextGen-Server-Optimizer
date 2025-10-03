#!/bin/bash
source "$(dirname "$0")/utils.sh"

optimize_ssh() {
  echo -e "${CYAN}>>> Optimizing SSH configuration${NC}"
  backup_file /etc/ssh/sshd_config
  # Idempotent additions
  grep -q "^UseDNS no" /etc/ssh/sshd_config || echo "UseDNS no" >> /etc/ssh/sshd_config
  grep -q "^TCPKeepAlive" /etc/ssh/sshd_config || echo "TCPKeepAlive yes" >> /etc/ssh/sshd_config
  grep -q "^ClientAliveInterval" /etc/ssh/sshd_config || echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
  grep -q "^ClientAliveCountMax" /etc/ssh/sshd_config || echo "ClientAliveCountMax 2" >> /etc/ssh/sshd_config
  grep -q "^AllowTcpForwarding" /etc/ssh/sshd_config || echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config
  grep -q "^GatewayPorts" /etc/ssh/sshd_config || echo "GatewayPorts yes" >> /etc/ssh/sshd_config
  grep -q "^Compression" /etc/ssh/sshd_config || echo "Compression yes" >> /etc/ssh/sshd_config
  grep -q "^X11Forwarding" /etc/ssh/sshd_config || echo "X11Forwarding yes" >> /etc/ssh/sshd_config

  # Optionally tighten ciphers (but keep compatibility)
  # grep -q "^Ciphers" /etc/ssh/sshd_config || echo "Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,chacha20-poly1305@openssh.com" >> /etc/ssh/sshd_config

  run "systemctl restart ssh || systemctl restart sshd || true"
  echo "[$(date '+%F %T')] sshd_config optimized" >> "$LOG_FILE"
}
