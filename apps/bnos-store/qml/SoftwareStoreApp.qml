import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../design-system/bnos-ui"

Rectangle {
    id: root

    width: 920
    height: 620
    color: Theme.background
    radius: Theme.radiusLg
    border.color: Theme.border
    border.width: 1
    clip: true

    signal closeRequested()

    // Instantiate C++ Software Manager
    SoftwareManager {
        id: storeManager
        onInstallStarted: function(name) {
            toast.show("Installing Software", "Starting installation of " + name + "...", "bag")
        }
        onInstallFinished: function(name, ok) {
            if (ok) {
                toast.show("Installation Complete", name + " is now ready to launch.", "check")
            } else {
                toast.show("Installation Failed", "Could not install " + name + ". Check connection.", "close")
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ================= Window Titlebar =================
        Rectangle {
            Layout.fillWidth: true
            height: 52
            color: Theme.card
            border.color: Theme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                BIcon {
                    name: "bag"
                    size: 22
                    color: Theme.brandPrimary
                }

                Text {
                    text: "BNOS Software Store"
                    font.pixelSize: Theme.fontSizeLg
                    font.weight: Font.Bold
                    color: Theme.foreground
                }

                Item { Layout.fillWidth: true }

                // Search Input
                BInput {
                    Layout.preferredWidth: 240
                    placeholder: "Search store..."
                    onTextChanged: storeManager.search(text)
                }

                // Close Button
                BButton {
                    variant: "ghost"
                    size: "icon"
                    BIcon {
                        anchors.centerIn: parent
                        name: "close"
                        size: 16
                        color: Theme.mutedForeground
                    }
                    onClicked: root.closeRequested()
                }
            }
        }

        // ================= Category Navigation Bar =================
        Rectangle {
            Layout.fillWidth: true
            height: 44
            color: Theme.surface
            border.color: Theme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 6

                Repeater {
                    model: ["All", "Installed", "Development", "Multimedia", "Productivity", "Utilities", "System"]

                    Rectangle {
                        height: 30
                        width: catText.implicitWidth + 20
                        radius: Theme.radiusSm
                        color: storeManager.activeCategory === modelData ? Theme.primary :
                               catMouse.containsMouse ? Theme.surfaceHover : "transparent"

                        Text {
                            id: catText
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: Theme.fontSizeSm
                            font.weight: storeManager.activeCategory === modelData ? Font.SemiBold : Font.Normal
                            color: storeManager.activeCategory === modelData ? Theme.primaryForeground : Theme.mutedForeground
                        }

                        MouseArea {
                            id: catMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: storeManager.setCategory(modelData)
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: storeManager.totalApps + " apps"
                    font.pixelSize: Theme.fontSizeXs
                    color: Theme.mutedForeground
                }
            }
        }

        // ================= Applications Grid =================
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.background

            GridView {
                id: appsGrid
                anchors.fill: parent
                anchors.margins: 16
                cellWidth: parent.width > 700 ? (parent.width - 32) / 2 : (parent.width - 32)
                cellHeight: 140
                clip: true
                model: storeManager

                delegate: Item {
                    width: appsGrid.cellWidth
                    height: appsGrid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: Theme.radiusLg
                        color: Theme.card
                        border.color: Theme.border
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 14

                            // App Icon Card
                            Rectangle {
                                width: 56
                                height: 56
                                radius: Theme.radiusMd
                                color: Theme.surface
                                border.color: Theme.border
                                border.width: 1

                                BIcon {
                                    anchors.centerIn: parent
                                    name: model.iconName
                                    size: 28
                                    color: Theme.brandPrimary
                                }
                            }

                            // App Details
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                RowLayout {
                                    spacing: 8
                                    Text {
                                        text: model.name
                                        font.pixelSize: Theme.fontSizeBase
                                        font.weight: Font.SemiBold
                                        color: Theme.foreground
                                    }

                                    BBadge {
                                        text: model.category
                                        variant: "secondary"
                                    }

                                    BBadge {
                                        visible: model.isInstalled
                                        text: "Installed"
                                        variant: "outline"
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: model.description
                                    font.pixelSize: Theme.fontSizeXs
                                    color: Theme.mutedForeground
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                    wrapMode: Text.WordWrap
                                }

                                Item { Layout.fillHeight: true }

                                // Actions
                                RowLayout {
                                    spacing: 8

                                    BButton {
                                        visible: !model.isInstalled && !model.isInstalling
                                        variant: "default"
                                        size: "sm"
                                        text: "Install"
                                        onClicked: storeManager.installApp(index)
                                    }

                                    BButton {
                                        visible: model.isInstalling
                                        variant: "outline"
                                        size: "sm"
                                        text: "Installing..."
                                        enabled: false
                                    }

                                    BButton {
                                        visible: model.isInstalled
                                        variant: "default"
                                        size: "sm"
                                        text: "Open"
                                        onClicked: storeManager.launchApp(index)
                                    }

                                    BButton {
                                        visible: model.isInstalled
                                        variant: "ghost"
                                        size: "sm"
                                        text: "Remove"
                                        onClicked: storeManager.removeApp(index)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Toast
    BToast {
        id: toast
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
