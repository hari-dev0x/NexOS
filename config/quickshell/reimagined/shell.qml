//@ pragma UseQApplication
// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   S H E L L   R O O T              │
// │   Phase 1 Non-invasive evaluation entry point in isolated FloatingWindow │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import Quickshell
import "tokens"
import "motion"
import "components"
import "bar"
import "companion"

ShellRoot {
    id: root

    // Non-invasive FloatingWindow:
    // - Does not interfere with the active sea-shell bar
    // - Does not claim exclusive layer surface margins
    // - Provides complete isolated evaluation of top-bar, motion, and spatial UI
    FloatingWindow {
        id: evalWindow
        title: "NexOS Reimagined · Phase 1 Evaluation Shell"
        visible: true
        color: "transparent"
        implicitWidth: 1280
        implicitHeight: 840

        DesktopWorkspace {
            anchors.fill: parent
        }
    }
}
