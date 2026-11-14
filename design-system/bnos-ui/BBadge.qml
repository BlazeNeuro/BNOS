import QtQuick

Rectangle {
    id: root

    // default | secondary | outline | destructive
    property string variant: "default"
    property string text: ""
    property string iconName: ""

    implicitWidth: contentRow.implicitWidth + 16
    implicitHeight: 22

    radius: Theme.radiusFull

    color: {
        if (variant === "secondary") return Theme.secondary
        if (variant === "destructive") return Theme.destructive
        if (variant === "outline") return "transparent"
        return Theme.primary
    }

    border.width: variant === "outline" ? 1 : 0
    border.color: Theme.border

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 4

        BIcon {
            name: root.iconName
            size: 11
            color: root.textColor
            visible: root.iconName !== ""
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontXs
            font.weight: Font.DemiBold
            color: root.textColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    readonly property color textColor: {
        if (variant === "secondary") return Theme.secondaryForeground
        if (variant === "destructive") return Theme.destructiveForeground
        if (variant === "outline") return Theme.foreground
        return Theme.primaryForeground
    }
}
