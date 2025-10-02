#!/bin/bash

# ============================================================
# NextGen Server Optimizer v3
# Author: Javid
# ============================================================

BASE_DIR="$(dirname "$0")/modules"
source "$BASE_DIR/utils.sh"
source "$BASE_DIR/firewall.sh"
source "$BASE_DIR/kernel.sh"
source "$BASE_DIR/optimizer.sh"

show_menu() {
clear
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
echo -e "${YELLOW} NextGen Server Optimizer - Main Menu ${RESET}"
echo ""
echo " 1) Run All + Xanmod Kernel"
echo " 2) Firewall Optimization"
echo " 3) Kernel Optimization (Xanmod)"
echo " 4) System Optimizer"
echo " 0) Exit"
echo ""
}

run_all() {
    setup_firewall
    install_xanmod
    optimize_system
    ask_reboot
}

ask_reboot() {
    read -p "ریبوت کنم؟ (yes/no): " choice
    if [[ "$choice" == "yes" ]]; then
        log_info "سیستم در حال ریبوت..."
        reboot
    else
        log_info "سیستم ریبوت نشد."
    fi
}

while true; do
    show_menu
    read -p "گزینه رو انتخاب کن: " opt
    case $opt in
        1) run_all ;;
        2) setup_firewall ;;
        3) install_xanmod ;;
        4) optimize_system ;;
        0) exit ;;
        *) log_error "گزینه نامعتبره" ;;
    esac
    read -p "ادامه بده (Enter بزن)..."
done
