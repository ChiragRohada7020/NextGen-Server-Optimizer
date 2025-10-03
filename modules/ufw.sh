#!/bin/bash
source "$(dirname "$0")/utils.sh"

configure_ufw() {
  echo -e "${CYAN}>>> Configuring UFW (SSH,80,443)...${NC}"
  backup_file /etc/default/ufw
  # ensure IPv6 enabled
  if ! grep -q "^IPV6=" /etc/default/ufw 2>/dev/null; then
    echo "IPV6=yes" >> /etc/default/ufw
  else
    sed -i 's/^IPV6=.*/IPV6=yes/' /etc/default/ufw
  fi
  run "ufw default deny incoming"
  run "ufw default allow outgoing"
  run "ufw allow ssh"
  run "ufw allow 80/tcp"
  run "ufw allow 443/tcp"
  run "ufw --force enable"
  echo "[$(date '+%F %T')] ufw configured" >> "$LOG_FILE"
}
