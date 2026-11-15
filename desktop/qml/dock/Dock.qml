import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../design-system/bnos-ui"

Item {
    id: root

    height: 72
    width: dockCard.width

    // Signals emitted to desktop shell
    signal toggleLauncher()
    signal openFiles()
    signal openBrowser()
    signal openStore()
    signal openTerminal()
    signal openSettings()

    // Active state indicators (can be bound to running window tracker)
    property bool filesRunning: false
    property bool browserRunning: false
    property bool storeRunning: false
    property bool terminalRunning: false
    property bool settingsRunning: false

    // Dock container card
    Rectangle {
        id: dockCard
        height: 64
        width: dockRow.implicitWidth + 24
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        radius: Theme.radiusXl

        color: Theme.glassBackground
        border.color: Theme.glassBorder
        border.width: 1

        Row {
            id: dockRow
            anchors.centerIn: parent
            spacing: 8

            // 1. App Launcher / Drawer
            DockItem {
                iconName: "grid"
                label: "Applications"
                badgeText: ""
                isRunning: false
                onClicked: root.toggleLauncher()
            }

            // Separator
            Rectangle {
                width: 1
                height: 32
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.border
                opacity: 0.6
            }

            // 2. Files (shadcn File Manager)
            DockItem {
                iconName: "folder"
                label: "Files"
                badgeText: ""
                isRunning: root.filesRunning
                onClicked: root.openFiles()
            }

            // 3. Web Browser (Firefox)
            DockItem {
                iconName: "globe"
                label: "Web Browser"
                badgeText: ""
                isRunning: root.browserRunning
                onClicked: root.openBrowser()
            }

            // 4. App Store (Software Center)
            DockItem {
                iconName: "bag"
                label: "Software Store"
                badgeText: ""
                isRunning: root.storeRunning
                onClicked: root.openStore()
            }

            // 5. Terminal
            DockItem {
                iconName: "terminal"
                label: "Terminal"
                badgeText: ""
                isRunning: root.terminalRunning
                onClicked: root.openTerminal()
            }

            // Separator
            Rectangle {
                width: 1
                height: 32
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.border
                opacity: 0.6
            }

            // 6. Settings
            DockItem {
                iconName: "settings"
                label: "System Settings"
                badgeText: ""
                isRunning: root.settingsRunning
                onClicked: root.openSettings()
            }
        }
    }

    // Component for individual dock item with hover magnification & tooltip
    component DockItem: Item {
        id: item

        property string iconName: ""
        property string label: ""
        property string badgeText: ""
        property bool isRunning: false
        signal clicked()

        width: 48
        height: 48

        // Hover scale animation (macOS-style magnification)
        scale: mouseArea.containsMouse ? 1.15 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        Rectangle {
            id: itemBg
            anchors.fill: parent
            radius: Theme.radiusMd
            color: mouseArea.pressed ? Theme.accent : (mouseArea.containsMouse ? Theme.surfaceHover : "transparent")
            border.color: mouseArea.containsMouse ? Theme.border : "transparent"
            border.width: 1

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            BIcon {
                anchors.centerIn: parent
                name: item.iconName
                size: 26
                color: mouseArea.containsMouse ? Theme.brandPrimary : Theme.foreground
            }
        }

        // Running Indicator Dot (Ubuntu / macOS style)
        Rectangle {
            visible: item.isRunning
            width: 4
            height: 4
            radius: 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -2
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.brandPrimary
        }

        // Tooltip Badge on hover
        Rectangle {
            id: tooltip
            visible: mouseArea.containsMouse
            anchors.bottom: parent.top
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            width: tooltipText.implicitWidth + 14
            height: 24
            radius: Theme.radiusSm
            color: Theme.popover
            border.color: Theme.border
            border.width: 1

            Text {
                id: tooltipText
                anchors.centerIn: parent
                text: item.label
                font.pixelSize: Theme.fontSizeXs
                font.weight: Font.Medium
                color: Theme.popoverForeground
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: item.clicked()
        }
    }
}
