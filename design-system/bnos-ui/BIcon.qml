import QtQuick

Item {
    id: root

    property string name: ""
    property int size: 20
    property color color: Theme.foreground
    property string sourceUrl: name !== "" ? ("../../themes/icons/solar/" + name + ".svg") : ""

    implicitWidth: size
    implicitHeight: size

    Image {
        id: img
        anchors.fill: parent
        source: root.sourceUrl
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: root.name !== ""
        opacity: root.color === Theme.mutedForeground ? 0.6 : 1.0
    }
}
