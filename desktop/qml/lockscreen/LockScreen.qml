import QtQuick
import QtQuick.Layouts
import "../../design-system/bnos-ui"

Rectangle {
    id: root

    property bool locked: false
    property string username: "Ankit"
    property string role: "Administrator • BlazeNeuro"

    signal unlocked()
    signal powerRequested()
    signal restartRequested()

    anchors.fill: parent
    color: Theme.background
    visible: opacity > 0
    opacity: locked ? 1.0 : 0.0

    Behavior on opacity { NumberAnimation { duration: Theme.animBase } }

    // Ambient background subtle gradient / glow
    Rectangle {
        width: 480
        height: 480
        radius: 240
        anchors.centerIn: parent
        color: Theme.brandPrimary
        opacity: Theme.isDark ? 0.06 : 0.03
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 32
        width: Math.min(parent.width - 40, 380)

        // Clock & Date Block
        Column {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Text {
                id: clockText
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(new Date(), "hh:mm")
                font.family: Theme.fontFamily
                font.pixelSize: 64
                font.weight: Font.Bold
                color: Theme.foreground
            }

            Text {
                id: fullDateText
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(new Date(), "dddd, MMMM d")
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBase
                color: Theme.mutedForeground
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    clockText.text = Qt.formatTime(new Date(), "hh:mm")
                    fullDateText.text = Qt.formatDate(new Date(), "dddd, MMMM d")
                }
            }
        }

        // User Avatar & Credentials Box
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16

            // Avatar
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 72
                height: 72
                radius: 36
                color: Theme.card
                border.width: 2
                border.color: Theme.border

                BIcon {
                    anchors.centerIn: parent
                    name: "fire"
                    size: 34
                    color: Theme.brandPrimary
                }
            }

            // Name
            Column {
                Layout.alignment: Qt.AlignHCenter
                spacing: 2
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.username
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontLg
                    font.weight: Font.SemiBold
                    color: Theme.foreground
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.role
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontXs
                    color: Theme.mutedForeground
                }
            }

            // Password Input
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                BInput {
                    id: passwordInput
                    Layout.fillWidth: true
                    placeholderText: "Enter password..."
                    iconName: "lock"
                    echoMode: TextInput.Password
                    onAccepted: {
                        root.unlocked()
                        passwordInput.text = ""
                    }
                }

                BButton {
                    variant: "default"
                    size: "default"
                    iconName: "chevron-right"
                    onClicked: {
                        root.unlocked()
                        passwordInput.text = ""
                    }
                }
            }
        }

        // Bottom Power bar
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            BButton {
                variant: "ghost"
                size: "sm"
                iconName: "power"
                text: "Restart"
                onClicked: root.restartRequested()
            }

            BButton {
                variant: "ghost"
                size: "sm"
                iconName: "power"
                text: "Shut Down"
                onClicked: root.powerRequested()
            }
        }
    }

    onLockedChanged: {
        if (locked) {
            passwordInput.text = ""
            passwordInput.input.forceActiveFocus()
        }
    }
}
