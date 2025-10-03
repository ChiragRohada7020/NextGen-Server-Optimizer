#!/bin/bash
source "$(dirname "$0")/utils.sh"

fix_hosts_dns() {
  echo -e "${CYAN}>>> Fixing /etc/hosts and /etc/resolv.conf${NC}"
  backup_file /etc/hosts
  if ! grep -qE "127\.0\.1\.1\s+$(hostname)" /etc/hosts 2>/dev/null; then
    run "bash -c 'echo \"127.0.1.1 $(hostname)\" >> /etc/hosts'"
  else
    echo "[i] 127.0.1.1 entry already present"
  fi

  backup_file /etc/resolv.conf
  cat > /etc/resolv.conf <<'EOF'
# NextGen: Cloudflare Security DNS
nameserver 1.1.1.2
nameserver 1.0.0.2
EOF
  echo "[$(date '+%F %T')] /etc/resolv.conf updated" >> "$LOG_FILE"
}
