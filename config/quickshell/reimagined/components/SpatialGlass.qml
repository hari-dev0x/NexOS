// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   S P A T I A L   G L A S S        │
// │   Core substrate primitive · Restrained depth, specular rim, fine border │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import "../tokens"
import "../motion"

Item {
    id: root

    property real radius: Tokens.rCard
    property real glassOpacity: 0.88
    property color baseColor: Tokens.surface
    property color borderColor: Tokens.borderGlass
    property bool specularRim: true
    property bool interactive: false
    property bool hovered: false
    property bool active: false

    default property alias contentData: contentContainer.data
    property alias contentItem: contentContainer

    implicitWidth: 0
    implicitHeight: 0

    // Ambient depth shadow outline (restrained dark edge)
    Rectangle {
        id: ambientDepth
        anchors.fill: parent
        anchors.margins: -1
        radius: root.radius + 1
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.45)
        z: -2
    }

    // Glass body substrate
    Rectangle {
        id: glassBody
        anchors.fill: parent
        radius: root.radius
        clip: true
        z: -1

        color: {
            if (root.active)
                return Tokens.accentContainer;
            if (root.interactive && root.hovered)
                return Tokens.surfaceHover;
            return Tokens.alpha(root.baseColor, root.glassOpacity);
        }

        border.width: 1
        border.color: {
            if (root.active)
                return Tokens.accent;
            if (root.interactive && root.hovered)
                return Tokens.specularHighlight;
            return root.borderColor;
        }

        // Top specular hairline highlight
        Rectangle {
            id: rimHighlight
            visible: root.specularRim
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 1
            anchors.leftMargin: Math.max(3, root.radius * 0.4)
            anchors.rightMargin: Math.max(3, root.radius * 0.4)
            height: 1
            color: root.active ? Tokens.alpha(Tokens.accent, 0.5) : Tokens.specularRim
            z: 1

            Behavior on color {
                ColorAnimation {
                    duration: MotionEngine.durationFast
                }
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: MotionEngine.durationFast
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: MotionEngine.durationFast
            }
        }
    }

    // Content container
    Item {
        id: contentContainer
        anchors.fill: parent
        clip: true
    }
}
