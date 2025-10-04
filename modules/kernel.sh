#!/bin/bash
# Kernel Optimization Module

LOG_FILE="/var/log/nextgen/kernel.log"

log() {
    echo "$(date): $1" >> "$LOG_FILE"
}

echo "🔧 Optimizing kernel parameters..."

# Backup current sysctl config
if [ -f /etc/sysctl.conf ]; then
    cp /etc/sysctl.conf /etc/sysctl.conf.backup.$(date +%Y%m%d)
    log "Backed up sysctl.conf"
fi

# Apply kernel optimizations
cat >> /etc/sysctl.conf << EOF

# NextGen Kernel Optimizations
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 65536 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 30000
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
EOF

# Reload sysctl
sysctl -p >> "$LOG_FILE" 2>&1

echo "✅ Kernel optimization completed!"
log "Kernel optimization finished successfully"
