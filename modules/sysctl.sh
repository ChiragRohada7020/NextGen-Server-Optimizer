#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/utils.sh"

optimize_sysctl() {
    log "Optimizing sysctl configs"
    cp /etc/sysctl.conf /etc/sysctl.conf.bak.$(date +%s)

cat <<EOF > /etc/sysctl.conf
fs.file-max = 2097152
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_congestion_control = bbr
EOF

    sysctl -p
    log "Completed: sysctl optimization"
}
