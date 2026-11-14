import QtQuick
import QtQuick.Layouts
import "../../design-system/bnos-ui"

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
                        if (filteredApps.count > 0) {
                            var app = filteredApps.get(0)
                            root.appLaunched(app.name, app.cmd)
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
                onTabSelected: {
                    filterModel()
                }
            }

            // Apps Grid
            GridView {
                id: appsGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: appsGrid.width / 4
                cellHeight: 110

                model: ListModel { id: filteredApps }

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
                                name: model.icon
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
                            root.appLaunched(model.name, model.cmd)
                            root.closeRequested()
                        }
                    }
                }
            }

            BSeparator { Layout.fillWidth: true }

            // Bottom Bar: Brand & Power controls
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
                        }
                    }
                }
            }
        }
    }

    // App Database
    ListModel {
        id: allAppsModel
        ListElement { name: "Terminal"; cmd: "foot"; icon: "terminal"; category: "Development" }
        ListElement { name: "File Manager"; cmd: "thunar"; icon: "folder"; category: "System" }
        ListElement { name: "Settings"; cmd: "bnos-settings"; icon: "settings"; category: "System" }
        ListElement { name: "Web Browser"; cmd: "firefox-esr"; icon: "fire"; category: "Productivity" }
        ListElement { name: "System Monitor"; cmd: "foot -e htop"; icon: "cpu"; category: "System" }
        ListElement { name: "Display Settings"; cmd: "wlr-randr"; icon: "monitor"; category: "System" }
    }

    function filterModel() {
        filteredApps.clear()
        var cat = categoryTabs.model[categoryTabs.currentIndex]
        var q = searchInput.text.toLowerCase()

        for (var i = 0; i < allAppsModel.count; ++i) {
            var item = allAppsModel.get(i)
            var matchesCat = (cat === "All Apps" || item.category === cat)
            var matchesQuery = (q === "" || item.name.toLowerCase().indexOf(q) !== -1 || item.cmd.toLowerCase().indexOf(q) !== -1)

            if (matchesCat && matchesQuery) {
                filteredApps.append(item)
            }
        }
    }

    onOpenChanged: {
        if (open) {
            filterModel()
            searchInput.input.forceActiveFocus()
        }
    }

    Connections {
        target: searchInput
        function onTextEdited() {
            root.filterModel()
        }
    }
}
