#!/usr/bin/env bash
# BNOS Host Setup — installs all dependencies needed to build the ISO
set -euo pipefail

echo "=== BNOS Host Setup ==="

# Check for root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo: sudo ./scripts/setup-host.sh"
    exit 1
fi

apt-get update

# Core build tools
apt-get install -y \
    live-build \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-common \
    mtools \
    debian-archive-keyring \
    rsync

# VM testing tools
apt-get install -y \
    qemu-system-x86 \
    qemu-utils \
    ovmf

# Optional: KVM acceleration
modprobe kvm_amd 2>/dev/null || modprobe kvm_intel 2>/dev/null || \
    echo "WARNING: Could not load KVM module. VM will run without acceleration."

echo ""
echo "=== Host setup complete ==="
echo "Available disk space:"
df -h / | tail -1
echo ""
echo "IMPORTANT: You need at least 15 GB free on the build drive to build the ISO."
