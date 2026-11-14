import QtQuick

Rectangle {
    id: root

    property string orientation: "horizontal" // horizontal | vertical
    property color color: Theme.border

    implicitWidth: orientation === "horizontal" ? parent.width : 1
    implicitHeight: orientation === "horizontal" ? 1 : parent.height

    color: root.color
}
