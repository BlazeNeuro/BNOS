import QtQuick

Rectangle {
    id: root

    property alias text: textInput.text
    property string placeholderText: ""
    property string iconName: ""
    property bool disabled: false
    property bool error: false
    property alias echoMode: textInput.echoMode
    property alias readOnly: textInput.readOnly
    property alias input: textInput

    signal accepted()
    signal textEdited()

    implicitWidth: 260
    implicitHeight: 38

    radius: Theme.radiusMd
    color: Theme.inputBackground
    border.width: 1
    border.color: error ? Theme.destructive : (textInput.activeFocus ? Theme.ring : Theme.border)

    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

    // Focus ring
    Rectangle {
        anchors.fill: parent
        anchors.margins: -3
        radius: root.radius + 3
        color: "transparent"
        border.width: textInput.activeFocus ? 2 : 0
        border.color: root.error ? Theme.destructive : Theme.ring
        opacity: 0.3
        visible: textInput.activeFocus
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8

        BIcon {
            name: root.iconName
            size: 16
            color: root.error ? Theme.destructive : Theme.mutedForeground
            visible: root.iconName !== ""
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: parent.width - (root.iconName !== "" ? 24 : 0)
            height: parent.height

            TextInput {
                id: textInput
                anchors.fill: parent
                verticalAlignment: TextInput.AlignVCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSm
                color: Theme.foreground
                selectionColor: Theme.brandPrimary
                selectedTextColor: "#ffffff"
                clip: true
                enabled: !root.disabled

                onAccepted: root.accepted()
                onTextEdited: root.textEdited()
            }

            Text {
                text: root.placeholderText
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSm
                color: Theme.mutedForeground
                visible: textInput.text === "" && !textInput.inputMethodComposing
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        acceptedButtons: Qt.NoButton
    }
}
