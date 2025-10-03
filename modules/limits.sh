#!/bin/bash
source "$(dirname "$0")/utils.sh"

optimize_limits() {
  echo -e "${CYAN}>>> Applying system limits${NC}"
  backup_file /etc/security/limits.conf
  if ! grep -q "NextGen limits" /etc/security/limits.conf 2>/dev/null; then
    cat >> /etc/security/limits.conf <<'EOF'

# NextGen limits
* soft nofile 1000000
* hard nofile 1000000
* soft nproc 65535
* hard nproc 65535
EOF
  fi
  echo "[$(date '+%F %T')] limits applied" >> "$LOG_FILE"
}
