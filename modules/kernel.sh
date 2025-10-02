#!/bin/bash
source "$(dirname "$0")/utils.sh"

install_xanmod() {
    log_info "نصب Xanmod Kernel..."
    apt update -y >/dev/null 2>&1
    apt install -y linux-xanmod >/dev/null 2>&1
    log_success "Xanmod Kernel نصب شد!"
}
