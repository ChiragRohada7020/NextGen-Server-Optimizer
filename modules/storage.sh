#!/bin/bash
# Storage Optimization Module

LOG_FILE="/var/log/nextgen/storage.log"

log() {
    echo "$(date): $1" >> "$LOG_FILE"
}

echo "💾 Optimizing storage settings..."

# Set I/O scheduler for SSDs and HDDs
for disk in /sys/block/sd*; do
    if [ -d "$disk" ]; then
        disk_name=$(basename "$disk")
        
        # Check if SSD
        if [ $(cat /sys/block/$disk_name/queue/rotational) -eq 0 ]; then
            # SSD - use mq-deadline or none
            echo mq-deadline > /sys/block/$disk_name/queue/scheduler 2>/dev/null || true
            log "Set mq-deadline scheduler for $disk_name (SSD)"
        else
            # HDD - use bfq or mq-deadline
            echo bfq > /sys/block/$disk_name/queue/scheduler 2>/dev/null || true
            log "Set bfq scheduler for $disk_name (HDD)"
        fi
        
        # Increase read-ahead for better sequential performance
        echo 4096 > /sys/block/$disk_name/queue/read_ahead_kb 2>/dev/null || true
    fi
done

# Enable trim for SSDs (if supported)
if command -v fstrim &> /dev/null; then
    fstrim -av >> "$LOG_FILE" 2>&1
    log "Executed fstrim on all filesystems"
fi

echo "✅ Storage optimization completed!"
