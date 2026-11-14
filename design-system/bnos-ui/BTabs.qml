import QtQuick

Rectangle {
    id: root

    property var model: []
    property int currentIndex: 0

    signal tabSelected(int index)

    implicitWidth: 320
    implicitHeight: 38

    radius: Theme.radiusMd
    color: Theme.muted
    border.width: 1
    border.color: Theme.border

    Row {
        id: tabRow
        anchors.fill: parent
        anchors.margins: 3
        spacing: 3

        Repeater {
            model: root.model

            Rectangle {
                id: tabButton
                width: (tabRow.width - (root.model.length - 1) * tabRow.spacing) / root.model.length
                height: tabRow.height
                radius: Theme.radiusSm

                readonly property bool isSelected: index === root.currentIndex
                color: isSelected ? Theme.card : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: modelData
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSm
                    font.weight: tabButton.isSelected ? Font.Medium : Font.Normal
                    color: tabButton.isSelected ? Theme.foreground : Theme.mutedForeground
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentIndex = index
                        root.tabSelected(index)
                    }
                }
            }
        }
    }
}
