import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../design-system/bnos-ui"

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

    property bool isGridView: true
    property string activeBookmark: "home"

    // Instantiate C++ File Manager Model
    FileManagerModel {
        id: fileModel
        onItemOpened: function(p) {
            toast.show("Opening File", p, "file")
        }
        onErrorOccurred: function(msg) {
            toast.show("File Error", msg, "close")
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ================= Window Titlebar =================
        Rectangle {
            Layout.fillWidth: true
            height: 48
            color: Theme.card
            border.color: Theme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                // Navigation Controls (Back, Forward, Up)
                Row {
                    spacing: 4

                    BButton {
                        variant: "ghost"
                        size: "icon"
                        enabled: fileModel.canGoBack
                        BIcon {
                            anchors.centerIn: parent
                            name: "arrow-left"
                            size: 16
                            color: parent.enabled ? Theme.foreground : Theme.mutedForeground
                        }
                        onClicked: fileModel.goBack()
                    }

                    BButton {
                        variant: "ghost"
                        size: "icon"
                        enabled: fileModel.canGoForward
                        BIcon {
                            anchors.centerIn: parent
                            name: "arrow-right"
                            size: 16
                            color: parent.enabled ? Theme.foreground : Theme.mutedForeground
                        }
                        onClicked: fileModel.goForward()
                    }

                    BButton {
                        variant: "ghost"
                        size: "icon"
                        BIcon {
                            anchors.centerIn: parent
                            name: "arrow-up"
                            size: 16
                            color: Theme.foreground
                        }
                        onClicked: fileModel.goUp()
                    }
                }

                // Breadcrumb Path Pill
                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: Theme.radiusMd
                    color: Theme.surface
                    border.color: Theme.border
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 6

                        BIcon {
                            name: "folder"
                            size: 16
                            color: Theme.brandPrimary
                        }

                        Text {
                            Layout.fillWidth: true
                            text: fileModel.currentPath
                            font.pixelSize: Theme.fontSizeSm
                            color: Theme.foreground
                            elide: Text.ElideMiddle
                        }
                    }
                }

                // Search Box
                BInput {
                    id: searchBox
                    Layout.preferredWidth: 200
                    placeholder: "Search files..."
                    onTextChanged: fileModel.search(text)
                }

                // New Folder Button
                BButton {
                    variant: "outline"
                    size: "sm"
                    text: "+ Folder"
                    onClicked: newFolderDialog.open()
                }

                // Close Window Button
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

        // ================= Main Content Area =================
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ---------------- Left Sidebar (Places & Folders) ----------------
            Rectangle {
                Layout.preferredWidth: 210
                Layout.fillHeight: true
                color: Theme.card
                border.color: Theme.border
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 12
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 4

                    Text {
                        text: "PLACES"
                        font.pixelSize: Theme.fontSizeXs
                        font.weight: Font.Bold
                        color: Theme.mutedForeground
                        Layout.leftMargin: 8
                        Layout.bottomMargin: 4
                    }

                    SidebarItem {
                        iconName: "grid"
                        label: "Home"
                        isSelected: root.activeBookmark === "home"
                        onClicked: {
                            root.activeBookmark = "home"
                            fileModel.openPath(fileModel.getHomePath())
                        }
                    }

                    SidebarItem {
                        iconName: "monitor"
                        label: "Desktop"
                        isSelected: root.activeBookmark === "desktop"
                        onClicked: {
                            root.activeBookmark = "desktop"
                            fileModel.openPath(fileModel.getDesktopPath())
                        }
                    }

                    SidebarItem {
                        iconName: "file"
                        label: "Documents"
                        isSelected: root.activeBookmark === "documents"
                        onClicked: {
                            root.activeBookmark = "documents"
                            fileModel.openPath(fileModel.getDocumentsPath())
                        }
                    }

                    SidebarItem {
                        iconName: "arrow-up"
                        label: "Downloads"
                        isSelected: root.activeBookmark === "downloads"
                        onClicked: {
                            root.activeBookmark = "downloads"
                            fileModel.openPath(fileModel.getDownloadsPath())
                        }
                    }

                    SidebarItem {
                        iconName: "code"
                        label: "Projects"
                        isSelected: root.activeBookmark === "projects"
                        onClicked: {
                            root.activeBookmark = "projects"
                            fileModel.openPath(fileModel.getProjectsPath())
                        }
                    }

                    SidebarItem {
                        iconName: "folder"
                        label: "Pictures"
                        isSelected: root.activeBookmark === "pictures"
                        onClicked: {
                            root.activeBookmark = "pictures"
                            fileModel.openPath(fileModel.getPicturesPath())
                        }
                    }

                    SidebarItem {
                        iconName: "volume"
                        label: "Music"
                        isSelected: root.activeBookmark === "music"
                        onClicked: {
                            root.activeBookmark = "music"
                            fileModel.openPath(fileModel.getMusicPath())
                        }
                    }

                    SidebarItem {
                        iconName: "monitor"
                        label: "Videos"
                        isSelected: root.activeBookmark === "videos"
                        onClicked: {
                            root.activeBookmark = "videos"
                            fileModel.openPath(fileModel.getVideosPath())
                        }
                    }

                    BSeparator {
                        Layout.fillWidth: true
                        Layout.topMargin: 6
                        Layout.bottomMargin: 6
                    }

                    Text {
                        text: "DEVICES"
                        font.pixelSize: Theme.fontSizeXs
                        font.weight: Font.Bold
                        color: Theme.mutedForeground
                        Layout.leftMargin: 8
                        Layout.bottomMargin: 4
                    }

                    SidebarItem {
                        iconName: "cpu"
                        label: "File System"
                        isSelected: root.activeBookmark === "root"
                        onClicked: {
                            root.activeBookmark = "root"
                            fileModel.openPath(fileModel.getRootPath())
                        }
                    }

                    SidebarItem {
                        iconName: "trash"
                        label: "Trash"
                        isSelected: root.activeBookmark === "trash"
                        onClicked: {
                            root.activeBookmark = "trash"
                            fileModel.openPath(fileModel.getHomePath() + "/.local/share/Trash/files")
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // ---------------- Right File View Area ----------------
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.background

                // Empty folder indicator
                Column {
                    anchors.centerIn: parent
                    spacing: 12
                    visible: fileModel.itemCount === 0

                    BIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        name: "folder"
                        size: 48
                        color: Theme.mutedForeground
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "This folder is empty"
                        font.pixelSize: Theme.fontSizeBase
                        color: Theme.mutedForeground
                    }
                }

                // Grid View of Files & Folders
                GridView {
                    id: fileGrid
                    anchors.fill: parent
                    anchors.margins: 16
                    cellWidth: 120
                    cellHeight: 115
                    clip: true
                    model: fileModel

                    delegate: Item {
                        width: fileGrid.cellWidth
                        height: fileGrid.cellHeight

                        Rectangle {
                            id: fileCard
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: Theme.radiusMd
                            color: itemMouse.containsMouse ? Theme.surfaceHover : "transparent"
                            border.color: itemMouse.containsMouse ? Theme.border : "transparent"
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 8
                                width: parent.width - 12

                                BIcon {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    name: model.iconName
                                    size: 38
                                    color: model.isDir ? Theme.brandPrimary : Theme.foreground
                                }

                                Text {
                                    width: parent.width
                                    text: model.name
                                    font.pixelSize: Theme.fontSizeSm
                                    color: Theme.foreground
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideMiddle
                                    maximumLineCount: 2
                                    wrapMode: Text.WrapAnywhere
                                }

                                Text {
                                    visible: !model.isDir
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: model.formattedSize
                                    font.pixelSize: Theme.fontSizeXs
                                    color: Theme.mutedForeground
                                }
                            }

                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onDoubleClicked: fileModel.openItem(index)
                            }
                        }
                    }
                }
            }
        }

        // ================= Bottom Status Bar =================
        Rectangle {
            Layout.fillWidth: true
            height: 28
            color: Theme.card
            border.color: Theme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                Text {
                    text: fileModel.itemCount + " items"
                    font.pixelSize: Theme.fontSizeXs
                    color: Theme.mutedForeground
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: fileModel.currentDirName
                    font.pixelSize: Theme.fontSizeXs
                    font.weight: Font.Medium
                    color: Theme.mutedForeground
                }
            }
        }
    }

    // Sidebar navigation row item
    component SidebarItem: Rectangle {
        id: sbItem
        property string iconName: ""
        property string label: ""
        property bool isSelected: false
        signal clicked()

        Layout.fillWidth: true
        height: 32
        radius: Theme.radiusSm
        color: sbItem.isSelected ? Theme.accent : (sbMouse.containsMouse ? Theme.surfaceHover : "transparent")

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 10

            BIcon {
                name: sbItem.iconName
                size: 16
                color: sbItem.isSelected ? Theme.brandPrimary : Theme.mutedForeground
            }

            Text {
                Layout.fillWidth: true
                text: sbItem.label
                font.pixelSize: Theme.fontSizeSm
                font.weight: sbItem.isSelected ? Font.SemiBold : Font.Normal
                color: sbItem.isSelected ? Theme.foreground : Theme.mutedForeground
            }
        }

        MouseArea {
            id: sbMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: sbItem.clicked()
        }
    }

    // Dialog: New Folder
    BDialog {
        id: newFolderDialog
        title: "Create New Folder"
        description: "Enter a name for the new folder:"
        confirmText: "Create"
        cancelText: "Cancel"

        BInput {
            id: newFolderInput
            width: parent.width
            placeholder: "New Folder Name"
            text: "Untitled Folder"
        }

        onConfirmed: {
            if (newFolderInput.text.trim().length > 0) {
                fileModel.createFolder(newFolderInput.text.trim())
            }
        }
    }

    // Notification Toast inside File Manager
    BToast {
        id: toast
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 36
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
