#!/bin/bash
#
# Ubuntu Basic System Maintenance Script
# Based on: https://github.com/jimmycrisp1/basic-ubuntu-system-maintenance
# Purpose: Quick and safe system cleanup for Ubuntu/Debian systems
#
# Usage: sudo ./ubuntu-maintenance-basic.sh
#

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${GREEN}=== Ubuntu Basic System Maintenance ===${NC}"
echo "Started at: $(date)"
echo ""

# Update package lists
echo -e "${YELLOW}[1/8] Updating package lists...${NC}"
apt-get update

# Upgrade all packages
echo -e "${YELLOW}[2/8] Upgrading installed packages...${NC}"
apt-get upgrade -y

# Dist-Upgrade for handling changed dependencies
echo -e "${YELLOW}[3/8] Performing dist-upgrade...${NC}"
apt-get dist-upgrade -y

# Remove unused packages and their configs
echo -e "${YELLOW}[4/8] Removing unnecessary packages...${NC}"
apt-get autoremove -y

echo -e "${YELLOW}[5/8] Cleaning package cache (autoclean)...${NC}"
apt-get autoclean

echo -e "${YELLOW}[6/8] Cleaning package cache (clean)...${NC}"
apt-get clean

# Remove old kernels (keep current + 1 backup)
echo -e "${YELLOW}[7/8] Removing old kernels (keeping current + 1 backup)...${NC}"
CURRENT_KERNEL=$(uname -r | cut -d"-" -f1,2)
OLD_KERNELS=$(dpkg --list | grep -P -o "linux-(headers|image|modules)-\d+\.\d+\.\d+-\d+" | grep -v "$CURRENT_KERNEL" | sort -u)

if [ -n "$OLD_KERNELS" ]; then
    echo "Old kernels to remove:"
    echo "$OLD_KERNELS"
    apt-get purge -y $OLD_KERNELS || echo "Note: Some kernels may already be removed"
else
    echo "No old kernels to remove."
fi

# Check for broken dependencies
echo -e "${YELLOW}[8/8] Checking for broken dependencies...${NC}"
apt-get check

# Optional: Remove orphaned packages (requires deborphan)
if command -v deborphan &> /dev/null; then
    echo -e "${YELLOW}[OPTIONAL] Removing orphaned packages...${NC}"
    ORPHANS=$(deborphan)
    if [ -n "$ORPHANS" ]; then
        echo "$ORPHANS" | xargs apt-get -y remove --purge
    else
        echo "No orphaned packages found."
    fi
else
    echo -e "${YELLOW}Note: deborphan not installed. Install with: apt-get install deborphan${NC}"
fi

echo ""
echo -e "${GREEN}=== System maintenance complete! ===${NC}"
echo "Finished at: $(date)"
echo ""

# Show disk space savings
df -h / | tail -1 | awk '{print "Disk Usage: " $3 " used / " $2 " total (" $5 " full)"}'

# Optional: Reboot prompt
echo ""
read -p "Do you want to reboot now? (y/n) " answer
case ${answer:0:1} in
    y|Y )
        echo "Rebooting in 5 seconds... (Ctrl+C to cancel)"
        sleep 5
        reboot
    ;;
    * )
        echo "Reboot skipped. Consider rebooting if kernel was updated."
    ;;
esac
