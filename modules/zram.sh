#!/bin/bash
source "$(dirname "$0")/utils.sh"

setup_zram() {
  echo -e "${CYAN}>>> Setting up zram (2GB)${NC}"
  run "apt install -y zram-tools || true"
  # create systemd oneshot service to ensure zram on boot
  cat > /etc/systemd/system/nextgen-zram.service <<'EOF'
[Unit]
Description=NextGen zram setup
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'modprobe zram && echo lz4 > /sys/block/zram0/comp_algorithm || true; echo $((2*1024*1024*1024)) > /sys/block/zram0/disksize || true; mkswap /dev/zram0 || true; swapon -p 5 /dev/zram0 || true'
ExecStop=/bin/bash -c 'swapoff /dev/zram0 || true; rmmod zram || true'

[Install]
WantedBy=multi-user.target
EOF
  run "systemctl daemon-reload"
  run "systemctl enable --now nextgen-zram.service"
  echo "[$(date '+%F %T')] zram service created/enabled" >> "$LOG_FILE"
}
