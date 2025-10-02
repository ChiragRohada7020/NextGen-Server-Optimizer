#!/bin/bash
source "$(dirname "$0")/utils.sh"

optimize_system() {
    log_info "Installing Optimizer..."
    sysctl -w net.ipv4.tcp_fin_timeout=10 >/dev/null 2>&1
    sysctl -w net.ipv4.tcp_tw_reuse=1 >/dev/null 2>&1
    sysctl -w fs.file-max=2097152 >/dev/null 2>&1
    log_success "Optimizer Succefully!"
}
