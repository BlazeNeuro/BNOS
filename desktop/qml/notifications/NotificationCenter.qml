import QtQuick
import QtQuick.Layouts
import "../../design-system/bnos-ui"

Item {
    id: root

    property bool open: false
    property bool dndActive: false

    signal closeRequested()
    signal clearAllRequested()

    anchors.fill: parent
    visible: opacity > 0
    opacity: open ? 1.0 : 0.0

    Behavior on opacity { NumberAnimation { duration: Theme.animBase } }

    MouseArea {
        anchors.fill: parent
        onClicked: root.closeRequested()
    }

    // Side Drawer anchored to right edge
    Rectangle {
        id: drawer
        width: Math.min(parent.width - 40, 380)
        height: parent.height - 56
        anchors.top: parent.top
        anchors.topMargin: 52
        anchors.right: parent.right
        anchors.rightMargin: 8
        radius: Theme.radiusLg
        color: Theme.popover
        border.width: 1
        border.color: Theme.border

        x: root.open ? (parent.width - width - 8) : parent.width

        Behavior on x { NumberAnimation { duration: Theme.animBase; easing.type: Easing.OutQuad } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // Header
            RowLayout {
                Layout.fillWidth: true

                Row {
                    spacing: 8
                    BIcon {
                        name: "bell"
                        size: 18
                        color: Theme.foreground
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Notifications"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBase
                        font.weight: Font.SemiBold
                        color: Theme.foreground
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item { Layout.fillWidth: true }

                BButton {
                    variant: "ghost"
                    size: "sm"
                    text: "Clear All"
                    visible: notifModel.count > 0
                    onClicked: {
                        notifModel.clear()
                        root.clearAllRequested()
                    }
                }
            }

            // DND Bar
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: Theme.radiusMd
                color: Theme.card
                border.width: 1
                border.color: Theme.border

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    Text {
                        text: "Do Not Disturb"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSm
                        color: Theme.foreground
                    }

                    Item { Layout.fillWidth: true }

                    BSwitch {
                        checked: root.dndActive
                        onToggled: function(val) { root.dndActive = val }
                    }
                }
            }

            BSeparator { Layout.fillWidth: true }

            // Notification List
            ListView {
                id: notifList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 10
                model: ListModel {
                    id: notifModel
                    ListElement {
                        title: "System Update Ready"
                        body: "Debian Trixie core patches and BNOS kernel update are available."
                        icon: "info"
                        time: "5m ago"
                    }
                    ListElement {
                        title: "Terminal Session"
                        body: "Background live-build environment check completed successfully."
                        icon: "terminal"
                        time: "24m ago"
                    }
                    ListElement {
                        title: "BlazeNeuro OS"
                        body: "Welcome to BNOS! Design system components initialized."
                        icon: "fire"
                        time: "1h ago"
                    }
                }

                delegate: Rectangle {
                    width: notifList.width
                    height: cardCol.implicitHeight + 20
                    radius: Theme.radiusMd
                    color: Theme.card
                    border.width: 1
                    border.color: Theme.border

                    ColumnLayout {
                        id: cardCol
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true

                            BIcon {
                                name: model.icon
                                size: 14
                                color: Theme.brandPrimary
                            }

                            Text {
                                text: model.title
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSm
                                font.weight: Font.SemiBold
                                color: Theme.foreground
                                Layout.fillWidth: true
                            }

                            Text {
                                text: model.time
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontXs
                                color: Theme.mutedForeground
                            }
                        }

                        Text {
                            text: model.body
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontXs
                            color: Theme.mutedForeground
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }

                // Empty state
                Item {
                    anchors.centerIn: parent
                    visible: notifModel.count === 0
                    width: 200
                    height: 120

                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        BIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "bell"
                            size: 28
                            color: Theme.mutedForeground
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "No notifications"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSm
                            color: Theme.mutedForeground
                        }
                    }
                }
            }
        }
    }
}
