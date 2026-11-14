import QtQuick
import QtQuick.Layouts
import "../../design-system/bnos-ui"

Item {
    id: root

    property bool open: false
    signal closeRequested()
    signal settingsRequested()
    signal lockRequested()
    signal powerRequested()

    property bool wifiEnabled: true
    property bool bluetoothEnabled: false
    property bool nightLightEnabled: false
    property bool dndEnabled: false

    property int volumeValue: (typeof AudioController !== "undefined") ? AudioController.volume : 70
    property int brightnessValue: 85

    anchors.fill: parent
    visible: opacity > 0
    opacity: open ? 1.0 : 0.0

    Behavior on opacity { NumberAnimation { duration: Theme.animBase } }

    // Click outside to dismiss
    MouseArea {
        anchors.fill: parent
        onClicked: root.closeRequested()
    }

    // Card Popover anchored to top right
    Rectangle {
        id: card
        width: 360
        height: contentCol.implicitHeight + 36
        anchors.top: parent.top
        anchors.topMargin: 56
        anchors.right: parent.right
        anchors.rightMargin: 16
        radius: Theme.radiusXl
        color: Theme.popover
        border.width: 1
        border.color: Theme.border

        scale: root.open ? 1.0 : 0.95
        Behavior on scale { NumberAnimation { duration: Theme.animBase; easing.type: Easing.OutQuad } }

        ColumnLayout {
            id: contentCol
            anchors.fill: parent
            anchors.margins: 18
            spacing: 16

            // Header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Control Center"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBase
                    font.weight: Font.SemiBold
                    color: Theme.foreground
                }

                Item { Layout.fillWidth: true }

                BButton {
                    variant: "ghost"
                    size: "icon"
                    iconName: "settings"
                    onClicked: {
                        root.closeRequested()
                        root.settingsRequested()
                    }
                }
            }

            BSeparator { Layout.fillWidth: true }

            // 2x2 Quick Action Tiles
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                // Wi-Fi Tile
                Rectangle {
                    Layout.fillWidth: true
                    height: 54
                    radius: Theme.radiusMd
                    color: root.wifiEnabled ? Theme.primary : Theme.card
                    border.width: 1
                    border.color: Theme.border

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        BIcon {
                            name: "wifi"
                            size: 18
                            color: root.wifiEnabled ? Theme.primaryForeground : Theme.mutedForeground
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: "Wi-Fi"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSm
                                font.weight: Font.Medium
                                color: root.wifiEnabled ? Theme.primaryForeground : Theme.foreground
                            }
                            Text {
                                text: root.wifiEnabled ? "BlazeNet_5G" : "Disconnected"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontXs
                                color: root.wifiEnabled ? Qt.darker(Theme.primaryForeground, 1.2) : Theme.mutedForeground
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.wifiEnabled = !root.wifiEnabled
                    }
                }

                // Bluetooth Tile
                Rectangle {
                    Layout.fillWidth: true
                    height: 54
                    radius: Theme.radiusMd
                    color: root.bluetoothEnabled ? Theme.primary : Theme.card
                    border.width: 1
                    border.color: Theme.border

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        BIcon {
                            name: "cpu"
                            size: 18
                            color: root.bluetoothEnabled ? Theme.primaryForeground : Theme.mutedForeground
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: "Bluetooth"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSm
                                font.weight: Font.Medium
                                color: root.bluetoothEnabled ? Theme.primaryForeground : Theme.foreground
                            }
                            Text {
                                text: root.bluetoothEnabled ? "Active" : "Off"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontXs
                                color: root.bluetoothEnabled ? Qt.darker(Theme.primaryForeground, 1.2) : Theme.mutedForeground
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.bluetoothEnabled = !root.bluetoothEnabled
                    }
                }

                // Dark/Light Mode Tile
                Rectangle {
                    Layout.fillWidth: true
                    height: 54
                    radius: Theme.radiusMd
                    color: Theme.card
                    border.width: 1
                    border.color: Theme.border

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        BIcon {
                            name: Theme.isDark ? "moon" : "sun"
                            size: 18
                            color: Theme.foreground
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: Theme.isDark ? "Dark Theme" : "Light Theme"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSm
                                font.weight: Font.Medium
                                color: Theme.foreground
                            }
                            Text {
                                text: "shadcn/ui zinc"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontXs
                                color: Theme.mutedForeground
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Theme.toggleTheme()
                    }
                }

                // Night Light Tile
                Rectangle {
                    Layout.fillWidth: true
                    height: 54
                    radius: Theme.radiusMd
                    color: root.nightLightEnabled ? Theme.primary : Theme.card
                    border.width: 1
                    border.color: Theme.border

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        BIcon {
                            name: "sun"
                            size: 18
                            color: root.nightLightEnabled ? Theme.primaryForeground : Theme.mutedForeground
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: "Night Light"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSm
                                font.weight: Font.Medium
                                color: root.nightLightEnabled ? Theme.primaryForeground : Theme.foreground
                            }
                            Text {
                                text: root.nightLightEnabled ? "Warm (3400K)" : "Off"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontXs
                                color: root.nightLightEnabled ? Qt.darker(Theme.primaryForeground, 1.2) : Theme.mutedForeground
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.nightLightEnabled = !root.nightLightEnabled
                    }
                }
            }

            // Volume Slider Control
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Volume"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontXs
                        color: Theme.mutedForeground
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: root.volumeValue + "%"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontXs
                        font.weight: Font.Medium
                        color: Theme.foreground
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: Theme.radiusSm
                    color: Theme.card
                    border.width: 1
                    border.color: Theme.border

                    Rectangle {
                        height: parent.height
                        width: parent.width * (root.volumeValue / 100.0)
                        radius: Theme.radiusSm
                        color: Theme.primary
                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        BIcon {
                            name: "volume"
                            size: 14
                            color: root.volumeValue > 15 ? Theme.primaryForeground : Theme.foreground
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPositionChanged: {
                            if (pressed) {
                                var v = Math.round((mouse.x / width) * 100)
                                root.volumeValue = Math.max(0, Math.min(100, v))
                            }
                        }
                        onClicked: {
                            var v = Math.round((mouse.x / width) * 100)
                            root.volumeValue = Math.max(0, Math.min(100, v))
                        }
                    }
                }
            }

            // Brightness Slider Control
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Display Brightness"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontXs
                        color: Theme.mutedForeground
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: root.brightnessValue + "%"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontXs
                        font.weight: Font.Medium
                        color: Theme.foreground
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: Theme.radiusSm
                    color: Theme.card
                    border.width: 1
                    border.color: Theme.border

                    Rectangle {
                        height: parent.height
                        width: parent.width * (root.brightnessValue / 100.0)
                        radius: Theme.radiusSm
                        color: Theme.brandPrimary
                    }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        BIcon {
                            name: "sun"
                            size: 14
                            color: "#ffffff"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPositionChanged: {
                            if (pressed) {
                                var v = Math.round((mouse.x / width) * 100)
                                root.brightnessValue = Math.max(10, Math.min(100, v))
                            }
                        }
                        onClicked: {
                            var v = Math.round((mouse.x / width) * 100)
                            root.brightnessValue = Math.max(10, Math.min(100, v))
                        }
                    }
                }
            }

            BSeparator { Layout.fillWidth: true }

            // Footer Power / Lock
            RowLayout {
                Layout.fillWidth: true

                BButton {
                    variant: "ghost"
                    size: "sm"
                    iconName: "lock"
                    text: "Lock Screen"
                    onClicked: {
                        root.closeRequested()
                        root.lockRequested()
                    }
                }

                Item { Layout.fillWidth: true }

                BButton {
                    variant: "destructive"
                    size: "sm"
                    iconName: "power"
                    text: "Power"
                    onClicked: {
                        root.closeRequested()
                        root.powerRequested()
                    }
                }
            }
        }
    }
}
