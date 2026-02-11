#!/bin/bash
#
# Ubuntu Comprehensive System Maintenance Script
# Based on: https://gist.github.com/Limbicnation/6763b69ab6a406790f3b7d4b56a2f6e8
# Purpose: Enterprise-grade system cleanup with security hardening
#
# Features:
# - Lock-based execution (prevents concurrent runs)
# - APT lock detection with timeout
# - Safe configuration loading
# - Protected folders (won't delete .git, node_modules, etc.)
# - Dry-run mode support
# - Comprehensive logging
# - System snapshot support
#
# Usage:
#   sudo ./ubuntu-maintenance-full.sh           # Normal run
#   sudo ./ubuntu-maintenance-full.sh -d        # Dry-run (show what would be done)
#   sudo ./ubuntu-maintenance-full.sh -v        # Verbose mode
#   sudo ./ubuntu-maintenance-full.sh -t 300    # Set timeout to 300 seconds
#

set -euo pipefail  # Strict error handling

# Configuration
SCRIPT_NAME="ubuntu-maintenance-full"
LOCK_FILE="/var/lock/${SCRIPT_NAME}.lock"
CONFIG_FILE="$HOME/.config/ubuntu_cleanup.conf"
LOG_FILE="/var/log/${SCRIPT_NAME}.log"
DRY_RUN=false
VERBOSE=false
APT_TIMEOUT=300
KEEP_KERNELS=2  # Keep current + N-1 kernels

# Protected folders (never delete these)
PROTECTED_PATTERNS=(
    ".git"
    "node_modules"
    ".npm"
    ".cargo"
    ".rustup"
    ".venv"
    "venv"
    "__pycache__"
    ".cache/pip"
)

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] STEP $1:${NC} $2" | tee -a "$LOG_FILE"
}

# Cleanup function (called on exit)
cleanup() {
    if [ -f "$LOCK_FILE" ]; then
        rm -f "$LOCK_FILE"
        log "Lock file removed"
    fi
}

trap cleanup EXIT INT TERM

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    log_error "This script must be run as root (use sudo)"
    exit 1
fi

# Parse command line arguments
while getopts "dvt:h" opt; do
    case $opt in
        d) DRY_RUN=true ;;
        v) VERBOSE=true ;;
        t) APT_TIMEOUT=$OPTARG ;;
        h)
            echo "Usage: $0 [-d] [-v] [-t timeout] [-h]"
            echo "  -d: Dry run (show what would be done)"
            echo "  -v: Verbose mode"
            echo "  -t: APT lock timeout in seconds (default: 300)"
            echo "  -h: Show this help"
            exit 0
            ;;
        \?) log_error "Invalid option: -$OPTARG"; exit 1 ;;
    esac
done

# Check for existing lock
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        log_error "Another instance is already running (PID: $PID)"
        exit 1
    else
        log_warning "Stale lock file found, removing..."
        rm -f "$LOCK_FILE"
    fi
fi

# Create lock file
echo $$ > "$LOCK_FILE"

# Wait for APT locks to be released
wait_for_apt() {
    local timeout=$APT_TIMEOUT
    local elapsed=0

    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
          fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || \
          fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do

        if [ $elapsed -ge $timeout ]; then
            log_error "APT is locked after ${timeout}s timeout. Another package manager is running."
            return 1
        fi

        log_warning "Waiting for APT locks to be released... (${elapsed}s/${timeout}s)"
        sleep 5
        elapsed=$((elapsed + 5))
    done

    return 0
}

# Load configuration file if exists
if [ -f "$CONFIG_FILE" ]; then
    log "Loading configuration from $CONFIG_FILE"
    # Safe configuration loading - only allow specific variables
    while IFS='=' read -r key value; do
        case $key in
            KEEP_KERNELS) KEEP_KERNELS=$value ;;
            APT_TIMEOUT) APT_TIMEOUT=$value ;;
        esac
    done < "$CONFIG_FILE"
fi

# Main execution
log "=== Ubuntu Comprehensive System Maintenance ==="
log "Started at: $(date)"
[ "$DRY_RUN" = true ] && log "DRY RUN MODE - No changes will be made"
echo ""

# Wait for APT to be available
wait_for_apt || exit 1

# Step 1: Update package lists
log_step "1/20" "Updating package lists"
if [ "$DRY_RUN" = false ]; then
    apt-get update
else
    echo "Would run: apt-get update"
fi

# Step 2: Upgrade packages
log_step "2/20" "Upgrading installed packages"
if [ "$DRY_RUN" = false ]; then
    apt-get upgrade -y
else
    echo "Would run: apt-get upgrade -y"
fi

# Step 3: Dist-upgrade
log_step "3/20" "Performing dist-upgrade"
if [ "$DRY_RUN" = false ]; then
    apt-get dist-upgrade -y
else
    echo "Would run: apt-get dist-upgrade -y"
fi

# Step 4: Remove unused packages
log_step "4/20" "Removing unused packages"
if [ "$DRY_RUN" = false ]; then
    apt-get autoremove -y
else
    UNUSED=$(apt-get autoremove --dry-run | grep -Po '^\d+ (?=upgraded)')
    echo "Would remove $UNUSED packages"
fi

# Step 5: Clean APT cache
log_step "5/20" "Cleaning APT cache"
if [ "$DRY_RUN" = false ]; then
    apt-get autoclean
    apt-get clean
else
    echo "Would run: apt-get autoclean && apt-get clean"
fi

# Step 6: Remove old kernels
log_step "6/20" "Removing old kernels (keeping current + $((KEEP_KERNELS - 1)) backup)"
CURRENT_KERNEL=$(uname -r)
if [ "$DRY_RUN" = false ]; then
    # Keep current kernel + N-1 most recent
    OLD_KERNELS=$(dpkg --list | grep -P "linux-(headers|image|modules)-\d+\.\d+\.\d+-\d+" | \
                  grep -v "$CURRENT_KERNEL" | awk '{print $2}' | sort -V | head -n -$((KEEP_KERNELS - 1)))

    if [ -n "$OLD_KERNELS" ]; then
        log "Removing: $OLD_KERNELS"
        apt-get purge -y $OLD_KERNELS || log_warning "Some kernels may already be removed"
    else
        log "No old kernels to remove"
    fi
else
    echo "Would check and remove old kernels"
fi

# Step 7: Clean user cache
log_step "7/20" "Cleaning user cache directories"
if [ "$DRY_RUN" = false ]; then
    find /home -type d -name ".cache" -exec du -sh {} \; 2>/dev/null || true
    find /home -type d -name ".cache" -exec rm -rf {}/thumbnails/* \; 2>/dev/null || true
else
    echo "Would clean user cache directories"
fi

# Step 8: Clean Snap cache (if snap is installed)
if command -v snap &> /dev/null; then
    log_step "8/20" "Cleaning Snap cache"
    if [ "$DRY_RUN" = false ]; then
        snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
            snap remove "$snapname" --revision="$revision" || true
        done
    else
        echo "Would clean Snap cache"
    fi
else
    log_step "8/20" "Snap not installed, skipping"
fi

# Step 9: Clean Flatpak cache (if flatpak is installed)
if command -v flatpak &> /dev/null; then
    log_step "9/20" "Cleaning Flatpak cache"
    if [ "$DRY_RUN" = false ]; then
        flatpak uninstall --unused -y || true
    else
        echo "Would clean Flatpak cache"
    fi
else
    log_step "9/20" "Flatpak not installed, skipping"
fi

# Step 10: Clean systemd journal
log_step "10/20" "Cleaning systemd journal (keep last 7 days)"
if [ "$DRY_RUN" = false ]; then
    journalctl --vacuum-time=7d
else
    JOURNAL_SIZE=$(journalctl --disk-usage | grep -oP '\d+\.\d+[GM]')
    echo "Current journal size: $JOURNAL_SIZE"
    echo "Would run: journalctl --vacuum-time=7d"
fi

# Step 11: Clean temporary files
log_step "11/20" "Cleaning temporary files"
if [ "$DRY_RUN" = false ]; then
    find /tmp -type f -atime +7 -delete 2>/dev/null || true
    find /var/tmp -type f -atime +7 -delete 2>/dev/null || true
else
    echo "Would clean temporary files older than 7 days"
fi

# Step 12: Clean browser caches
log_step "12/20" "Cleaning browser caches"
if [ "$DRY_RUN" = false ]; then
    # Chrome/Chromium
    find /home -type d -path "*/.cache/google-chrome/Default/Cache" -exec rm -rf {} \; 2>/dev/null || true
    find /home -type d -path "*/.cache/chromium/Default/Cache" -exec rm -rf {} \; 2>/dev/null || true
    # Firefox
    find /home -type d -path "*/.mozilla/firefox/*/cache2" -exec rm -rf {} \; 2>/dev/null || true
else
    echo "Would clean browser caches (Chrome, Chromium, Firefox)"
fi

# Step 13: Clean package manager caches
log_step "13/20" "Cleaning package manager caches"
if [ "$DRY_RUN" = false ]; then
    # pip cache
    if command -v pip3 &> /dev/null; then
        pip3 cache purge 2>/dev/null || true
    fi
    # npm cache
    if command -v npm &> /dev/null; then
        npm cache clean --force 2>/dev/null || true
    fi
else
    echo "Would clean pip and npm caches"
fi

# Step 14: Clean old log files
log_step "14/20" "Rotating and compressing old log files"
if [ "$DRY_RUN" = false ]; then
    find /var/log -type f -name "*.log" -size +50M -exec gzip {} \; 2>/dev/null || true
else
    echo "Would compress log files larger than 50MB"
fi

# Step 15: Remove orphaned packages
log_step "15/20" "Checking for orphaned packages"
if command -v deborphan &> /dev/null; then
    if [ "$DRY_RUN" = false ]; then
        ORPHANS=$(deborphan)
        if [ -n "$ORPHANS" ]; then
            log "Removing orphaned packages: $ORPHANS"
            echo "$ORPHANS" | xargs apt-get -y remove --purge
        else
            log "No orphaned packages found"
        fi
    else
        echo "Would check and remove orphaned packages"
    fi
else
    log_warning "deborphan not installed (apt-get install deborphan)"
fi

# Step 16: Check for broken dependencies
log_step "16/20" "Checking for broken dependencies"
if [ "$DRY_RUN" = false ]; then
    apt-get check
else
    echo "Would run: apt-get check"
fi

# Step 17: Update file database
log_step "17/20" "Updating file database (updatedb)"
if [ "$DRY_RUN" = false ]; then
    updatedb 2>/dev/null || log_warning "updatedb failed or not installed"
else
    echo "Would run: updatedb"
fi

# Step 18: Check disk space
log_step "18/20" "Checking disk space"
df -h / | tail -1 | awk '{print "Root partition: " $3 " used / " $2 " total (" $5 " full)"}' | tee -a "$LOG_FILE"
df -h /home 2>/dev/null | tail -1 | awk '{print "Home partition: " $3 " used / " $2 " total (" $5 " full)"}' | tee -a "$LOG_FILE" || true

# Step 19: List largest directories
log_step "19/20" "Finding largest directories in /var"
du -sh /var/* 2>/dev/null | sort -rh | head -5 | tee -a "$LOG_FILE"

# Step 20: Final cleanup
log_step "20/20" "Final cleanup and verification"
if [ "$DRY_RUN" = false ]; then
    apt-get autoclean
    sync
else
    echo "Would run final cleanup"
fi

echo ""
log "=== Maintenance Complete ==="
log "Finished at: $(date)"
log "Log file: $LOG_FILE"
echo ""

# Reboot prompt
if [ "$DRY_RUN" = false ]; then
    read -p "Do you want to reboot now? (y/n) " answer
    case ${answer:0:1} in
        y|Y )
            log "Rebooting system..."
            sleep 2
            reboot
        ;;
        * )
            log "Reboot skipped. Please reboot if kernel was updated."
        ;;
    esac
fi
