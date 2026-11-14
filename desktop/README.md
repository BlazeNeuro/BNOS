# BNOS Desktop Shell (`bnos-shell`)

The official desktop shell for BNOS, built with **Qt 6 + QML** and backed by C++.

## Screens & Components

- **`Shell.qml`**: Master shell orchestrator managing desktop wallpaper, layer-shell integration, keyboard shortcuts (Super, Ctrl+Alt+L, Esc).
- **`Panel.qml`**: Top/bottom status bar and dock with workspace switcher, time/date, battery, volume, network indicators, launcher trigger, and notifications button.
- **`Launcher.qml`**: Application launcher with live search input, categories, recent/pinned applications, and system power actions.
- **`ControlCenter.qml`**: Quick settings overlay for Wi-Fi, Bluetooth, Dark/Light theme toggle, Night Light, Volume & Brightness sliders.
- **`NotificationCenter.qml`**: Drawer with system notifications, Do Not Disturb mode, and clear-all actions.
- **`LockScreen.qml`**: Lock & login screen with large typography clock, user credentials, and password unlock.
- **`SettingsApp.qml`**: System settings application covering About BNOS (specs, licences), Appearance, Display, Network, Sound, and Power.

## Building & Running

```bash
# Build binary
cmake -B build -S .
cmake --build build -j$(nproc)

# Run shell
./build/desktop/bnos-shell
```
