#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/utils.sh"

install_xanmod() {
    log "Installing XanMod Kernel + BBRv3"
    apt install -y gnupg software-properties-common curl
    curl -fsSL https://dl.xanmod.org/gpg.key | gpg --dearmor -o /usr/share/keyrings/xanmod.gpg
    echo "deb [signed-by=/usr/share/keyrings/xanmod.gpg] http://deb.xanmod.org releases main" \
    | tee /etc/apt/sources.list.d/xanmod.list
    apt update -y && apt install -y linux-xanmod
    echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
    sysctl -p
    log "Completed: XanMod + BBRv3"
}
