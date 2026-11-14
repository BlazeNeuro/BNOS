import QtQuick
import QtQuick.Layouts
import "../../design-system/bnos-ui"

Rectangle {
    id: root

    height: 48
    color: Theme.glassBackground
    border.width: 1
    border.color: Theme.glassBorder

    signal launcherClicked()
    signal controlCenterClicked()
    signal notificationsClicked()
    signal settingsClicked()

    property int activeWorkspace: 1
    property int batteryLevel: (typeof PowerManager !== "undefined") ? PowerManager.batteryPercentage : 85
    property bool wifiConnected: (typeof NetworkManager !== "undefined") ? NetworkManager.connected : true
    property int volumeLevel: (typeof AudioController !== "undefined") ? AudioController.volume : 70
    property int unreadNotifications: 3

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        // --- Left: Brand & Launcher Button ---
        RowLayout {
            spacing: 8

            Rectangle {
                width: 36
                height: 36
                radius: Theme.radiusMd
                color: launcherMouse.containsMouse ? Theme.accent : "transparent"

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    BIcon {
                        name: "fire"
                        size: 20
                        color: Theme.brandPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: launcherMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.launcherClicked()
                }
            }

            // Workspaces
            Row {
                spacing: 4

                Repeater {
                    model: [1, 2, 3, 4]

                    Rectangle {
                        width: 28
                        height: 28
                        radius: Theme.radiusSm
                        color: modelData === root.activeWorkspace ? Theme.primary :
                               wsMouse.containsMouse ? Theme.accent : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSm
                            font.weight: modelData === root.activeWorkspace ? Font.Bold : Font.Normal
                            color: modelData === root.activeWorkspace ? Theme.primaryForeground : Theme.mutedForeground
                        }

                        MouseArea {
                            id: wsMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activeWorkspace = modelData
                        }
                    }
                }
            }
        }

        // --- Center: Clock & Date ---
        Item {
            Layout.fillWidth: true
            height: parent.height

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    id: timeText
                    text: Qt.formatTime(new Date(), "hh:mm AP")
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSm
                    font.weight: Font.SemiBold
                    color: Theme.foreground
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "•"
                    color: Theme.mutedForeground
                    font.pixelSize: Theme.fontXs
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: dateText
                    text: Qt.formatDate(new Date(), "ddd, MMM d")
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSm
                    color: Theme.mutedForeground
                    anchors.verticalCenter: parent.verticalCenter
                }

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        timeText.text = Qt.formatTime(new Date(), "hh:mm AP")
                        dateText.text = Qt.formatDate(new Date(), "ddd, MMM d")
                    }
                }
            }
        }

        // --- Right: System Status & Triggers ---
        RowLayout {
            spacing: 6

            // Network icon
            Rectangle {
                width: 32
                height: 32
                radius: Theme.radiusSm
                color: netMouse.containsMouse ? Theme.accent : "transparent"

                BIcon {
                    anchors.centerIn: parent
                    name: "wifi"
                    size: 16
                    color: root.wifiConnected ? Theme.foreground : Theme.mutedForeground
                }

                MouseArea {
                    id: netMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.controlCenterClicked()
                }
            }

            // Volume icon
            Rectangle {
                width: 32
                height: 32
                radius: Theme.radiusSm
                color: volMouse.containsMouse ? Theme.accent : "transparent"

                BIcon {
                    anchors.centerIn: parent
                    name: "volume"
                    size: 16
                    color: Theme.foreground
                }

                MouseArea {
                    id: volMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.controlCenterClicked()
                }
            }

            // Battery
            Rectangle {
                width: 52
                height: 32
                radius: Theme.radiusSm
                color: batMouse.containsMouse ? Theme.accent : "transparent"

                Row {
                    anchors.centerIn: parent
                    spacing: 4

                    BIcon {
                        name: "battery"
                        size: 16
                        color: Theme.foreground
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.batteryLevel + "%"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontXs
                        color: Theme.foreground
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: batMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.controlCenterClicked()
                }
            }

            // Theme toggle (Dark / Light)
            Rectangle {
                width: 32
                height: 32
                radius: Theme.radiusSm
                color: themeMouse.containsMouse ? Theme.accent : "transparent"

                BIcon {
                    anchors.centerIn: parent
                    name: Theme.isDark ? "sun" : "moon"
                    size: 16
                    color: Theme.foreground
                }

                MouseArea {
                    id: themeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Theme.toggleTheme()
                }
            }

            // Notifications
            Rectangle {
                width: 32
                height: 32
                radius: Theme.radiusSm
                color: notifMouse.containsMouse ? Theme.accent : "transparent"

                BIcon {
                    anchors.centerIn: parent
                    name: "bell"
                    size: 16
                    color: Theme.foreground
                }

                // Unread dot
                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: Theme.brandPrimary
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 4
                    visible: root.unreadNotifications > 0
                }

                MouseArea {
                    id: notifMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.notificationsClicked()
                }
            }
        }
    }
}
