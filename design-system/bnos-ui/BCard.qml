import QtQuick

Rectangle {
    id: root

    property string title: ""
    property string description: ""
    default property alias content: contentSlot.children

    implicitWidth: 320
    implicitHeight: mainCol.implicitHeight + 32

    radius: Theme.radiusLg
    color: Theme.card
    border.width: 1
    border.color: Theme.border

    Column {
        id: mainCol
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        Column {
            width: parent.width
            spacing: 4
            visible: root.title !== "" || root.description !== ""

            Text {
                text: root.title
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontLg
                font.weight: Font.DemiBold
                color: Theme.cardForeground
                visible: root.title !== ""
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

        Item {
            id: contentSlot
            width: parent.width
            implicitHeight: childrenRect.height
        }
    }
}
