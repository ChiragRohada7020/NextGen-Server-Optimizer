#!/usr/bin/env bash
# NextGen v4 - Main
#Created by Javid
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/modules"


if [[ "$EUID" -ne 0 ]]; then
  echo "Run as root: sudo $0"
  exit 1
fi


source "$BASE_DIR/utils.sh"


source "$BASE_DIR/hosts_dns.sh"
source "$BASE_DIR/update.sh"
source "$BASE_DIR/packages.sh"
source "$BASE_DIR/kernel.sh"
source "$BASE_DIR/timezone.sh"
source "$BASE_DIR/zram.sh"
source "$BASE_DIR/sysctl.sh"
source "$BASE_DIR/ssh.sh"
source "$BASE_DIR/limits.sh"
source "$BASE_DIR/ufw.sh"
source "$BASE_DIR/performance.sh"
source "$BASE_DIR/qol.sh"

show_logo() {
  echo -e "${CYAN}"
  cat <<'EOF'
 _        _______          _________   _______  _______  _       
( (    /|(  ____ \|\     /|\__   __/  (  ____ \(  ____ \( (    /|
|  \  ( || (    \/( \   / )   ) (     | (    \/| (    \/|  \  ( |
|   \ | || (__     \ (_) /    | |     | |      | (__    |   \ | |
| (\ \) ||  __)     ) _ (     | |     | | ____ |  __)   | (\ \) |
| | \   || (       / ( ) \    | |     | | \_  )| (      | | \   |
| )  \  || (____/\( /   \ )   | |     | (___) || (____/\| )  \  |
|/    )_)(_______/|/     \|   )_(     (_______)(_______/|/    )_)
                                                                 
EOF
  echo -e "${NC}${YELLOW}       🚀 NextGen Server Optimizer v4 🚀${NC}\n"
}

menu() {
  clear
  show_logo
  echo -e "${CYAN}Select an option:${NC}"
  echo -e "${GREEN} 1) Run All (Full) + XanMod${NC}"
  echo -e "${GREEN} 2) Run All (without XanMod)${NC}"
  echo -e "${GREEN} 3) Hosts & DNS${NC}"
  echo -e "${GREEN} 4) Update & Clean${NC}"
  echo -e "${GREEN} 5) Install Packages${NC}"
  echo -e "${GREEN} 6) Install XanMod Kernel${NC}"
  echo -e "${GREEN} 7) ZRAM (2GB)${NC}"
  echo -e "${GREEN} 8) Sysctl Optimizations${NC}"
  echo -e "${GREEN} 9) SSH Optimizations${NC}"
  echo -e "${GREEN}10) Limits (ulimit)${NC}"
  echo -e "${GREEN}11) UFW (SSH/80/443)${NC}"
  echo -e "${GREEN}12) Performance Tweaks${NC}"
  echo -e "${GREEN}13) QOL tweaks (aliases, motd)${NC}"
  echo -e "${GREEN}0) Exit${NC}"
  echo
  read -rp "Select [0-13]: " opt
  case "$opt" in
    1)
      fix_hosts_dns
      update_system
      install_packages
      install_xanmod
      set_timezone_from_ip
      setup_zram
      optimize_sysctl
      optimize_ssh
      optimize_limits
      configure_ufw
      performance_tweaks
      apply_qol
      ;;
    2)
      fix_hosts_dns
      update_system
      install_packages
      set_timezone_from_ip
      setup_zram
      optimize_sysctl
      optimize_ssh
      optimize_limits
      configure_ufw
      performance_tweaks
      apply_qol
      ;;
    3) fix_hosts_dns ;;
    4) update_system ;;
    5) install_packages ;;
    6) install_xanmod ;;
    7) setup_zram ;;
    8) optimize_sysctl ;;
    9) optimize_ssh ;;
    10) optimize_limits ;;
    11) configure_ufw ;;
    12) performance_tweaks ;;
    13) apply_qol ;;
    0) exit 0 ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
  esac

  echo
  read -rp "Press Enter to return to menu..."
  menu
}


menu


