import QtQuick
import QtQuick.Window

Window {
    id: window
    width: 1280
    height: 800
    minimumWidth: 800
    minimumHeight: 600
    visible: true
    title: "BNOS Desktop Shell — BlazeNeuro"

    Shell {
        anchors.fill: parent
    }
}
