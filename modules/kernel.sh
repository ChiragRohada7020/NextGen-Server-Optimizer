#!/bin/bash
# Kernel Optimization Module

LOG_FILE="/var/log/nextgen/kernel.log"
BACKUP_DIR="/etc/nextgen/backups"
CURRENT_DATE=$(date +%Y%m%d_%H%M%S)

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

echo "🔧 Optimizing kernel parameters..."
log "Starting kernel optimization"

# Backup current sysctl config
if [ -f /etc/sysctl.conf ]; then
    cp /etc/sysctl.conf "$BACKUP_DIR/sysctl.conf.backup.$CURRENT_DATE"
    log "Backed up sysctl.conf to $BACKUP_DIR/sysctl.conf.backup.$CURRENT_DATE"
fi

# Check if we're in a container
if [ -f /proc/1/cgroup ] && grep -q docker /proc/1/cgroup; then
    echo "⚠️  Running in container, some optimizations may not apply"
    log "Container environment detected"
fi

# Apply kernel optimizations
cat >> /etc/sysctl.conf << 'EOF'

# NextGen Kernel Optimizations - Added $(date)
# Network optimizations
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 65536 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 30000
net.ipv4.tcp_max_syn_backlog = 65536

# TCP optimizations
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 5

# Port range
net.ipv4.ip_local_port_range = 10000 65000

# Memory optimizations
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50

# Security optimizations
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
EOF

# Reload sysctl
if sysctl -p > /dev/null 2>&1; then
    echo "✅ Kernel optimization completed!"
    log "Kernel optimization completed successfully"
    
    # Show applied changes
    echo ""
    echo "📊 Applied kernel parameters:"
    sysctl -a 2>/dev/null | grep -E "(net.core|net.ipv4.tcp|vm.swappiness)" | head -10
else
    echo "❌ Kernel optimization failed!"
    log "Failed to apply kernel optimizations"
    
    # Restore backup
    if [ -f "$BACKUP_DIR/sysctl.conf.backup.$CURRENT_DATE" ]; then
        cp "$BACKUP_DIR/sysctl.conf.backup.$CURRENT_DATE" /etc/sysctl.conf
        log "Restored sysctl.conf from backup"
    fi
    exit 1
fi
