#!/usr/bin/env bash
# BNOS VM Launcher — boots an ISO in QEMU
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# --- Defaults ---
RAM="2048"
CPUS="2"
UEFI=false
ISO_FILE=""

# --- Parse arguments ---
usage() {
    echo "Usage: $0 [OPTIONS] <iso-file>"
    echo ""
    echo "Options:"
    echo "  --ram SIZE      RAM in MB (default: 2048)"
    echo "  --cpus N        Number of CPUs (default: 2)"
    echo "  --uefi          Boot in UEFI mode (requires OVMF)"
    echo "  -h, --help      Show this help"
    exit 0
}

while [ $# -gt 0 ]; do
    case "$1" in
        --ram)  RAM="$2"; shift 2 ;;
        --cpus) CPUS="$2"; shift 2 ;;
        --uefi) UEFI=true; shift ;;
        -h|--help) usage ;;
        *)
            if [ -z "$ISO_FILE" ]; then
                ISO_FILE="$1"
            else
                echo "ERROR: Unknown argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# --- Find ISO ---
if [ -z "$ISO_FILE" ]; then
    # Try to find the most recent ISO in build/, distribution/, or SSD tmp/
    ISO_FILE=$(ls -1t "$PROJECT_ROOT"/build/*.iso 2>/dev/null | head -1)
    if [ -z "$ISO_FILE" ]; then
        ISO_FILE=$(ls -1t /media/ankit/ARCH_ROOT/tmp/bnos-iso/*.iso 2>/dev/null | head -1)
    fi
    if [ -z "$ISO_FILE" ]; then
        ISO_FILE=$(ls -1t "$PROJECT_ROOT"/distribution/*.iso 2>/dev/null | head -1)
    fi
    if [ -z "$ISO_FILE" ]; then
        echo "ERROR: No ISO file specified and none found in build/ or distribution/"
        echo "Build one first: sudo ./scripts/build-iso.sh"
        exit 1
    fi
    echo "Auto-detected ISO: $ISO_FILE"
fi

if [ ! -f "$ISO_FILE" ]; then
    echo "ERROR: ISO file not found: $ISO_FILE"
    exit 1
fi

# --- Detect KVM ---
KVM_FLAG=""
if [ -e /dev/kvm ]; then
    KVM_FLAG="-enable-kvm"
    echo "[✓] KVM acceleration available"
else
    echo "[!] KVM not available — VM will run in software emulation (slow)"
    echo "    Try: sudo modprobe kvm_amd  (or kvm_intel)"
fi

# --- Build QEMU command ---
rm -f /tmp/qemu-monitor.sock
QEMU_CMD="qemu-system-x86_64"
QEMU_ARGS=(
    $KVM_FLAG
    -m "$RAM"
    -smp "$CPUS"
    -cdrom "$ISO_FILE"
    -boot d
    -display gtk,gl=on
    -device virtio-vga-gl
    -device virtio-net-pci,netdev=net0
    -netdev user,id=net0
    -device intel-hda
    -device hda-duplex
    -usb
    -device usb-tablet
    -monitor unix:/tmp/qemu-monitor.sock,server,nowait
)

# --- UEFI firmware ---
if [ "$UEFI" = true ]; then
    OVMF_CODE="/usr/share/OVMF/OVMF_CODE_4M.fd"
    OVMF_VARS="/usr/share/OVMF/OVMF_VARS_4M.fd"

    if [ ! -f "$OVMF_CODE" ]; then
        echo "ERROR: OVMF not found. Install with: sudo apt install ovmf"
        exit 1
    fi

    # Copy VARS so UEFI state is per-VM
    VARS_COPY="$PROJECT_ROOT/build/ovmf_vars_bnos.fd"
    mkdir -p "$PROJECT_ROOT/build"
    cp "$OVMF_VARS" "$VARS_COPY"

    QEMU_ARGS+=(
        -drive "if=pflash,format=raw,readonly=on,file=$OVMF_CODE"
        -drive "if=pflash,format=raw,file=$VARS_COPY"
    )
    echo "[✓] UEFI mode enabled"
fi

echo ""
echo "╔══════════════════════════════════════╗"
echo "║       BNOS VM Launcher               ║"
echo "╚══════════════════════════════════════╝"
echo "ISO:  $ISO_FILE"
echo "RAM:  ${RAM}MB | CPUs: $CPUS"
echo "Mode: $([ "$UEFI" = true ] && echo "UEFI" || echo "BIOS")"
echo ""
echo "Starting QEMU..."

exec $QEMU_CMD "${QEMU_ARGS[@]}"
