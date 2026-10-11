pragma Singleton

import QtQuick

// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   I M P A S T O   T H E M E                                              │
// │   design tokens ported directly from upstream andreumassanet/impasto      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

QtObject {
    id: root

    // ── ISLAND ──────────────────────────────────────────────────────────────
    // Pure black in every palette: the island is the shell's identity, not a themed surface.
    readonly property color island: "#000000"
    readonly property color islandSurface: "#141414"
    readonly property color islandSurfaceHover: "#1f1f1f"
    readonly property color islandBorder: "#262626"

    // ── SEMANTIC COLOURS ────────────────────────────────────────────────────
    readonly property color background: "#0c0c0c"
    readonly property color surface: "#141414"
    readonly property color surfaceHover: "#202020"
    readonly property color border: "#282828"
    readonly property color text: "#ffffff"
    readonly property color textMuted: "#8e8e93"
    readonly property color accent: "#0a84ff"
    readonly property color accentHover: "#409cff"
    readonly property color accentText: "#ffffff"

    readonly property color red: "#ff453a"
    readonly property color green: "#32d74b"
    readonly property color yellow: "#ffd60a"
    readonly property color blue: "#0a84ff"

    // Status indicators
    readonly property color indicator: "#ffffff"
    readonly property color indicatorDim: "#4d4d4d"
    readonly property color indicatorGood: "#32d74b"
    readonly property color indicatorWarn: "#ffd60a"
    readonly property color indicatorBad: "#ff453a"
    readonly property color indicatorTimer: "#64d2ff"

    readonly property color scrim: "#bf000000"
    readonly property color scrimText: "#ffffff"
    readonly property color hairline: "#20ffffff"

    // ── METRICS ─────────────────────────────────────────────────────────────
    readonly property int capsuleHeight: 42
    readonly property int barTopMargin: 14
    readonly property int capsuleSpacing: 10
    readonly property int barReserve: root.barTopMargin + root.capsuleHeight // 56 reserved
    readonly property int barBand: root.barReserve + 8 // 64
    readonly property int panelPadding: 20

    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 12
    readonly property int radiusLarge: 18
    readonly property int radiusPill: 999
    readonly property real pictureCorner: 0.24

    // ── TYPOGRAPHY ──────────────────────────────────────────────────────────
    readonly property string fontFamily: "Inter, sans-serif"
    readonly property string fontMono: "monospace"

    readonly property int fontSizeLabel: 10
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeRegular: 13
    readonly property int fontSizeMedium: 14
    readonly property int fontSizeLarge: 16

    // ── MOTION ──────────────────────────────────────────────────────────────
    readonly property int durationFast: 140
    readonly property int durationMedium: 200
    readonly property int durationMorph: 380
    readonly property int easing: Easing.OutCubic
}
