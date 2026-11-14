pragma Singleton
import QtQuick

QtObject {
    id: root

    // Theme toggle: dark (default) / light
    property bool isDark: true

    // Brand accent colors (Flame / BlazeNeuro)
    readonly property color brandPrimary: "#f97316"    // Blaze Orange
    readonly property color brandSecondary: "#fb923c"  // Soft Orange
    readonly property color brandGlow: "#ea580c"

    // shadcn/ui zinc-slate tokens
    readonly property color background: isDark ? "#09090b" : "#ffffff"
    readonly property color surface: isDark ? "#121215" : "#f8fafc"
    readonly property color foreground: isDark ? "#f4f4f5" : "#09090b"

    readonly property color card: isDark ? "#18181b" : "#ffffff"
    readonly property color cardForeground: isDark ? "#f4f4f5" : "#09090b"

    readonly property color popover: isDark ? "#18181b" : "#ffffff"
    readonly property color popoverForeground: isDark ? "#f4f4f5" : "#09090b"

    readonly property color primary: isDark ? "#fafafa" : "#18181b"
    readonly property color primaryForeground: isDark ? "#18181b" : "#fafafa"

    readonly property color secondary: isDark ? "#27272a" : "#f4f4f5"
    readonly property color secondaryForeground: isDark ? "#fafafa" : "#18181b"

    readonly property color muted: isDark ? "#27272a" : "#f4f4f5"
    readonly property color mutedForeground: isDark ? "#a1a1aa" : "#71717a"

    readonly property color accent: isDark ? "#27272a" : "#f4f4f5"
    readonly property color accentForeground: isDark ? "#fafafa" : "#18181b"

    readonly property color destructive: isDark ? "#ef4444" : "#dc2626"
    readonly property color destructiveForeground: "#fafafa"

    readonly property color border: isDark ? "#27272a" : "#e4e4e7"
    readonly property color inputBorder: isDark ? "#27272a" : "#e4e4e7"
    readonly property color inputBackground: isDark ? "#121215" : "#ffffff"
    readonly property color ring: isDark ? "#a1a1aa" : "#18181b"

    readonly property color highlight: isDark ? "#3f3f46" : "#e4e4e7"
    readonly property color glassBackground: isDark ? "#cc09090b" : "#ccffffff"
    readonly property color glassBorder: isDark ? "#4027272a" : "#40e4e4e7"

    // Geometry / Radii
    readonly property real radiusSm: 4
    readonly property real radiusMd: 6
    readonly property real radiusLg: 8
    readonly property real radiusXl: 12
    readonly property real radiusFull: 9999

    // Elevation / Shadows
    readonly property color shadowColor: isDark ? "#80000000" : "#20000000"

    // Typography
    readonly property string fontFamily: "Inter, sans-serif"
    readonly property string fontMono: "JetBrains Mono, monospace"

    readonly property int fontXs: 11
    readonly property int fontSm: 12
    readonly property int fontBase: 14
    readonly property int fontLg: 16
    readonly property int fontXl: 18
    readonly property int font2Xl: 22
    readonly property int font3Xl: 28

    // Spacing
    readonly property int space1: 4
    readonly property int space2: 8
    readonly property int space3: 12
    readonly property int space4: 16
    readonly property int space5: 20
    readonly property int space6: 24
    readonly property int space8: 32

    // Animation speeds (ms)
    readonly property int animFast: 120
    readonly property int animBase: 200
    readonly property int animSlow: 350

    function toggleTheme() {
        isDark = !isDark
    }
}
