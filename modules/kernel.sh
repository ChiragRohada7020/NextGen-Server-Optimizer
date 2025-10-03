#!/bin/bash
source "$(dirname "$0")/utils.sh"

install_xanmod() {
  echo -e "${CYAN}>>> Installing XanMod (Debian/Ubuntu only)${NC}"
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "${ID}" != "debian" && "${ID}" != "ubuntu" && "${ID_LIKE:-}" != *"debian"* ]]; then
      echo "[!] XanMod supported only on Debian/Ubuntu. Skipping."
      return 0
    fi
  fi

  run "apt install -y wget gnupg"
  run "bash -c 'wget -qO - https://dl.xanmod.org/gpg.key | gpg --dearmor -o /usr/share/keyrings/xanmod-kernel.gpg'"
  run "bash -c 'echo \"deb [signed-by=/usr/share/keyrings/xanmod-kernel.gpg] http://deb.xanmod.org releases main\" > /etc/apt/sources.list.d/xanmod-kernel.list'"
  run "apt update -y"
  run "apt install -y linux-xanmod"
  # BBR activation will be applied by sysctl module as well
  echo "[$(date '+%F %T')] XanMod installation done (reboot recommended)" >> "$LOG_FILE"
}
