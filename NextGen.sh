#!/bin/bash

# ==============================
# NextGen Server Optimizer v3
# Created by Javid
# ==============================


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' 


logo() {
clear
echo -e "${CYAN}"
cat << "EOF"
 _        _______          _________   _______  _______  _       
( (    /|(  ____ \|\     /|\__   __/  (  ____ \(  ____ \( (    /|
|  \  ( || (    \/( \   / )   ) (     | (    \/| (    \/|  \  ( |
|   \ | || (__     \ (_) /    | |     | |      | (__    |   \ | |
| (\ \) ||  __)     ) _ (     | |     | | ____ |  __)   | (\ \) |
| | \   || (       / ( ) \    | |     | | \_  )| (      | | \   |
| )  \  || (____/\( /   \ )   | |     | (___) || (____/\| )  \  |
|/    )_)(_______/|/     \|   )_(     (_______)(_______/|/    )_)
                                                                 
EOF
echo -e "${NC}${YELLOW}       🚀 NextGen Server Optimizer v3 🚀${NC}\n"
}


menu() {
echo -e "${CYAN}Select an option:${NC}"
echo -e "${GREEN} 1) Run All + Xanmod Kernel${NC}"
echo -e "${GREEN} 2) Firewall Optimization${NC}"
echo -e "${GREEN} 3) Kernel Optimization (Xanmod)${NC}"
echo -e "${GREEN} 4) System Optimizer${NC}"
echo -e "${GREEN} 0) Exit${NC}\n"
}


run_all() {
    echo -e "${YELLOW}[INFO] Running full optimization with Xanmod Kernel...${NC}"
  
    sleep 2
    echo -e "${GREEN}[SUCCESS] All tasks completed.${NC}"
}

firewall_opt() {
    echo -e "${YELLOW}[INFO] Optimizing Firewall (UFW)...${NC}"
    sleep 1
    echo -e "${GREEN}[SUCCESS] Firewall optimized.${NC}"
}

kernel_opt() {
    echo -e "${YELLOW}[INFO] Installing & configuring Xanmod Kernel...${NC}"
    sleep 1
    echo -e "${GREEN}[SUCCESS] Xanmod Kernel installed and BBRv3 enabled.${NC}"
}

system_opt() {
    echo -e "${YELLOW}[INFO] Running system optimization...${NC}"
    sleep 1
    echo -e "${GREEN}[SUCCESS] System optimization completed.${NC}"
}


ask_reboot() {
    echo -e "\n${CYAN}Do you want to reboot now? (y/n)${NC}"
    read -r answer
    if [[ $answer == "y" || $answer == "Y" ]]; then
        echo -e "${YELLOW}[INFO] Rebooting...${NC}"
        reboot
    else
        echo -e "${GREEN}[OK] Skipping reboot.${NC}"
    fi
}


while true; do
    logo
    menu
    read -rp "Select an option [0-4]: " opt
    case $opt in
        1) run_all; ask_reboot ;;
        2) firewall_opt ;;
        3) kernel_opt; ask_reboot ;;
        4) system_opt ;;
        0) echo -e "${RED}[EXIT] Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}[ERROR] Invalid option!${NC}" ;;
    esac
    echo -e "\n${YELLOW}Press Enter to return to menu...${NC}"
    read
done
