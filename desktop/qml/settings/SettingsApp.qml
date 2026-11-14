import QtQuick
import QtQuick.Layouts
import "../../design-system/bnos-ui"

Rectangle {
    id: root

    property string currentSection: "about"
    signal closeRequested()

    width: 860
    height: 580
    radius: Theme.radiusXl
    color: Theme.card
    border.width: 1
    border.color: Theme.border
    clip: true

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ================= Sidebar =================
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 220
            color: Theme.surface
            border.width: 1
            border.color: Theme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    BIcon {
                        name: "settings"
                        size: 20
                        color: Theme.brandPrimary
                    }

                    Text {
                        text: "Settings"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontLg
                        font.weight: Font.Bold
                        color: Theme.foreground
                    }
                }

                BSeparator { Layout.fillWidth: true }

                // Nav Items
                Column {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: [
                            { id: "about", name: "About BNOS", icon: "info" },
                            { id: "appearance", name: "Appearance", icon: "sun" },
                            { id: "display", name: "Display", icon: "monitor" },
                            { id: "network", name: "Network", icon: "wifi" },
                            { id: "sound", name: "Sound", icon: "volume" },
                            { id: "power", name: "Power", icon: "battery" }
                        ]

                        Rectangle {
                            width: 188
                            height: 36
                            radius: Theme.radiusMd
                            color: root.currentSection === modelData.id ? Theme.accent :
                                   navMouse.containsMouse ? Qt.darker(Theme.surface, 1.05) : "transparent"

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                spacing: 10

                                BIcon {
                                    name: modelData.icon
                                    size: 16
                                    color: root.currentSection === modelData.id ? Theme.brandPrimary : Theme.mutedForeground
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData.name
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSm
                                    font.weight: root.currentSection === modelData.id ? Font.SemiBold : Font.Normal
                                    color: root.currentSection === modelData.id ? Theme.foreground : Theme.mutedForeground
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: navMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.currentSection = modelData.id
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Close Button
                BButton {
                    Layout.fillWidth: true
                    variant: "outline"
                    size: "sm"
                    text: "Close Settings"
                    onClicked: root.closeRequested()
                }
            }
        }

        // ================= Content Area =================
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.background

            Flickable {
                anchors.fill: parent
                anchors.margins: 28
                contentHeight: contentColumn.implicitHeight
                clip: true

                ColumnLayout {
                    id: contentColumn
                    width: parent.width
                    spacing: 24

                    // ---------- Section: About BNOS ----------
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        visible: root.currentSection === "about"

                        RowLayout {
                            spacing: 16
                            Rectangle {
                                width: 56
                                height: 56
                                radius: Theme.radiusLg
                                color: Theme.card
                                border.width: 1
                                border.color: Theme.border

                                BIcon {
                                    anchors.centerIn: parent
                                    name: "fire"
                                    size: 32
                                    color: Theme.brandPrimary
                                }
                            }

                            Column {
                                Text {
                                    text: "BlazeNeuro Operating System (BNOS)"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontXl
                                    font.weight: Font.Bold
                                    color: Theme.foreground
                                }
                                Text {
                                    text: "Version 1.0 (Debian Trixie) • x86_64"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSm
                                    color: Theme.mutedForeground
                                }
                            }
                        }

                        BCard {
                            Layout.fillWidth: true
                            title: "System Information"
                            description: "Core architecture and distribution details."

                            ColumnLayout {
                                width: parent.width
                                spacing: 8

                                RowLayout {
                                    Text { text: "Distribution:"; color: Theme.mutedForeground; font.pixelSize: Theme.fontSm; Layout.preferredWidth: 140 }
                                    Text { text: "Debian 13 (Trixie) Stable"; color: Theme.foreground; font.pixelSize: Theme.fontSm; font.weight: Font.Medium }
                                }
                                RowLayout {
                                    Text { text: "Kernel:"; color: Theme.mutedForeground; font.pixelSize: Theme.fontSm; Layout.preferredWidth: 140 }
                                    Text { text: (typeof SystemManager !== "undefined") ? SystemManager.kernelVersion : "Linux 6.x"; color: Theme.foreground; font.pixelSize: Theme.fontSm; font.weight: Font.Medium }
                                }
                                RowLayout {
                                    Text { text: "Uptime:"; color: Theme.mutedForeground; font.pixelSize: Theme.fontSm; Layout.preferredWidth: 140 }
                                    Text { text: (typeof SystemManager !== "undefined") ? SystemManager.uptimeString : "0m"; color: Theme.foreground; font.pixelSize: Theme.fontSm; font.weight: Font.Medium }
                                }
                                RowLayout {
                                    Text { text: "Desktop Shell:"; color: Theme.mutedForeground; font.pixelSize: Theme.fontSm; Layout.preferredWidth: 140 }
                                    Text { text: "BNOS Shell (Qt 6.4+ / QML)"; color: Theme.foreground; font.pixelSize: Theme.fontSm; font.weight: Font.Medium }
                                }
                                RowLayout {
                                    Text { text: "Compositor:"; color: Theme.mutedForeground; font.pixelSize: Theme.fontSm; Layout.preferredWidth: 140 }
                                    Text { text: "QtWayland Compositor (Wayland)"; color: Theme.foreground; font.pixelSize: Theme.fontSm; font.weight: Font.Medium }
                                }
                                RowLayout {
                                    Text { text: "System Services:"; color: Theme.mutedForeground; font.pixelSize: Theme.fontSm; Layout.preferredWidth: 140 }
                                    Text { text: "os-core Rust Services (D-Bus / zbus)"; color: Theme.foreground; font.pixelSize: Theme.fontSm; font.weight: Font.Medium }
                                }
                            }
                        }

                        BCard {
                            Layout.fillWidth: true
                            title: "Attribution & Licences"
                            description: "Open source components and creative assets."

                            ColumnLayout {
                                width: parent.width
                                spacing: 8

                                Text {
                                    text: "• Solar Icons by 480 Design (solar-icons.dev) licensed under Creative Commons Attribution 4.0 International (CC BY 4.0)."
                                    color: Theme.mutedForeground
                                    font.pixelSize: Theme.fontSm
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "• shadcn/ui design reference (shadcn.com) ported natively to Qt 6 QML."
                                    color: Theme.mutedForeground
                                    font.pixelSize: Theme.fontSm
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "• Debian GNU/Linux (debian.org) base operating system."
                                    color: Theme.mutedForeground
                                    font.pixelSize: Theme.fontSm
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }

                    // ---------- Section: Appearance ----------
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        visible: root.currentSection === "appearance"

                        Text {
                            text: "Appearance & Theme"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontXl
                            font.weight: Font.Bold
                            color: Theme.foreground
                        }

                        BCard {
                            Layout.fillWidth: true
                            title: "Color Theme"
                            description: "Select light or dark shadcn/ui zinc-slate palette."

                            RowLayout {
                                width: parent.width
                                spacing: 16

                                Rectangle {
                                    Layout.preferredWidth: 140
                                    height: 80
                                    radius: Theme.radiusMd
                                    color: "#18181b"
                                    border.width: Theme.isDark ? 2 : 1
                                    border.color: Theme.isDark ? Theme.brandPrimary : Theme.border

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        BIcon { name: "moon"; size: 20; color: "#fafafa"; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: "Dark Mode"; color: "#fafafa"; font.pixelSize: Theme.fontSm; font.weight: Font.Medium }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Theme.isDark = true
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 140
                                    height: 80
                                    radius: Theme.radiusMd
                                    color: "#ffffff"
                                    border.width: !Theme.isDark ? 2 : 1
                                    border.color: !Theme.isDark ? Theme.brandPrimary : Theme.border

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        BIcon { name: "sun"; size: 20; color: "#18181b"; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: "Light Mode"; color: "#18181b"; font.pixelSize: Theme.fontSm; font.weight: Font.Medium }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Theme.isDark = false
                                    }
                                }
                            }
                        }

                        BCard {
                            Layout.fillWidth: true
                            title: "UI Preview & Tokens"
                            description: "Real-time components following Theme singleton."

                            RowLayout {
                                width: parent.width
                                spacing: 12

                                BButton { text: "Default"; variant: "default" }
                                BButton { text: "Secondary"; variant: "secondary" }
                                BButton { text: "Outline"; variant: "outline" }
                                BButton { text: "Destructive"; variant: "destructive" }
                                BSwitch { checked: true }
                                BCheckbox { checked: true }
                            }
                        }
                    }

                    // ---------- Section: Display ----------
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        visible: root.currentSection === "display"

                        Text {
                            text: "Display Configuration"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontXl
                            font.weight: Font.Bold
                            color: Theme.foreground
                        }

                        BCard {
                            Layout.fillWidth: true
                            title: "Active Display (Wayland)"
                            description: "Output configuration managed by compositor."

                            ColumnLayout {
                                width: parent.width
                                spacing: 10

                                RowLayout {
                                    Text { text: "Resolution:"; color: Theme.mutedForeground; font.pixelSize: Theme.fontSm; Layout.preferredWidth: 140 }
                                    Text { text: "1920 x 1080 (16:9)"; color: Theme.foreground; font.pixelSize: Theme.fontSm; font.weight: Font.Medium }
                                }
                                RowLayout {
                                    Text { text: "Refresh Rate:"; color: Theme.mutedForeground; font.pixelSize: Theme.fontSm; Layout.preferredWidth: 140 }
                                    Text { text: "60.00 Hz"; color: Theme.foreground; font.pixelSize: Theme.fontSm; font.weight: Font.Medium }
                                }
                                RowLayout {
                                    Text { text: "Scale Factor:"; color: Theme.mutedForeground; font.pixelSize: Theme.fontSm; Layout.preferredWidth: 140 }
                                    Text { text: "100% (1.0x)"; color: Theme.foreground; font.pixelSize: Theme.fontSm; font.weight: Font.Medium }
                                }
                            }
                        }
                    }

                    // ---------- Section: Network ----------
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        visible: root.currentSection === "network"

                        Text {
                            text: "Network & Connectivity"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontXl
                            font.weight: Font.Bold
                            color: Theme.foreground
                        }

                        BCard {
                            Layout.fillWidth: true
                            title: "Wi-Fi (NetworkManager)"
                            description: "Managed via os-core D-Bus wrapper."

                            RowLayout {
                                width: parent.width

                                Column {
                                    Text { text: "Connected: BlazeNet_5G"; color: Theme.foreground; font.pixelSize: Theme.fontSm; font.weight: Font.SemiBold }
                                    Text { text: "IPv4: 192.168.1.104 • Signal: 92%"; color: Theme.mutedForeground; font.pixelSize: Theme.fontXs }
                                }

                                Item { Layout.fillWidth: true }

                                BBadge { text: "Connected"; variant: "default" }
                            }
                        }
                    }

                    // ---------- Section: Sound ----------
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        visible: root.currentSection === "sound"

                        Text {
                            text: "Sound & Audio (PipeWire)"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontXl
                            font.weight: Font.Bold
                            color: Theme.foreground
                        }

                        BCard {
                            Layout.fillWidth: true
                            title: "Output Device"
                            description: "Default sink via PipeWire PulseAudio layer."

                            Text {
                                text: "Built-in Audio / HD Audio Controller Stereo"
                                color: Theme.foreground
                                font.pixelSize: Theme.fontSm
                                font.weight: Font.Medium
                            }
                        }
                    }

                    // ---------- Section: Power ----------
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        visible: root.currentSection === "power"

                        Text {
                            text: "Power & Battery (UPower)"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontXl
                            font.weight: Font.Bold
                            color: Theme.foreground
                        }

                        BCard {
                            Layout.fillWidth: true
                            title: "Battery Health"
                            description: "System power supply status."

                            RowLayout {
                                width: parent.width
                                Column {
                                    Text { text: "Battery: 85% Remaining"; color: Theme.foreground; font.pixelSize: Theme.fontSm; font.weight: Font.SemiBold }
                                    Text { text: "Estimated time: 4 hours 12 minutes"; color: Theme.mutedForeground; font.pixelSize: Theme.fontXs }
                                }
                                Item { Layout.fillWidth: true }
                                BBadge { text: "Good"; variant: "secondary" }
                            }
                        }
                    }
                }
            }
        }
    }
}
