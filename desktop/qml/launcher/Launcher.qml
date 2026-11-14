import QtQuick
import QtQuick.Layouts
import "../../design-system/bnos-ui"
import BNOS.Core 1.0

Item {
    id: root

    property bool open: false
    signal closeRequested()
    signal appLaunched(string appName, string execCmd)
    signal lockRequested()
    signal powerOffRequested()
    signal restartRequested()

    anchors.fill: parent
    visible: opacity > 0
    opacity: open ? 1.0 : 0.0

    Behavior on opacity { NumberAnimation { duration: Theme.animBase } }

    // Backdrop
    Rectangle {
        anchors.fill: parent
        color: "#66000000"

        MouseArea {
            anchors.fill: parent
            onClicked: root.closeRequested()
        }
    }

    // C++ App Backend Model
    AppModel {
        id: cppAppModel
        filterText: searchInput.text
        categoryFilter: categoryTabs.model[categoryTabs.currentIndex]
    }

    // Modal Launcher Container
    Rectangle {
        id: container
        width: Math.min(parent.width - 60, 680)
        height: Math.min(parent.height - 100, 560)
        anchors.centerIn: parent
        radius: Theme.radiusXl
        color: Theme.popover
        border.width: 1
        border.color: Theme.border

        scale: root.open ? 1.0 : 0.96
        Behavior on scale { NumberAnimation { duration: Theme.animBase; easing.type: Easing.OutQuad } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            // Top Search Bar
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                BInput {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: "Search apps, commands, files..."
                    iconName: "search"
                    onAccepted: {
                        if (cppAppModel.count > 0) {
                            cppAppModel.launch(0)
                            root.closeRequested()
                        }
                    }
                }

                BBadge {
                    text: "ESC to close"
                    variant: "outline"
                }
            }

            BSeparator { Layout.fillWidth: true }

            // Category Tabs
            BTabs {
                id: categoryTabs
                Layout.fillWidth: true
                model: ["All Apps", "System", "Productivity", "Development"]
                onTabSelected: function(index) {
                    cppAppModel.categoryFilter = categoryTabs.model[index]
                }
            }

            // Apps Grid driven by C++ AppModel
            GridView {
                id: appsGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: appsGrid.width / 4
                cellHeight: 110

                model: cppAppModel

                delegate: Rectangle {
                    width: appsGrid.cellWidth - 12
                    height: 98
                    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                    radius: Theme.radiusMd
                    color: appMouse.containsMouse ? Theme.accent : "transparent"

                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Rectangle {
                            width: 44
                            height: 44
                            radius: Theme.radiusMd
                            color: Theme.card
                            border.width: 1
                            border.color: Theme.border
                            anchors.horizontalCenter: parent.horizontalCenter

                            BIcon {
                                anchors.centerIn: parent
                                name: model.icon || "grid"
                                size: 22
                                color: Theme.brandPrimary
                            }
                        }

                        Text {
                            text: model.name
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSm
                            font.weight: Font.Medium
                            color: Theme.foreground
                            anchors.horizontalCenter: parent.horizontalCenter
                            elide: Text.ElideRight
                            width: parent.parent.width - 8
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    MouseArea {
                        id: appMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            cppAppModel.launch(index)
                            root.appLaunched(model.name, model.exec)
                            root.closeRequested()
                        }
                    }
                }
            }

            BSeparator { Layout.fillWidth: true }

            // Bottom Bar: Brand & C++ Power Controls
            RowLayout {
                Layout.fillWidth: true

                Row {
                    spacing: 8
                    BIcon {
                        name: "fire"
                        size: 18
                        color: Theme.brandPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "BNOS 1.0 Trixie"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSm
                        font.weight: Font.SemiBold
                        color: Theme.mutedForeground
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item { Layout.fillWidth: true }

                Row {
                    spacing: 8

                    BButton {
                        variant: "ghost"
                        size: "sm"
                        iconName: "lock"
                        text: "Lock"
                        onClicked: {
                            root.closeRequested()
                            root.lockRequested()
                        }
                    }

                    BButton {
                        variant: "ghost"
                        size: "sm"
                        iconName: "power"
                        text: "Restart"
                        onClicked: {
                            root.closeRequested()
                            root.restartRequested()
                            if (typeof SystemManager !== "undefined") SystemManager.reboot()
                        }
                    }

                    BButton {
                        variant: "destructive"
                        size: "sm"
                        iconName: "power"
                        text: "Shut Down"
                        onClicked: {
                            root.closeRequested()
                            root.powerOffRequested()
                            if (typeof SystemManager !== "undefined") SystemManager.powerOff()
                        }
                    }
                }
            }
        }
    }

    onOpenChanged: {
        if (open) {
            cppAppModel.reload()
            searchInput.input.forceActiveFocus()
        }
    }
}
