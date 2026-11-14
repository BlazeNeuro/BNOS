import QtQuick

Rectangle {
    id: root

    // Variants: default | secondary | outline | ghost | destructive | link
    property string variant: "default"
    // Sizes: sm | default | lg | icon
    property string size: "default"

    property string text: ""
    property string iconName: ""
    property bool disabled: false
    property bool loading: false

    signal clicked()

    implicitWidth: {
        if (size === "icon") return buttonHeight
        return contentRow.implicitWidth + horizontalPadding * 2
    }
    implicitHeight: buttonHeight

    readonly property int buttonHeight: {
        switch (size) {
            case "sm": return 32
            case "lg": return 44
            case "icon": return 36
            default: return 36
        }
    }

    readonly property int horizontalPadding: {
        switch (size) {
            case "sm": return 12
            case "lg": return 24
            case "icon": return 0
            default: return 16
        }
    }

    readonly property int fontSize: {
        switch (size) {
            case "sm": return Theme.fontXs
            case "lg": return Theme.fontBase
            default: return Theme.fontSm
        }
    }

    readonly property int iconSize: {
        switch (size) {
            case "sm": return 14
            case "lg": return 18
            default: return 16
        }
    }

    radius: Theme.radiusMd
    opacity: disabled ? 0.45 : 1.0

    // Color logic according to shadcn/ui variants
    color: {
        if (variant === "default") {
            return mouseArea.containsPress ? Qt.darker(Theme.primary, 1.1) :
                   mouseArea.containsMouse ? Qt.darker(Theme.primary, 1.05) : Theme.primary
        } else if (variant === "secondary") {
            return mouseArea.containsPress ? Qt.darker(Theme.secondary, 1.1) :
                   mouseArea.containsMouse ? Theme.accent : Theme.secondary
        } else if (variant === "destructive") {
            return mouseArea.containsPress ? Qt.darker(Theme.destructive, 1.15) :
                   mouseArea.containsMouse ? Qt.darker(Theme.destructive, 1.08) : Theme.destructive
        } else if (variant === "outline" || variant === "ghost" || variant === "link") {
            return mouseArea.containsMouse ? (Theme.isDark ? "#1f1f23" : "#f4f4f5") : "transparent"
        }
        return Theme.primary
    }

    border.width: variant === "outline" ? 1 : 0
    border.color: Theme.border

    // Active scale feedback
    scale: mouseArea.containsPress && !disabled ? 0.98 : 1.0
    Behavior on scale { NumberAnimation { duration: Theme.animFast } }
    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    // Focus ring
    Rectangle {
        anchors.fill: parent
        anchors.margins: -3
        radius: root.radius + 3
        color: "transparent"
        border.width: root.activeFocus ? 2 : 0
        border.color: Theme.ring
        visible: root.activeFocus
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8

        BIcon {
            id: iconItem
            name: root.iconName
            size: root.iconSize
            color: root.textColor
            visible: root.iconName !== "" && !root.loading
            anchors.verticalCenter: parent.verticalCenter
        }

        // Loading spinner placeholder
        Rectangle {
            width: root.iconSize
            height: root.iconSize
            radius: width / 2
            color: "transparent"
            border.width: 2
            border.color: root.textColor
            visible: root.loading
            anchors.verticalCenter: parent.verticalCenter
            RotationAnimation on rotation {
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 900
                running: root.loading
            }
        }

        Text {
            id: textItem
            text: root.text
            font.family: Theme.fontFamily
            font.pixelSize: root.fontSize
            font.weight: Font.Medium
            color: root.textColor
            visible: root.text !== ""
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    readonly property color textColor: {
        if (variant === "default") return Theme.primaryForeground
        if (variant === "secondary") return Theme.secondaryForeground
        if (variant === "destructive") return Theme.destructiveForeground
        if (variant === "link") return Theme.brandPrimary
        return Theme.foreground
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: !root.disabled
        cursorShape: root.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        enabled: !root.disabled && !root.loading
        onClicked: {
            root.forceActiveFocus()
            root.clicked()
        }
    }
}
