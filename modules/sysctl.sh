#!/bin/bash
source "$(dirname "$0")/utils.sh"

optimize_sysctl() {
  echo -e "${CYAN}>>> Applying sysctl optimizations${NC}"
  backup_file /etc/sysctl.conf
  cat >> /etc/sysctl.conf <<'EOF'

# NextGen v4 optimizations
# Networking
net.core.default_qdisc = fq
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.somaxconn = 1024
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_tw_reuse = 1
# VM
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
# File limits
fs.file-max = 2097152
EOF
  run "sysctl -p || true"
  echo "[$(date '+%F %T')] sysctl applied" >> "$LOG_FILE"
}
