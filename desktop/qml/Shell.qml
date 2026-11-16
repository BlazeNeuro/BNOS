import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../design-system/bnos-ui"
import "panel"
import "dock"
import "launcher"
import "controlcenter"
import "notifications"
import "lockscreen"
import "settings"
import "../../apps/bnos-files/qml"
import "../../apps/bnos-store/qml"

Rectangle {
    id: root

    width: 1280
    height: 800
    color: Theme.background
    focus: true

    // State properties
    property bool launcherOpen: false
    property bool controlCenterOpen: false
    property bool notificationsOpen: false
    property bool settingsOpen: false
    property bool filesOpen: false
    property bool storeOpen: false
    property bool isLocked: false

    // ================= Desktop Wallpaper Background =================
    Rectangle {
        id: wallpaper
        anchors.fill: parent
        color: Theme.background

        // Subtle gradient background
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.isDark ? "#0f0f12" : "#f1f5f9" }
            GradientStop { position: 1.0; color: Theme.isDark ? "#050507" : "#e2e8f0" }
        }

        // Ambient Flame Glow in background
        Rectangle {
            width: 700
            height: 700
            radius: 350
            anchors.centerIn: parent
            color: Theme.brandPrimary
            opacity: Theme.isDark ? 0.035 : 0.02
        }

        // Desktop Center Watermark (Solar Fire Icon)
        Column {
            anchors.centerIn: parent
            spacing: 12
            opacity: 0.25

            BIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                name: "fire"
                size: 72
                color: Theme.foreground
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "BNOS"
                font.family: Theme.fontFamily
                font.pixelSize: 22
                font.weight: Font.Bold
                font.letterSpacing: 4
                color: Theme.foreground
            }
        }
    }

    // ================= Top Panel =================
    Panel {
        id: topPanel
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        onLauncherClicked: {
            root.controlCenterOpen = false
            root.notificationsOpen = false
            root.launcherOpen = !root.launcherOpen
        }

        onControlCenterClicked: {
            root.launcherOpen = false
            root.notificationsOpen = false
            root.controlCenterOpen = !root.controlCenterOpen
        }

        onNotificationsClicked: {
            root.launcherOpen = false
            root.controlCenterOpen = false
            root.notificationsOpen = !root.notificationsOpen
        }
    }

    // ================= Running App Window: Settings Window =================
    Rectangle {
        id: settingsWindowContainer
        anchors.centerIn: parent
        width: Math.min(parent.width - 60, 880)
        height: Math.min(parent.height - 100, 600)
        radius: Theme.radiusXl
        color: "transparent"
        visible: root.settingsOpen && !root.isLocked

        SettingsApp {
            anchors.fill: parent
            onCloseRequested: root.settingsOpen = false
        }
    }

    // ================= Running App Window: File Manager =================
    Rectangle {
        id: filesWindowContainer
        anchors.centerIn: parent
        width: Math.min(parent.width - 60, 940)
        height: Math.min(parent.height - 100, 620)
        radius: Theme.radiusXl
        color: "transparent"
        visible: root.filesOpen && !root.isLocked

        FileManagerApp {
            anchors.fill: parent
            onCloseRequested: root.filesOpen = false
        }
    }

    // ================= Running App Window: Software Store =================
    Rectangle {
        id: storeWindowContainer
        anchors.centerIn: parent
        width: Math.min(parent.width - 60, 940)
        height: Math.min(parent.height - 100, 620)
        radius: Theme.radiusXl
        color: "transparent"
        visible: root.storeOpen && !root.isLocked

        SoftwareStoreApp {
            anchors.fill: parent
            onCloseRequested: root.storeOpen = false
        }
    }

    // ================= macOS / Ubuntu Style Bottom Dock =================
    Dock {
        id: bottomDock
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        anchors.horizontalCenter: parent.horizontalCenter
        visible: !root.isLocked

        filesRunning: root.filesOpen
        storeRunning: root.storeOpen
        settingsRunning: root.settingsOpen

        onToggleLauncher: {
            root.controlCenterOpen = false
            root.notificationsOpen = false
            root.launcherOpen = !root.launcherOpen
        }
        onOpenFiles: {
            root.filesOpen = true
            root.launcherOpen = false
        }
        onOpenBrowser: {
            toast.show("Web Browser", "Launching Firefox ESR...", "globe")
            if (typeof SystemManager !== "undefined") {
                SystemManager.launchCommand("firefox-esr")
            }
        }
        onOpenStore: {
            root.storeOpen = true
            root.launcherOpen = false
        }
        onOpenTerminal: {
            toast.show("Terminal", "Launching Foot Terminal...", "terminal")
            if (typeof SystemManager !== "undefined") {
                SystemManager.launchCommand("foot")
            }
        }
        onOpenSettings: {
            root.settingsOpen = true
            root.launcherOpen = false
        }
    }

    // ================= Floating Launcher Overlay =================
    Launcher {
        id: launcherOverlay
        open: root.launcherOpen && !root.isLocked
        onCloseRequested: root.launcherOpen = false
        onLockRequested: root.isLocked = true
        onPowerOffRequested: toast.show("Power Off", "Shutdown request dispatched to systemd.", "power")
        onRestartRequested: toast.show("Restart", "Reboot request dispatched to systemd.", "power")
        onAppLaunched: function(appName, cmd) {
            if (cmd === "bnos-settings") {
                root.settingsOpen = true
            } else if (cmd === "bnos-files" || cmd === "thunar") {
                root.filesOpen = true
            } else if (cmd === "bnos-store") {
                root.storeOpen = true
            } else if (typeof SystemManager !== "undefined") {
                SystemManager.launchCommand(cmd)
                toast.show("Launched " + appName, "Command: " + cmd, "terminal")
            } else {
                toast.show("Launched " + appName, "Command: " + cmd, "terminal")
            }
        }
    }

    // ================= Floating Control Center Popover =================
    ControlCenter {
        id: controlCenterOverlay
        open: root.controlCenterOpen && !root.isLocked
        onCloseRequested: root.controlCenterOpen = false
        onSettingsRequested: root.settingsOpen = true
        onLockRequested: root.isLocked = true
        onPowerRequested: toast.show("System Power", "Opening power management dialog...", "power")
    }

    // ================= Floating Notification Drawer =================
    NotificationCenter {
        id: notifCenterOverlay
        open: root.notificationsOpen && !root.isLocked
        onCloseRequested: root.notificationsOpen = false
        onClearAllRequested: toast.show("Notifications", "All notifications cleared.", "check")
    }

    // ================= Lock Screen =================
    LockScreen {
        id: lockScreenOverlay
        locked: root.isLocked
        onUnlocked: root.isLocked = false
        onRestartRequested: toast.show("System", "Rebooting system...", "power")
        onPowerRequested: toast.show("System", "Shutting down system...", "power")
    }

    // ================= Global Toast Notifier =================
    BToast {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 56
    }

    // ================= Keyboard Shortcuts =================
    Keys.onPressed: function(event) {
        // Esc: close active overlays
        if (event.key === Qt.Key_Escape) {
            if (root.launcherOpen) { root.launcherOpen = false; event.accepted = true; return }
            if (root.controlCenterOpen) { root.controlCenterOpen = false; event.accepted = true; return }
            if (root.notificationsOpen) { root.notificationsOpen = false; event.accepted = true; return }
            if (root.settingsOpen) { root.settingsOpen = false; event.accepted = true; return }
            if (root.filesOpen) { root.filesOpen = false; event.accepted = true; return }
            if (root.storeOpen) { root.storeOpen = false; event.accepted = true; return }
        }

        // Ctrl+Alt+L: Lock
        if ((event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.AltModifier) && event.key === Qt.Key_L) {
            root.isLocked = true
            event.accepted = true
            return
        }

        // Super key or F1: Toggle Launcher
        if (event.key === Qt.Key_Super_L || event.key === Qt.Key_F1) {
            root.launcherOpen = !root.launcherOpen
            event.accepted = true
            return
        }
    }
}
