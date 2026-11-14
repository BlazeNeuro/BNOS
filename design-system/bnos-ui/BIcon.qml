import QtQuick
import QtQuick.Effects

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
        sourceSize.width: root.size * 2
        sourceSize.height: root.size * 2
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: false
    }

    MultiEffect {
        anchors.fill: img
        source: img
        colorization: 1.0
        colorizationColor: root.color
    }
}
