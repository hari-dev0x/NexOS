// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   N E X   L O G O   M A R K        │
// │   Authoritative monolithic 4-blade geometric vector mark in QtQuick.Shapes│
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Shapes
import "../tokens"

Item {
    id: root

    property real size: 24
    property color color: Tokens.textPrimary
    property color accent: Tokens.accent
    property color cardColor: "transparent"
    property color rimColor: "transparent"

    implicitWidth: size
    implicitHeight: size

    // Optional framing card / badge
    Rectangle {
        anchors.fill: parent
        visible: root.cardColor !== "transparent" && root.cardColor !== ""
        radius: Math.max(4, root.size * 0.25)
        color: root.cardColor
        border.width: 1
        border.color: root.rimColor !== "transparent" ? root.rimColor : Tokens.borderGlass
    }

    Item {
        anchors.centerIn: parent
        width: 294
        height: 300
        scale: (root.size * (root.cardColor !== "transparent" ? 0.72 : 0.95)) / 300.0

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            // Part 1: Left Vertical Stem
            ShapePath {
                fillColor: root.color
                strokeColor: "transparent"
                PathSvg { path: "M0 0 L56 0 L56 300 L0 244 Z" }
            }

            // Part 2: Upper Diagonal Blade
            ShapePath {
                fillColor: root.color
                strokeColor: "transparent"
                PathSvg { path: "M56 0 L128 0 L166 145 L106 145 Z" }
            }

            // Part 3: Lower Diagonal Blade
            ShapePath {
                fillColor: root.color
                strokeColor: "transparent"
                PathSvg { path: "M188 155 L128 155 L166 300 L238 300 Z" }
            }

            // Part 4: Right Vertical Stem
            ShapePath {
                fillColor: root.color
                strokeColor: "transparent"
                PathSvg { path: "M238 56 L294 0 L294 300 L238 300 Z" }
            }
        }
    }
}
