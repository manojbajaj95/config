#!/bin/bash
#
# macOS Font Installation Script
# Purpose: Install custom fonts to macOS system
#
# Usage: ./install-fonts.sh [source_directory]
#

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Configuration
DEFAULT_SOURCE_DIR="$HOME/Assets/fonts"
DEST_DIR="$HOME/Library/Fonts"
LOG_FILE="$HOME/font-installation.log"

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

log_info() {
    echo -e "${CYAN}INFO:${NC} $*" | tee -a "$LOG_FILE"
}

# Error handler
error_exit() {
    log_error "$1"
    log_error "Font installation failed. Check log file: $LOG_FILE"
    exit 1
}

# Banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "║        macOS Font Installation            ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        error_exit "This script must be run on macOS"
    fi
}

# Determine source directory
get_source_dir() {
    if [ $# -ge 1 ]; then
        echo "$1"
    else
        echo "$DEFAULT_SOURCE_DIR"
    fi
}

# Validate source directory
validate_source() {
    local source_dir="$1"

    if [ ! -d "$source_dir" ]; then
        error_exit "Source directory not found: $source_dir"
    fi

    # Check if directory contains font files
    local font_count=$(find "$source_dir" -type f \( -iname "*.ttf" -o -iname "*.otf" -o -iname "*.ttc" -o -iname "*.dfont" \) | wc -l | xargs)

    if [ "$font_count" -eq 0 ]; then
        error_exit "No font files found in: $source_dir"
    fi

    log_info "Found $font_count font file(s) in: $source_dir"
}

# Validate destination directory
validate_destination() {
    if [ ! -d "$DEST_DIR" ]; then
        log "Creating destination directory: $DEST_DIR"
        mkdir -p "$DEST_DIR" || error_exit "Failed to create destination directory"
    fi

    if [ ! -w "$DEST_DIR" ]; then
        error_exit "Destination directory is not writable: $DEST_DIR"
    fi

    log_info "Destination directory: $DEST_DIR"
}

# Install fonts
install_fonts() {
    local source_dir="$1"
    local installed=0
    local skipped=0
    local failed=0

    log "Installing fonts from: $source_dir"
    echo ""

    # Find all font files
    while IFS= read -r -d '' font_file; do
        local font_name=$(basename "$font_file")
        local dest_file="$DEST_DIR/$font_name"

        # Check if font already exists
        if [ -f "$dest_file" ]; then
            log_warning "Already exists: $font_name (skipping)"
            ((skipped++))
            continue
        fi

        # Copy font file
        if cp "$font_file" "$DEST_DIR/"; then
            log "Installed: $font_name"
            ((installed++))
        else
            log_error "Failed to install: $font_name"
            ((failed++))
        fi
    done < <(find "$source_dir" -type f \( -iname "*.ttf" -o -iname "*.otf" -o -iname "*.ttc" -o -iname "*.dfont" \) -print0)

    echo ""
    log "═══════════════════════════════════════"
    log "Installation Summary:"
    log "  Installed: $installed"
    log "  Skipped: $skipped (already installed)"
    log "  Failed: $failed"
    log "═══════════════════════════════════════"

    if [ $installed -eq 0 ] && [ $skipped -eq 0 ]; then
        error_exit "No fonts were installed"
    fi

    if [ $failed -gt 0 ]; then
        log_warning "Some fonts failed to install. Check the log file."
    fi
}

# Refresh font cache
refresh_font_cache() {
    log "Refreshing font cache..."

    # Clear font cache
    if command -v atsutil &> /dev/null; then
        atsutil databases -remove 2>/dev/null || log_warning "Failed to clear font database"
    fi

    # Restart font services (optional, usually not needed)
    # killall Finder 2>/dev/null || true

    log "Font cache refreshed"
    log_info "You may need to restart applications to see new fonts"
}

# Show installed fonts
show_installed_fonts() {
    echo ""
    log_info "Fonts installed in $DEST_DIR:"
    echo ""
    ls -1 "$DEST_DIR" | grep -E "\.(ttf|otf|ttc|dfont)$" | head -20

    local total_fonts=$(ls -1 "$DEST_DIR" | grep -E "\.(ttf|otf|ttc|dfont)$" | wc -l | xargs)

    if [ "$total_fonts" -gt 20 ]; then
        echo "... and $((total_fonts - 20)) more"
    fi

    echo ""
    log "Total fonts in Library: $total_fonts"
}

# Show recommendations
show_recommendations() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              Recommendations               ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo "1. Restart any open applications to use the new fonts"
    echo ""
    echo "2. View installed fonts in Font Book:"
    echo "   open -a 'Font Book'"
    echo ""
    echo "3. To install fonts system-wide (requires admin):"
    echo "   sudo cp fonts/* /Library/Fonts/"
    echo ""
    echo "4. Check the log file for details:"
    echo "   less $LOG_FILE"
    echo ""
}

# Main execution
main() {
    show_banner

    log "═══════════════════════════════════════"
    log "Font Installation Started"
    log "Started at: $(date)"
    log "═══════════════════════════════════════"
    echo ""

    # Pre-flight checks
    check_macos

    # Get source directory (from argument or default)
    local source_dir=$(get_source_dir "$@")

    # Validate directories
    validate_source "$source_dir"
    validate_destination
    echo ""

    # Install fonts
    install_fonts "$source_dir"

    # Refresh font cache
    echo ""
    refresh_font_cache

    # Show results
    show_installed_fonts
    show_recommendations

    log "═══════════════════════════════════════"
    log "Font installation completed!"
    log "Finished at: $(date)"
    log "Log file: $LOG_FILE"
    log "═══════════════════════════════════════"
}

# Run main function
main "$@"
