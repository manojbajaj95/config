#!/bin/bash
#
# Ubuntu First-Time Setup Script
# Purpose: Initial system setup and package installation for new Ubuntu installations
#
# Usage: sudo ./ubuntu-first-time.sh
#

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/packages.ubuntu.lst"
LOG_FILE="$HOME/ubuntu-first-time-setup.log"
BACKUP_DIR="$HOME/.config/setup-backups"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $*" | tee -a "$LOG_FILE"
}

log_step() {
    echo -e "${BLUE}[STEP $1]${NC} $2" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${CYAN}INFO:${NC} $*" | tee -a "$LOG_FILE"
}

# Error handler
error_exit() {
    log_error "$1"
    log_error "Setup failed. Check log file: $LOG_FILE"
    exit 1
}

# Banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "║   Ubuntu First-Time Setup Script          ║"
    echo "║   Initial system configuration             ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Check if packages file exists
check_packages_file() {
    if [ ! -f "$PACKAGES_FILE" ]; then
        error_exit "Packages file not found: $PACKAGES_FILE"
    fi

    # Check if file is empty
    if [ ! -s "$PACKAGES_FILE" ]; then
        error_exit "Packages file is empty: $PACKAGES_FILE"
    fi
}

# Create backup directory
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log "Created backup directory: $BACKUP_DIR"
    fi
}

# Backup important files
backup_files() {
    log_step "BACKUP" "Creating backups of important files"

    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_subdir="$BACKUP_DIR/pre-setup-$timestamp"
    mkdir -p "$backup_subdir"

    # Backup apt sources
    if [ -f /etc/apt/sources.list ]; then
        cp /etc/apt/sources.list "$backup_subdir/sources.list.backup"
        log "Backed up: /etc/apt/sources.list"
    fi

    # List installed packages
    dpkg --get-selections > "$backup_subdir/installed-packages.txt"
    log "Saved current package list to: $backup_subdir/installed-packages.txt"

    log "Backups created in: $backup_subdir"
}

# Update system
update_system() {
    log_step "1/5" "Updating package lists"
    apt-get update || error_exit "Failed to update package lists"

    log_step "2/5" "Upgrading installed packages"
    apt-get upgrade -y || error_exit "Failed to upgrade packages"
}

# Optional: Release upgrade
release_upgrade() {
    log_step "3/5" "Checking for Ubuntu release upgrade"

    # Check if update-manager-core is installed
    if ! dpkg -l | grep -q update-manager-core; then
        log_info "Installing update-manager-core..."
        apt-get install -y update-manager-core || log_warning "Failed to install update-manager-core"
    fi

    # Check if release upgrade is available
    if command -v do-release-upgrade >/dev/null 2>&1; then
        echo ""
        log_warning "Release upgrade is available but will NOT run automatically"
        log_info "To upgrade Ubuntu version, run: sudo do-release-upgrade"
        log_info "This is recommended only after verifying system compatibility"
        echo ""
    else
        log_info "Release upgrade not available or not applicable"
    fi
}

# Install packages from list
install_packages() {
    log_step "4/5" "Installing packages from list"

    # Read packages from file, filter comments and empty lines
    local packages=$(grep -v '^#' "$PACKAGES_FILE" | grep -v '^$' | tr '\n' ' ')

    if [ -z "$packages" ]; then
        log_warning "No packages to install"
        return
    fi

    log_info "Packages to install: $packages"
    echo ""

    # Count packages
    local package_count=$(echo "$packages" | wc -w)
    log "Installing $package_count package(s)..."
    echo ""

    # Check which packages are available
    log "Verifying package availability..."
    local unavailable_packages=""
    for pkg in $packages; do
        if ! apt-cache show "$pkg" >/dev/null 2>&1; then
            log_warning "Package not available: $pkg"
            unavailable_packages="$unavailable_packages $pkg"
        fi
    done

    # Remove unavailable packages from list
    if [ -n "$unavailable_packages" ]; then
        log_warning "The following packages are not available and will be skipped:"
        echo "$unavailable_packages"
        for pkg in $unavailable_packages; do
            packages=$(echo "$packages" | sed "s/\b$pkg\b//g")
        done
        echo ""
    fi

    # Install packages
    if [ -n "$(echo $packages | tr -d ' ')" ]; then
        # Use DEBIAN_FRONTEND=noninteractive to avoid prompts
        DEBIAN_FRONTEND=noninteractive apt-get install -y $packages || {
            log_error "Some packages failed to install"
            log_info "Check the log file for details: $LOG_FILE"
        }
        log "Package installation complete"
    else
        log_warning "No valid packages to install"
    fi
}

# Clean up
cleanup_system() {
    log_step "5/5" "Cleaning up unnecessary packages"

    apt-get autoremove -y || log_warning "Autoremove encountered issues"
    apt-get autoclean || log_warning "Autoclean encountered issues"

    log "Cleanup complete"
}

# Show installed package summary
show_summary() {
    echo ""
    log "═══════════════════════════════════════"
    log "Setup Complete!"
    log "═══════════════════════════════════════"
    echo ""

    # Show system info
    log_info "System Information:"
    echo "  OS: $(lsb_release -ds)"
    echo "  Kernel: $(uname -r)"
    echo "  Architecture: $(uname -m)"
    echo ""

    # Show disk space
    log_info "Disk Usage:"
    df -h / | tail -1 | awk '{print "  Root: " $3 " used / " $2 " total (" $5 " full)"}'

    # Show installed packages from our list
    local installed_count=0
    local failed_packages=""

    for pkg in $(grep -v '^#' "$PACKAGES_FILE" | grep -v '^$'); do
        if dpkg -l | grep -q "^ii  $pkg "; then
            ((installed_count++))
        else
            failed_packages="$failed_packages $pkg"
        fi
    done

    echo ""
    log_info "Package Installation Summary:"
    echo "  Successfully installed: $installed_count packages"

    if [ -n "$failed_packages" ]; then
        log_warning "Failed to install:$failed_packages"
    fi

    echo ""
    log "Log file saved to: $LOG_FILE"
    echo ""
}

# Post-setup recommendations
show_recommendations() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          Post-Setup Recommendations        ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo "1. Review the log file for any warnings or errors:"
    echo "   less $LOG_FILE"
    echo ""
    echo "2. Configure installed tools (zsh, vim, tmux, etc.):"
    echo "   ~/scripts/setup/zsh-setup.sh"
    echo "   ~/scripts/setup/vim-setup.sh"
    echo "   ~/scripts/setup/tmux-setup.sh"
    echo ""
    echo "3. Set up regular maintenance:"
    echo "   sudo ~/scripts/linux/ubuntu/ubuntu-maintenance-basic.sh"
    echo ""
    echo "4. Consider upgrading Ubuntu release (if needed):"
    echo "   sudo do-release-upgrade"
    echo ""
    echo "5. Reboot to ensure all changes take effect:"
    echo "   sudo reboot"
    echo ""
}

# Main execution
main() {
    show_banner

    log "═══════════════════════════════════════"
    log "Ubuntu First-Time Setup Started"
    log "Started at: $(date)"
    log "═══════════════════════════════════════"
    echo ""

    # Pre-flight checks
    check_root
    check_packages_file
    create_backup_dir

    # Create backups
    backup_files
    echo ""

    # Main setup steps
    update_system
    echo ""

    release_upgrade
    echo ""

    install_packages
    echo ""

    cleanup_system
    echo ""

    # Show results
    show_summary
    show_recommendations

    log "═══════════════════════════════════════"
    log "Setup completed successfully!"
    log "Finished at: $(date)"
    log "═══════════════════════════════════════"

    # Reboot prompt
    echo ""
    read -p "Do you want to reboot now? (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            log "Rebooting system in 5 seconds... (Ctrl+C to cancel)"
            sleep 5
            reboot
        ;;
        * )
            log "Reboot skipped. Please reboot manually later."
            echo "Run: sudo reboot"
        ;;
    esac
}

# Run main function
main "$@"
