#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/utils.sh"

setup_ufw() {
    log "Configuring UFW firewall"
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    log "Completed: UFW firewall"
}
