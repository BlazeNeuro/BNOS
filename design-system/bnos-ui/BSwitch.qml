import QtQuick

Item {
    id: root

    property bool checked: false
    property bool disabled: false

    signal toggled(bool isChecked)

    implicitWidth: 44
    implicitHeight: 24

    Rectangle {
        id: track
        anchors.fill: parent
        radius: Theme.radiusFull
        color: root.checked ? Theme.primary : Theme.muted
        border.width: 1
        border.color: root.checked ? Theme.primary : Theme.border
        opacity: root.disabled ? 0.45 : 1.0

        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

        Rectangle {
            id: thumb
            width: 18
            height: 18
            radius: Theme.radiusFull
            y: 2
            x: root.checked ? parent.width - width - 3 : 3
            color: root.checked ? Theme.primaryForeground : Theme.foreground

            Behavior on x { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        enabled: !root.disabled
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
