// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   S P A T I A L   C A R D          │
// │   Structured content container · Opaque elevated surface & fine borders  │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import "../tokens"
import "../motion"

Item {
    id: root

    property int padding: Tokens.s4
    property real radius: Tokens.rCard
    property color cardColor: Tokens.elevated
    property color borderColor: Tokens.borderGlass
    property bool interactive: false
    property bool hovered: false
    property bool focused: false

    default property alias contentData: cardContent.data
    property alias contentItem: cardContent

    implicitWidth: cardContent.implicitWidth + (padding * 2)
    implicitHeight: cardContent.implicitHeight + (padding * 2)

    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: root.radius
        clip: true

        color: {
            if (root.interactive && root.hovered)
                return Tokens.surfaceHover;
            return root.cardColor;
        }

        border.width: root.focused ? 2 : 1
        border.color: {
            if (root.focused)
                return Tokens.accent;
            if (root.interactive && root.hovered)
                return Tokens.specularHighlight;
            return root.borderColor;
        }

        // Top specular hairline
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 1
            anchors.leftMargin: Math.max(2, root.radius * 0.4)
            anchors.rightMargin: Math.max(2, root.radius * 0.4)
            height: 1
            color: root.focused ? Tokens.alpha(Tokens.accent, 0.4) : Tokens.specularRim
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

    Item {
        id: cardContent
        anchors.fill: parent
        anchors.margins: root.padding
        clip: true
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }
}
