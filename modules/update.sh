#!/bin/bash
source "$(dirname "$0")/utils.sh"

update_system() {
  echo -e "${CYAN}>>> Update & Upgrade & Clean${NC}"
  run "apt update -y"
  run "apt upgrade -y"
  run "apt full-upgrade -y"
  run "apt autoremove -y"
  run "apt autoclean -y"
  run "apt clean -y"
}
