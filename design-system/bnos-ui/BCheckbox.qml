import QtQuick

Rectangle {
    id: root

    property bool checked: false
    property bool disabled: false

    signal toggled(bool isChecked)

    implicitWidth: 18
    implicitHeight: 18

    radius: Theme.radiusSm
    color: root.checked ? Theme.primary : "transparent"
    border.width: 1
    border.color: root.checked ? Theme.primary : Theme.border
    opacity: root.disabled ? 0.45 : 1.0

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    BIcon {
        name: "check"
        size: 13
        color: Theme.primaryForeground
        anchors.centerIn: parent
        visible: root.checked
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
