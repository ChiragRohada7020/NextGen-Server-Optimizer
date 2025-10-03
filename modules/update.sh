#!/bin/bash
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/utils.sh"

update_upgrade() {
    log "Starting: Update/Upgrade/Clean"
    apt update -y && apt upgrade -y && apt full-upgrade -y
    apt autoremove -y && apt autoclean -y && apt clean -y
    log "Completed: Update/Upgrade/Clean"
}
