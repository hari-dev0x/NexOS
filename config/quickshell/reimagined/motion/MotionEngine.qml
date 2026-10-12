// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   M O T I O N   E N G I N E        │
// │   Adaptive / Drop / Merge motion architecture & transitions.dev curves   │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick

pragma Singleton

QtObject {
    id: root

    // ── Motion Modes ──────────────────────────────────────────────────────
    readonly property string modeAdaptive: "adaptive" // Default: origin-scaled & translated
    readonly property string modeDrop: "drop"         // Directional downward roll from bar
    readonly property string modeMerge: "merge"       // Continuous morph from island/capsule

    // Active global motion mode (configurable at runtime)
    property string activeMode: modeAdaptive

    // System reduced-motion setting (can be forced or bound to compositor)
    property bool reducedMotion: false

    // ── Cubic-Bezier Curves (transitions.dev & CSS specs) ─────────────────
    // Entry easing: cubic-bezier(0.16, 1, 0.3, 1) — swift initial motion with smooth spring-deceleration
    readonly property var easeEntry: [0.16, 1.0, 0.3, 1.0, 1.0, 1.0]

    // Exit easing: cubic-bezier(0.7, 0, 0.84, 0) — accelerating tuck back to origin
    readonly property var easeExit: [0.7, 0.0, 0.84, 0.0, 1.0, 1.0]

    // Standard Qt Easing constants
    readonly property int standardEasing: Easing.Bezier

    // ── Canonical Durations (milliseconds) ────────────────────────────────
    readonly property int durationMicro: reducedMotion ? 0 : 160
    readonly property int durationFast: reducedMotion ? 0 : 200
    readonly property int durationSpatial: reducedMotion ? 0 : 300
    readonly property int durationMerge: reducedMotion ? 0 : 340

    // ── Easing Helper Functions ───────────────────────────────────────────
    function durationFor(type: string): int {
        if (reducedMotion) return 0;
        switch (type) {
            case "micro": return durationMicro;
            case "fast": return durationFast;
            case "spatial": return durationSpatial;
            case "merge": return durationMerge;
            default: return durationSpatial;
        }
    }
}
