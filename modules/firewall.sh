#!/bin/bash
source "$(dirname "$0")/utils.sh"

setup_firewall() {
    log_info "در حال تنظیم فایروال..."
    ufw disable >/dev/null 2>&1
    ufw reset >/dev/null 2>&1
    ufw allow ssh >/dev/null 2>&1
    ufw default deny incoming >/dev/null 2>&1
    ufw default allow outgoing >/dev/null 2>&1
    yes | ufw enable >/dev/null 2>&1
    log_success "فایروال با موفقیت تنظیم شد!"
}
