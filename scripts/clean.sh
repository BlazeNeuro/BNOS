#!/usr/bin/env bash
# BNOS Build Cleaner
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$PROJECT_ROOT/distribution"
BUILD_DIR="${BUILD_DIR:-/media/ankit/ARCH_ROOT/BNOS-build}"

echo "=== BNOS Build Cleaner ==="

if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo: sudo ./scripts/clean.sh"
    exit 1
fi

# Clean SSD build area
if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning SSD build area at $BUILD_DIR..."
    cd "$BUILD_DIR"
    lb clean --purge 2>/dev/null || true
    rm -rf config/binary config/bootstrap config/chroot config/common config/source
    rm -f build.log
    rm -f *.iso *.hybrid.iso *.contents *.files *.packages
fi

# Clean local build output
rm -rf "$PROJECT_ROOT/build"

echo ""
echo "Clean complete. SSD space reclaimed:"
df -h "$BUILD_DIR" 2>/dev/null | tail -1 || echo "(SSD not mounted)"
