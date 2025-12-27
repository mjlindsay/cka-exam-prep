#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if swap is currently enabled
if ! swapon --show | grep -q .; then
    echo "Swap is already disabled. No action needed."
    exit 0
fi

echo "Disabling all active swap..."
# Turn off all current swap areas
swapoff -a
echo "Active swap disabled temporarily."

echo "Commenting out all swap entries in /etc/fstab to prevent activation on boot..."
# Use sed to comment out lines containing the word "swap" in /etc/fstab
# The pattern ensures only lines related to swap partitions or files are affected
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab
echo "Entries in /etc/fstab updated. Original file backed up to /etc/fstab.bak."

# Optional: If your system uses dphys-swapfile (common in Raspberry Pi OS, a Debian fork)
# you might want to stop and purge it. This might not be installed on standard Debian.
if dpkg -l | grep -qw dphys-swapfile; then
    echo "Removing dphys-swapfile package..."
    apt-get purge -y dphys-swapfile
fi

# Optional: Remove the physical swap file if one was used (common in modern Debian/Ubuntu)
# First, identify the swap file path if it was used (e.g., /swapfile)
SWAPFILE_PATH=$(grep '^#' /etc/fstab.bak | grep 'swap' | awk '{print $1}')
if [ -f "$SWAPFILE_PATH" ]; then
    echo "Removing swap file: $SWAPFILE_PATH"
    rm "$SWAPFILE_PATH"
fi

echo "Swap has been permanently disabled. A system reboot is recommended for changes to take full effect."

reboot
