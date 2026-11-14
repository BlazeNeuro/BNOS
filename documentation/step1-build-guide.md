# Step 1: Build Guide — BNOS Live ISO

## Prerequisites

- **Host OS:** Debian or Ubuntu (tested on Ubuntu 24.04)
- **Disk space:** ≥15 GB free on the build drive (SSD recommended)
- **Internet:** Required for downloading packages during build

## 1. Install Host Dependencies

```bash
sudo ./scripts/setup-host.sh
```

This installs:
- `live-build`, `debootstrap`, `squashfs-tools`, `xorriso` — ISO build tools
- `debian-archive-keyring` — GPG keys for Debian repos
- `qemu-system-x86`, `ovmf` — VM testing tools

## 2. Build the ISO

```bash
sudo ./scripts/build-iso.sh
```

The build script will:
1. Check for required tools and disk space on the SSD
2. Sync configuration from `distribution/` to the SSD build area
3. Run `lb config` to generate the live-build configuration
4. Run `lb build` to create the ISO (10–30 minutes)
5. Copy the finished ISO to `build/`

### Build on a Different Drive

Set the `BUILD_DIR` environment variable:

```bash
sudo BUILD_DIR=/path/to/large/drive/bnos-build ./scripts/build-iso.sh
```

## 3. Test in QEMU

### BIOS mode (default)

```bash
./scripts/run-vm.sh
```

### UEFI mode

```bash
./scripts/run-vm.sh --uefi
```

### Custom settings

```bash
./scripts/run-vm.sh --ram 4096 --cpus 4 path/to/bnos.iso
```

### Enable KVM acceleration

If the VM runs slowly (software emulation):

```bash
# AMD CPU
sudo modprobe kvm_amd

# Intel CPU
sudo modprobe kvm_intel
```

If this fails, enable virtualization (SVM/VT-x) in your BIOS/UEFI settings.

## 4. What You Should See

1. **Boot menu** — syslinux boot screen with "BNOS Live" option
2. **Login prompt** — greetd/agreety on VT7
3. **Credentials** — username: `user`, password: `live`
4. **Desktop** — labwc Wayland compositor (minimal, clean)
5. **Terminal** — foot terminal emulator

### Verify branding

Inside the live session, open a terminal and run:

```bash
cat /etc/os-release    # Should show BNOS, not Debian
cat /etc/lsb-release   # Should show BNOS
neofetch               # Should show BNOS
```

## 5. Clean Up

```bash
sudo ./scripts/clean.sh
```

This removes all build artifacts from the SSD and local `build/` directory.

## Troubleshooting

### GPG / keyring errors during build

```bash
sudo apt install debian-archive-keyring
```

### "No space left on device" during build

Free space on the SSD or set `BUILD_DIR` to a drive with ≥15 GB free.

### QEMU shows black screen

Try without GL acceleration:

```bash
qemu-system-x86_64 -m 2G -cdrom build/*.iso -boot d -display gtk
```

### Build fails with "debootstrap error"

Check `build.log` in the SSD build directory for the exact error.
Usually caused by network issues or missing keyring.

## 6. CI / GitHub Actions

The ISO is also built automatically by GitHub Actions on every push to `main`.
Check the status at: https://github.com/BlazeNeuro/BNOS/actions

To create a release with the ISO attached:

```bash
git tag v0.1.0-alpha
git push origin v0.1.0-alpha
```
