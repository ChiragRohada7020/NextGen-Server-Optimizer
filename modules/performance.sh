#!/bin/bash
source "$(dirname "$0")/utils.sh"

performance_tweaks() {
  echo -e "${CYAN}>>> Applying performance tweaks${NC}"
  # CPU governor
  run "apt install -y cpufrequtils || true"
  if command -v cpufreq-set >/dev/null 2>&1; then
    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
      cpuidx=$(basename "$cpu")
      run "cpufreq-set -c ${cpuidx#cpu} -g performance || true"
    done
  else
    # fallback: write default governor
    echo 'GOVERNOR="performance"' > /etc/default/cpufrequtils || true
  fi

  # reduce journald disk usage
  mkdir -p /etc/systemd/journald.conf.d
  cat > /etc/systemd/journald.conf.d/nextgen.conf <<'EOF'
[Journal]
SystemMaxUse=100M
RuntimeMaxUse=50M
MaxRetentionSec=1month
EOF
  run "systemctl restart systemd-journald || true"

  # disable apt timers to speed up runtime (safe)
  run "systemctl disable --now apt-daily.service apt-daily.timer apt-daily-upgrade.timer || true"

  echo "[$(date '+%F %T')] performance tweaks applied" >> "$LOG_FILE"
}
