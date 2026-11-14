import QtQuick

Rectangle {
    id: root

    property string title: ""
    property string message: ""
    property string iconName: "info"
    property bool showing: false
    property int duration: 4000

    signal closed()

    implicitWidth: 320
    implicitHeight: toastRow.implicitHeight + 20

    radius: Theme.radiusMd
    color: Theme.card
    border.width: 1
    border.color: Theme.border

    opacity: showing ? 1.0 : 0.0
    y: showing ? 24 : -height

    Behavior on opacity { NumberAnimation { duration: Theme.animBase } }
    Behavior on y { NumberAnimation { duration: Theme.animBase; easing.type: Easing.OutQuad } }

    Timer {
        id: hideTimer
        interval: root.duration
        running: root.showing
        onTriggered: {
            root.showing = false
            root.closed()
        }
    }

    Row {
        id: toastRow
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        BIcon {
            name: root.iconName
            size: 18
            color: Theme.brandPrimary
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            width: parent.width - 50
            spacing: 2
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: root.title
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSm
                font.weight: Font.DemiBold
                color: Theme.cardForeground
            }

            Text {
                text: root.message
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontXs
                color: Theme.mutedForeground
                wrapMode: Text.WordWrap
                width: parent.width
                visible: root.message !== ""
            }
        }

        BButton {
            variant: "ghost"
            size: "icon"
            iconName: "close"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                root.showing = false
                root.closed()
            }
        }
    }

    function show(titleText, msgText, icon) {
        title = titleText
        message = msgText || ""
        if (icon) iconName = icon
        showing = true
        hideTimer.restart()
    }
}
