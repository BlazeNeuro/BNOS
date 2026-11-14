# BNOS — BlazeNeuro Operating System

A custom Linux distribution by [BlazeNeuro](https://blazeneuro.com), built on
Debian Stable (Trixie) with a Qt 6/QML desktop environment and Rust system services.

## Status

🚧 **Early development** — Step 1: Bootable baseline ISO

## Quick Start

```bash
# 1. Install host dependencies
sudo ./scripts/setup-host.sh

# 2. Build the ISO (uses SSD as build scratch space)
sudo ./scripts/build-iso.sh

# 3. Test in QEMU
./scripts/run-vm.sh                    # BIOS mode
./scripts/run-vm.sh --uefi             # UEFI mode
```

## Repository Layout

| Directory | Purpose |
|---|---|
| `distribution/` | live-build configuration, package lists, branding overlays |
| `scripts/` | Build, test, and setup automation |
| `branding/` | Logos, icons, and visual assets |
| `os-core/` | Rust system services (D-Bus) — *future* |
| `desktop/` | Qt 6 shell, panel, launcher — *future* |
| `compositor/` | QtWayland Compositor — *future* |
| `design-system/` | bnos-ui QML components, Theme tokens — *future* |
| `themes/` | Token sets, Solar icons, wallpapers — *future* |
| `applications/` | File manager, terminal, etc. — *future* |
| `packaging/` | debian/ directories per component — *future* |
| `documentation/` | Build guides and architecture docs |

## Architecture

- **Base:** Debian Trixie (Stable) + selected backports
- **Desktop:** Qt 6 / QML with C++ backend
- **System services:** Rust with zbus, exposed over D-Bus
- **Compositor:** QtWayland Compositor (Smithay experiment later)
- **Design language:** shadcn/ui-inspired, Solar Icons
- **Packages:** APT / DEB, `bnos-` prefix

## Licence

© BlazeNeuro. Licence TBD.

Solar Icons by 480 Design — CC BY 4.0.
