#!/bin/bash
# ============================================================
# NextGen Server Optimizer v3
# Author: Javid
# ============================================================

LOG_FILE="/var/log/nextgen-setup.log"


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # بدون رنگ


logo() {
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
echo -e "${BLUE}========= NextGen v3 - Server Optimizer =========${NC}"
}


run_cmd() {
    echo -e "${YELLOW}[RUNNING]${NC} $1"
    echo "=== $(date '+%F %T') $1 ===" >> $LOG_FILE
    eval $1 >> $LOG_FILE 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[OK]${NC} $1"
    else
        echo -e "${RED}[FAILED]${NC} $1 (see $LOG_FILE)"
    fi
}


fix_hosts_dns() {
    echo -e "${BLUE}>>> Fixing Hosts & DNS...${NC}"
    cp /etc/hosts /etc/hosts.bak.$(date +%s)
    grep -q "127.0.1.1" /etc/hosts || echo "127.0.1.1 $(hostname)" >> /etc/hosts
    cp /etc/resolv.conf /etc/resolv.conf.bak.$(date +%s)
    echo -e "nameserver 1.1.1.2\nnameserver 1.0.0.2" > /etc/resolv.conf
    echo -e "${GREEN}Hosts & DNS fixed.${NC}"
}

update_system() {
    echo -e "${BLUE}>>> Updating system...${NC}"
    run_cmd "apt update -y"
    run_cmd "apt upgrade -y"
    run_cmd "apt full-upgrade -y"
    run_cmd "apt autoremove -y"
    run_cmd "apt autoclean -y"
    run_cmd "apt clean -y"
    echo -e "${GREEN}System updated.${NC}"
}

install_packages() {
    echo -e "${BLUE}>>> Installing useful packages...${NC}"
    run_cmd "apt install -y apt-transport-https apt-utils autoconf automake bash-completion bc binutils build-essential busybox ca-certificates cron curl dialog gnupg2 git haveged htop jq libssl-dev libsqlite3-dev libtool locales lsb-release make nano net-tools preload python3 python3-pip qrencode socat screen software-properties-common ufw unzip vim wget zip"
    echo -e "${GREEN}Packages installed.${NC}"
}

install_xanmod() {
    echo -e "${BLUE}>>> Installing XanMod Kernel...${NC}"
    run_cmd "curl -fsSL https://dl.xanmod.org/gpg.key | gpg --dearmor -o /usr/share/keyrings/xanmod.gpg"
    run_cmd "echo 'deb [signed-by=/usr/share/keyrings/xanmod.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod.list"
    run_cmd "apt update -y"
    run_cmd "apt install -y linux-xanmod"
    echo -e "${GREEN}XanMod kernel installed.${NC}"
}

optimize_sysctl() {
    echo -e "${BLUE}>>> Optimizing sysctl...${NC}"
    cp /etc/sysctl.conf /etc/sysctl.conf.bak.$(date +%s)
    cat <<EOF > /etc/sysctl.conf
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF
    sysctl -p
    echo -e "${GREEN}Sysctl optimized.${NC}"
}

optimize_ssh() {
    echo -e "${BLUE}>>> Optimizing SSH...${NC}"
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%s)
    sed -i 's/#TCPKeepAlive yes/TCPKeepAlive yes/' /etc/ssh/sshd_config
    sed -i 's/#Compression no/Compression yes/' /etc/ssh/sshd_config
    systemctl restart ssh
    echo -e "${GREEN}SSH optimized.${NC}"
}


run_all() {
    fix_hosts_dns
    update_system
    install_packages
    optimize_sysctl
    optimize_ssh
}

run_all_xanmod() {
    run_all
    install_xanmod
}


menu() {
    logo
    echo -e "${YELLOW}[1] Run ALL + XanMod Kernel${NC}"
    echo -e "${YELLOW}[2] Run ALL (without XanMod)${NC}"
    echo -e "[3] Fix Hosts & DNS"
    echo -e "[4] Update/Upgrade/Clean"
    echo -e "[5] Install Useful Packages"
    echo -e "[6] Install XanMod Kernel"
    echo -e "[7] Optimize sysctl"
    echo -e "[8] Optimize SSH"
    echo -e "${YELLOW}[9] Run Security + Optimization (sysctl + ssh)${NC}"
    echo -e "[0] Exit"
    echo
    read -p "Select an option [0-9]: " choice
    case $choice in
        1) run_all_xanmod ;;
        2) run_all ;;
        3) fix_hosts_dns ;;
        4) update_system ;;
        5) install_packages ;;
        6) install_xanmod ;;
        7) optimize_sysctl ;;
        8) optimize_ssh ;;
        9) optimize_sysctl; optimize_ssh ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
}


menu


echo -e "\n${GREEN}✅ NextGen Setup Completed!${NC}"
read -p "🔄 Do you want to reboot now? (yes/no): " answer
if [[ "$answer" == "yes" || "$answer" == "y" ]]; then
    echo -e "${YELLOW}Rebooting...${NC}"
    reboot
else
    echo -e "${BLUE}Reboot skipped. Please reboot manually later.${NC}"
fi
