import QtQuick

Item {
    id: root

    property bool open: false
    property string title: ""
    property string description: ""
    default property alias content: dialogContent.children

    signal accepted()
    signal cancelled()

    anchors.fill: parent
    visible: opacity > 0
    opacity: open ? 1.0 : 0.0

    Behavior on opacity { NumberAnimation { duration: Theme.animBase } }

    // Backdrop
    Rectangle {
        anchors.fill: parent
        color: "#99000000"

        MouseArea {
            anchors.fill: parent
            onClicked: root.cancelled()
        }
    }

    // Modal Card
    Rectangle {
        id: card
        width: Math.min(parent.width - 40, 440)
        height: dialogCol.implicitHeight + 40
        anchors.centerIn: parent
        radius: Theme.radiusLg
        color: Theme.card
        border.width: 1
        border.color: Theme.border

        scale: root.open ? 1.0 : 0.95
        Behavior on scale { NumberAnimation { duration: Theme.animBase; easing.type: Easing.OutQuad } }

        Column {
            id: dialogCol
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Row {
                width: parent.width
                spacing: 8

                Column {
                    width: parent.width - 32
                    spacing: 4

                    Text {
                        text: root.title
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontLg
                        font.weight: Font.DemiBold
                        color: Theme.cardForeground
                    }

                    Text {
                        text: root.description
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSm
                        color: Theme.mutedForeground
                        wrapMode: Text.WordWrap
                        width: parent.width
                        visible: root.description !== ""
                    }
                }

                BButton {
                    variant: "ghost"
                    size: "icon"
                    iconName: "close"
                    onClicked: root.cancelled()
                }
            }

            BSeparator {}

            Item {
                id: dialogContent
                width: parent.width
                implicitHeight: childrenRect.height
            }
        }
    }
}
