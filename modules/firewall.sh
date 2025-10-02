#!/bin/bash
source "$(dirname "$0")/utils.sh"

setup_firewall() {
    log_info "Waiting For Firewall..."
    ufw disable >/dev/null 2>&1
    ufw reset >/dev/null 2>&1
    ufw allow ssh >/dev/null 2>&1
    ufw default deny incoming >/dev/null 2>&1
    ufw default allow outgoing >/dev/null 2>&1
    yes | ufw enable >/dev/null 2>&1
    log_success "Firewall Activated!"
}
