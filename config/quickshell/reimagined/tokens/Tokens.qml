// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   D E S I G N   T O K E N S        │
// │   Canonical design system tokens, typography, radii, spacing & metrics    │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick

pragma Singleton

QtObject {
    id: root

    // ── Canonical Color System ───────────────────────────────────────────
    readonly property color background: "#0C0E14"
    readonly property color surface: "#12151D"
    readonly property color elevated: "#1E2433"
    readonly property color textPrimary: "#E2E8F0"
    readonly property color textSecondary: "#94A3B8"
    readonly property color accent: "#76A9FA"
    readonly property color danger: "#F87171"
    readonly property color muted: "#475569"

    // ── Extended Semantic & Surface Hierarchy ────────────────────────────
    readonly property color surfaceGlass: Qt.rgba(0.07, 0.08, 0.11, 0.78)
    readonly property color surfaceElevatedGlass: Qt.rgba(0.12, 0.14, 0.20, 0.85)
    readonly property color surfaceOverlay: Qt.rgba(0.05, 0.06, 0.08, 0.65)
    readonly property color islandBackground: "#0A0C10"

    // Interaction states
    readonly property color surfaceHover: "#181D29"
    readonly property color surfacePressed: "#232A3B"
    readonly property color accentHover: "#8AB9FB"
    readonly property color accentPressed: "#6296E6"
    readonly property color accentContainer: Qt.rgba(0.46, 0.66, 0.98, 0.18)
    readonly property color accentMuted: Qt.rgba(0.46, 0.66, 0.98, 0.10)
    readonly property color accentOn: "#0C0E14"

    // Semantic status colors
    readonly property color success: "#4ADE80"
    readonly property color warning: "#FBBF24"
    readonly property color dangerContainer: Qt.rgba(0.97, 0.44, 0.44, 0.18)
    readonly property color successContainer: Qt.rgba(0.29, 0.87, 0.50, 0.18)
    readonly property color warningContainer: Qt.rgba(0.98, 0.75, 0.14, 0.18)

    // Specular edges & hairline borders
    readonly property color borderGlass: Qt.rgba(1.0, 1.0, 1.0, 0.08)
    readonly property color borderSubtle: Qt.rgba(1.0, 1.0, 1.0, 0.05)
    readonly property color borderAccent: Qt.rgba(0.46, 0.66, 0.98, 0.40)
    readonly property color specularRim: Qt.rgba(1.0, 1.0, 1.0, 0.14)
    readonly property color specularHighlight: Qt.rgba(1.0, 1.0, 1.0, 0.22)
    readonly property color hairline: Qt.rgba(1.0, 1.0, 1.0, 0.06)

    // ── 4px Spacing Scale ─────────────────────────────────────────────────
    readonly property int s1: 4
    readonly property int s2: 8
    readonly property int s3: 12
    readonly property int s4: 16
    readonly property int s6: 24
    readonly property int s8: 32

    // ── Nominal Radii ─────────────────────────────────────────────────────
    readonly property real rControl: 10
    readonly property real rCard: 16
    readonly property real rMajor: 24
    readonly property real rPill: 9999

    // ── Typography & Hierarchy ───────────────────────────────────────────
    readonly property string fontSans: "Adwaita Sans, -apple-system, BlinkMacSystemFont, Inter, sans-serif"
    readonly property string fontMono: "JetBrainsMono Nerd Font, JetBrainsMono, monospace"

    readonly property int tCaption: 11
    readonly property int tSmall: 12
    readonly property int tBody: 14
    readonly property int tSubtitle: 16
    readonly property int tHeading: 20
    readonly property int tTitle: 24

    readonly property int weightRegular: Font.Normal
    readonly property int weightMedium: Font.Medium
    readonly property int weightBold: Font.Bold

    // ── Shell Geometry Metrics ───────────────────────────────────────────
    readonly property int barHeight: 38
    readonly property int barTopMargin: 8
    readonly property int barSideMargin: 12
    readonly property int islandRestWidth: 168
    readonly property int islandRestHeight: 34

    // ── Helper Utility ───────────────────────────────────────────────────
    function alpha(col: color, a: real): color {
        return Qt.rgba(col.r, col.g, col.b, a)
    }
}
