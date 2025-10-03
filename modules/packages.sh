#!/bin/bash
source "$(dirname "$0")/utils.sh"

install_packages() {
  echo -e "${CYAN}>>> Installing useful packages${NC}"
  local pkgs=(apt-transport-https apt-utils autoconf automake bash-completion bc binutils build-essential busybox ca-certificates cron curl dialog gnupg2 git haveged htop jq keyring libssl-dev libsqlite3-dev libtool locales lsb-release make nano net-tools packagekit preload python3 python3-pip qrencode socat screen software-properties-common ufw unzip vim wget zip cpufrequtils)
  run "DEBIAN_FRONTEND=noninteractive apt install -y ${pkgs[*]}"
  # enable services that make sense
  if command -v systemctl >/dev/null 2>&1; then
    run "systemctl enable haveged || true"
    run "systemctl start haveged || true"
  fi
}
