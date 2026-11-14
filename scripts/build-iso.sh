#!/usr/bin/env bash
# BNOS ISO Builder — uses SSD as build scratch space
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$PROJECT_ROOT/distribution"

# --- SSD build area ---
# Override with BUILD_DIR env var if the SSD is mounted elsewhere
BUILD_DIR="${BUILD_DIR:-/media/ankit/ARCH_ROOT/BNOS-build}"

echo "╔══════════════════════════════════════╗"
echo "║       BNOS ISO Builder v0.1          ║"
echo "║       BlazeNeuro Operating System    ║"
echo "╚══════════════════════════════════════╝"
echo ""

# --- Pre-flight checks ---
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: ISO build requires root. Run with: sudo ./scripts/build-iso.sh"
    exit 1
fi

# Check SSD is mounted
if [ ! -d "$(dirname "$BUILD_DIR")" ]; then
    echo "ERROR: SSD not mounted at $(dirname "$BUILD_DIR")"
    echo "Mount it or set BUILD_DIR to another location with ≥15 GB free."
    exit 1
fi

# Ensure build dir exists for df check
mkdir -p "$BUILD_DIR"

# Check available disk space on SSD (in KB)
AVAIL_KB=$(df --output=avail "$BUILD_DIR" | tail -1 | tr -d ' ')
AVAIL_GB=$((AVAIL_KB / 1048576))
if [ "$AVAIL_GB" -lt 10 ]; then
    echo "ERROR: Only ${AVAIL_GB}GB available on SSD. Need at least 10 GB."
    exit 1
fi
echo "[✓] SSD space: ${AVAIL_GB}GB available at $BUILD_DIR"

# Check for debian-archive-keyring
if [ ! -f /usr/share/keyrings/debian-archive-keyring.gpg ]; then
    echo "ERROR: debian-archive-keyring not installed."
    echo "Run: sudo apt install debian-archive-keyring"
    exit 1
fi
echo "[✓] Debian archive keyring present"

# Check for live-build
if ! command -v lb &> /dev/null; then
    echo "ERROR: live-build not installed."
    echo "Run: sudo ./scripts/setup-host.sh"
    exit 1
fi
echo "[✓] live-build available ($(lb --version))"

echo ""
echo "--- Setting up build area on SSD ---"

# Sync distribution config to SSD build area
rsync -a --delete \
    --exclude='.build' \
    --exclude='chroot' \
    --exclude='binary' \
    --exclude='cache' \
    --exclude='*.iso' \
    --exclude='*.hybrid.iso' \
    --exclude='build.log' \
    "$DIST_DIR/" "$BUILD_DIR/"

echo "[✓] Config synced to $BUILD_DIR"

echo ""
echo "--- Configuring build ---"
cd "$BUILD_DIR"

# Clean any previous build
lb clean 2>/dev/null || true

# Run lb config via auto/config
lb config

echo ""
echo "--- Building ISO (this will take 10-30 minutes) ---"
echo "    Build dir: $BUILD_DIR"
echo "    Log: $BUILD_DIR/build.log"
echo ""

lb build 2>&1 | tee build.log

# Find the output ISO
ISO_FILE=$(ls -1 "$BUILD_DIR"/*.iso 2>/dev/null | head -1)
if [ -n "$ISO_FILE" ]; then
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)

    # Copy ISO back to project output dir
    OUTPUT_DIR="$PROJECT_ROOT/build"
    mkdir -p "$OUTPUT_DIR"
    cp "$ISO_FILE" "$OUTPUT_DIR/"
    OUTPUT_ISO="$OUTPUT_DIR/$(basename "$ISO_FILE")"

    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║       BUILD SUCCESSFUL               ║"
    echo "╚══════════════════════════════════════╝"
    echo "ISO (SSD):    $ISO_FILE ($ISO_SIZE)"
    echo "ISO (copied): $OUTPUT_ISO"
    echo ""
    echo "Test with: ./scripts/run-vm.sh $OUTPUT_ISO"
else
    echo ""
    echo "ERROR: Build completed but no ISO found."
    echo "Check $BUILD_DIR/build.log for errors."
    exit 1
fi
