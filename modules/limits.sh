#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/utils.sh"

optimize_limits() {
    log "Optimizing system limits"
    echo "* soft nofile 512000" >> /etc/security/limits.conf
    echo "* hard nofile 512000" >> /etc/security/limits.conf
    ulimit -n 512000
    log "Completed: system limits"
}
