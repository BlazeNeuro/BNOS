# BNOS Distribution — live-build Configuration

This directory contains the [Debian live-build](https://live-team.pages.debian.net/live-manual/)
configuration for building the BNOS live ISO image.

## Structure

```
distribution/
├── auto/
│   ├── config    # lb config invocation (reproducible builds)
│   ├── build     # lb build wrapper
│   └── clean     # lb clean wrapper
├── config/
│   ├── package-lists/
│   │   ├── base.list.chroot      # Core system packages
│   │   └── desktop.list.chroot   # Desktop session packages
│   ├── includes.chroot/
│   │   └── etc/                  # Branding overlay files
│   ├── hooks/
│   │   └── live/                 # Chroot hooks (run during build)
│   └── bootloaders/              # Boot splash and themes (future)
└── README.md
```

## Building

Do not run `lb build` directly in this directory. Use the build script instead:

```bash
sudo ../scripts/build-iso.sh
```

This syncs the config to the SSD build area, builds there, and copies the ISO back.

## Configuration Details

- **Target:** Debian Trixie (Stable), amd64
- **Archive areas:** main, contrib, non-free, non-free-firmware
- **Output:** Hybrid ISO (bootable from USB or CD)
- **Bootloader:** syslinux (BIOS), GRUB EFI support planned
- **Desktop session:** labwc + greetd (temporary, replaced by BNOS shell in Step 3)
