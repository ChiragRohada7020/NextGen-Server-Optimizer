#!/bin/bash
# NextGen Server Optimizer - Main Script
# Version: 2.0.0

VERSION="2.0.0"
MODULES_DIR="/opt/nextgen/modules"
LOG_DIR="/var/log/nextgen"
CONFIG_DIR="/etc/nextgen"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): [INFO] $1" >> "$LOG_DIR/nextgen.log"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): [WARN] $1" >> "$LOG_DIR/nextgen.log"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): [ERROR] $1" >> "$LOG_DIR/nextgen.log"
}

# Display banner
show_banner() {
    echo -e "${MAGENTA}"
    cat << "EOF"
╔═══════════════════════════════════════════╗
║         NextGen Server Optimizer          ║
║                v2.0.0                     ║
║          Optimize Your Server             ║
║               Like a Pro!                 ║
╚═══════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# System information
show_system_info() {
    echo -e "${CYAN}🖥️  System Information:${NC}"
    [ -f /etc/os-release ] && echo -e "  OS: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
    echo -e "  Kernel: $(uname -r)"
    echo -e "  Architecture: $(uname -m)"
    echo -e "  CPU: $(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "?") cores"
    echo -e "  Memory: $(free -h 2>/dev/null | grep Mem: | awk '{print $2}' || echo "?")"
    echo ""
}

# Check root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "This script must be run as root!"
        echo "Use: sudo nextgen-optimizer [OPTIONS]"
        exit 1
    fi
}

# Check module
module_exists() {
    [ -f "$MODULES_DIR/${1}.sh" ] && return 0 || return 1
}

# Run module
run_module() {
    local module_name="$1"
    local module_file="$MODULES_DIR/${module_name}.sh"
    local module_log="$LOG_DIR/${module_name}.log"
    
    if ! module_exists "$module_name"; then
        error "Module '$module_name' not found!"
        return 1
    fi
    
    log "Starting $module_name optimization..."
    echo "=== $(date) - $module_name optimization ===" >> "$module_log"
    
    if bash "$module_file" >> "$module_log" 2>&1; then
        log "✅ $module_name optimization completed"
        return 0
    else
        error "❌ $module_name optimization failed - check $module_log"
        return 1
    fi
}

# Display help
show_help() {
    echo -e "${GREEN}NextGen Server Optimizer v$VERSION${NC}"
    echo ""
    echo -e "${CYAN}Usage:${NC}"
    echo "  nextgen-optimizer [OPTIONS]"
    echo ""
    echo -e "${CYAN}Options:${NC}"
    echo "  --all              Run all optimizations"
    echo "  --kernel           Optimize kernel parameters"
    echo "  --network          Optimize network settings"
    echo "  --storage          Optimize storage and I/O"
    echo "  --security         Apply security hardening"
    echo "  --services         Optimize system services"
    echo "  --nginx            Optimize Nginx web server"
    echo "  --info             Show system information"
    echo "  --help             Show this help message"
    echo "  --version          Show version information"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  nextgen-optimizer --all"
    echo "  nextgen-optimizer --kernel --network --security"
    echo "  nextgen-optimizer --info"
}

# Parse arguments
parse_arguments() {
    local show_help=false
    local show_version=false
    local show_info=false
    local modules=()
    
    if [ $# -eq 0 ]; then
        show_help=true
    fi
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help=true
                shift
                ;;
            --version)
                show_version=true
                shift
                ;;
            --info)
                show_info=true
                shift
                ;;
            --all)
                modules=("kernel" "network" "storage" "security" "services" "nginx")
                shift
                ;;
            --kernel|--network|--storage|--security|--services|--nginx)
                modules+=("${1#--}")
                shift
                ;;
            *)
                error "Unknown option: $1"
                show_help=true
                shift
                ;;
        esac
    done
    
    if [ "$show_help" = true ]; then
        show_help
        exit 0
    fi
    
    if [ "$show_version" = true ]; then
        echo "NextGen Server Optimizer v$VERSION"
        exit 0
    fi
    
    if [ "$show_info" = true ]; then
        show_banner
        show_system_info
        exit 0
    fi
    
    if [ ${#modules[@]} -eq 0 ]; then
        error "No modules specified!"
        show_help
        exit 1
    fi
    
    printf "%s\n" "${modules[@]}"
}

# Main execution
main() {
    show_banner
    check_root
    
    local modules
    mapfile -t modules < <(parse_arguments "$@")
    
    if [ ${#modules[@]} -eq 0 ]; then
        exit 1
    fi
    
    log "Starting optimization with modules: ${modules[*]}"
    show_system_info
    
    local success_count=0
    local total_count=${#modules[@]}
    
    for module in "${modules[@]}"; do
        if run_module "$module"; then
            ((success_count++))
        fi
        echo ""
    done
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}🎯 Optimization Summary:${NC}"
    echo -e "${GREEN}  Successful: $success_count/$total_count${NC}"
    echo -e "${GREEN}  Logs: $LOG_DIR${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    if [ $success_count -eq $total_count ]; then
        log "All optimizations completed successfully!"
        echo -e "${GREEN}✨ All optimizations completed successfully!${NC}"
    else
        warn "Some optimizations failed. Check logs for details."
        exit 1
    fi
}

# Run main function
main "$@"
