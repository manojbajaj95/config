#!/bin/bash
#
# macOS First-Time Setup Script
# Purpose: Initial system setup with Homebrew and essential packages
#
# Usage: ./mac-first-time.sh
#

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"
LOG_FILE="$HOME/mac-first-time-setup.log"
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
    echo "║     macOS First-Time Setup Script         ║"
    echo "║   Initial system configuration             ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        error_exit "This script must be run on macOS"
    fi
}

# Check if Brewfile exists
check_brewfile() {
    if [ ! -f "$BREWFILE" ]; then
        error_exit "Brewfile not found: $BREWFILE"
    fi
    log_info "Found Brewfile: $BREWFILE"
}

# Create backup directory
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log "Created backup directory: $BACKUP_DIR"
    fi
}

# Backup installed packages
backup_installed_packages() {
    log_step "BACKUP" "Creating backup of currently installed packages"

    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_subdir="$BACKUP_DIR/pre-setup-$timestamp"
    mkdir -p "$backup_subdir"

    # Backup currently installed brew packages (if brew exists)
    if command -v brew &> /dev/null; then
        log "Backing up current Homebrew installations..."
        brew bundle dump --file="$backup_subdir/Brewfile.backup" --force 2>/dev/null || true
        brew list --formula > "$backup_subdir/brew-formula.txt" 2>/dev/null || true
        brew list --cask > "$backup_subdir/brew-cask.txt" 2>/dev/null || true
        log "Brew backup saved to: $backup_subdir"
    else
        log_info "Homebrew not installed yet, skipping brew backup"
    fi

    # Backup system info
    sw_vers > "$backup_subdir/system-info.txt" 2>/dev/null || true
    system_profiler SPSoftwareDataType >> "$backup_subdir/system-info.txt" 2>/dev/null || true

    log "Backups created in: $backup_subdir"
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    log_step "1/3" "Installing Xcode Command Line Tools"

    # Check if already installed
    if xcode-select -p &> /dev/null; then
        log_info "Xcode Command Line Tools already installed at: $(xcode-select -p)"
        return 0
    fi

    log "Installing Xcode Command Line Tools..."
    log_warning "This may prompt for your password and open a GUI installer"
    echo ""

    # Trigger installation
    xcode-select --install 2>/dev/null || true

    # Wait for installation
    echo ""
    log_info "Waiting for Xcode Command Line Tools installation..."
    log_info "Please complete the installation in the popup window"
    echo ""

    # Poll until installed (with timeout)
    local timeout=600  # 10 minutes
    local elapsed=0
    local interval=5

    while ! xcode-select -p &> /dev/null; do
        if [ $elapsed -ge $timeout ]; then
            error_exit "Xcode Command Line Tools installation timeout after ${timeout}s"
        fi

        echo -n "."
        sleep $interval
        elapsed=$((elapsed + interval))
    done

    echo ""
    log "Xcode Command Line Tools installed successfully"
}

# Install Homebrew
install_homebrew() {
    log_step "2/3" "Installing Homebrew"

    # Check if already installed
    if command -v brew &> /dev/null; then
        log_info "Homebrew already installed at: $(which brew)"
        log_info "Homebrew version: $(brew --version | head -1)"

        # Update Homebrew
        log "Updating Homebrew..."
        brew update || log_warning "Homebrew update encountered issues"
        return 0
    fi

    log "Installing Homebrew..."
    log_warning "This may prompt for your password"
    echo ""

    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || \
        error_exit "Homebrew installation failed"

    # Check if brew is in PATH
    if ! command -v brew &> /dev/null; then
        log_warning "Homebrew installed but not in PATH"

        # Try to add to PATH for Apple Silicon Macs
        if [ -f /opt/homebrew/bin/brew ]; then
            log_info "Detected Apple Silicon Mac, adding Homebrew to PATH"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        # Try Intel Macs
        elif [ -f /usr/local/bin/brew ]; then
            log_info "Detected Intel Mac, adding Homebrew to PATH"
            eval "$(/usr/local/bin/brew shellenv)"
        else
            error_exit "Cannot find Homebrew binary after installation"
        fi
    fi

    log "Homebrew installed successfully: $(brew --version | head -1)"
}

# Install packages from Brewfile
install_brewfile_packages() {
    log_step "3/3" "Installing packages from Brewfile"

    if ! command -v brew &> /dev/null; then
        error_exit "Homebrew not found. Cannot install packages."
    fi

    log_info "Installing packages from: $BREWFILE"
    echo ""

    # Show what will be installed
    log "Packages to be installed:"
    grep -E "^(brew|cask|tap)" "$BREWFILE" | grep -v "^#" | tee -a "$LOG_FILE"
    echo ""

    # Install from Brewfile
    log "Running: brew bundle --file=$BREWFILE"
    echo ""

    if brew bundle --file="$BREWFILE" --no-lock 2>&1 | tee -a "$LOG_FILE"; then
        log "Package installation complete"
    else
        log_warning "Some packages may have failed to install"
        log_info "Check the log file for details: $LOG_FILE"
    fi

    # Run brew doctor to check for issues
    echo ""
    log "Running brew doctor to check for issues..."
    brew doctor 2>&1 | tee -a "$LOG_FILE" || log_warning "brew doctor found some issues"
}

# Show summary
show_summary() {
    echo ""
    log "═══════════════════════════════════════"
    log "Setup Complete!"
    log "═══════════════════════════════════════"
    echo ""

    # Show system info
    log_info "System Information:"
    echo "  macOS Version: $(sw_vers -productVersion)"
    echo "  Build: $(sw_vers -buildVersion)"
    echo "  Architecture: $(uname -m)"
    echo ""

    # Show Homebrew info
    if command -v brew &> /dev/null; then
        log_info "Homebrew Installation:"
        echo "  Location: $(which brew)"
        echo "  Version: $(brew --version | head -1)"
        echo "  Prefix: $(brew --prefix)"
        echo ""

        log_info "Installed Packages:"
        local formula_count=$(brew list --formula | wc -l | xargs)
        local cask_count=$(brew list --cask 2>/dev/null | wc -l | xargs)
        echo "  Formulae: $formula_count"
        echo "  Casks: $cask_count"
    fi

    echo ""
    log "Log file saved to: $LOG_FILE"
    echo ""
}

# Show recommendations
show_recommendations() {
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          Post-Setup Recommendations        ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo "1. Review the log file for any warnings or errors:"
    echo "   less $LOG_FILE"
    echo ""
    echo "2. Add Homebrew to your shell profile (if not already done):"
    if [ -f /opt/homebrew/bin/brew ]; then
        echo "   echo 'eval \"\$(/opt/homebrew/bin/brew shellenv)\"' >> ~/.zprofile"
        echo "   eval \"\$(/opt/homebrew/bin/brew shellenv)\""
    else
        echo "   echo 'eval \"\$(/usr/local/bin/brew shellenv)\"' >> ~/.zprofile"
        echo "   eval \"\$(/usr/local/bin/brew shellenv)\""
    fi
    echo ""
    echo "3. Configure installed tools (zsh, vim, tmux, etc.):"
    echo "   ~/scripts/setup/zsh-setup.sh"
    echo "   ~/scripts/setup/vim-setup.sh"
    echo "   ~/scripts/setup/tmux-setup.sh"
    echo ""
    echo "4. Install fonts (if needed):"
    echo "   ~/scripts/mac/install-fonts.sh"
    echo ""
    echo "5. Keep your system updated regularly:"
    echo "   brew update && brew upgrade && brew cleanup"
    echo ""
    echo "6. Restart your terminal to ensure PATH changes take effect"
    echo ""
}

# Main execution
main() {
    show_banner

    log "═══════════════════════════════════════"
    log "macOS First-Time Setup Started"
    log "Started at: $(date)"
    log "═══════════════════════════════════════"
    echo ""

    # Pre-flight checks
    check_macos
    check_brewfile
    create_backup_dir

    # Create backups
    backup_installed_packages
    echo ""

    # Main setup steps
    install_xcode_tools
    echo ""

    install_homebrew
    echo ""

    install_brewfile_packages
    echo ""

    # Show results
    show_summary
    show_recommendations

    log "═══════════════════════════════════════"
    log "Setup completed successfully!"
    log "Finished at: $(date)"
    log "═══════════════════════════════════════"
}

# Run main function
main "$@"
