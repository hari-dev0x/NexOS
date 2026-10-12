// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   S L I D E R   R O W                                                    │
// │   Tactile level control · Icon, track and value readout                  │
// │                                                                          │
// │   Reused & adapted from Impasto (github.com/andreumassanet/impasto)      │
// │   License: GPL-3.0 · Adapted for NexOS Reimagined                        │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../tokens"
import "../motion"

Item {
    id: root

    property string icon: ""
    property int value: 0
    property int from: 0
    property int to: 100
    property string unit: "%"
    property bool available: true
    property bool dimmed: false

    signal moved(int value)
    signal iconClicked()

    implicitHeight: 36
    implicitWidth: 240

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: sliderMouse.containsMouse ? Tokens.surfaceHover : Tokens.elevated
        border.color: sliderMouse.containsMouse ? Tokens.specularHighlight : Tokens.borderGlass
        border.width: 1
        opacity: root.available ? 1.0 : 0.45

        Behavior on border.color { ColorAnimation { duration: MotionEngine.durationFast } }
        Behavior on color { ColorAnimation { duration: MotionEngine.durationFast } }

        // Filled accent track
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(parent.height, parent.width * Math.max(0, Math.min(1.0, (root.value - root.from) / (root.to - root.from))))
            radius: parent.radius
            color: root.dimmed ? Tokens.muted : Tokens.accent
            opacity: root.dimmed ? 0.8 : 0.95

            Behavior on width {
                NumberAnimation {
                    duration: MotionEngine.durationFast
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color { ColorAnimation { duration: MotionEngine.durationFast } }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 14
            spacing: Tokens.s2

            Text {
                text: root.icon
                font.family: Tokens.fontMono
                font.pixelSize: 15
                color: root.dimmed ? Tokens.textSecondary : Tokens.accentOn

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.iconClicked()
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: `${root.value}${root.unit}`
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.tSmall
                font.weight: Tokens.weightBold
                color: root.dimmed ? Tokens.textSecondary : Tokens.textPrimary
            }
        }

        MouseArea {
            id: sliderMouse
            anchors.fill: parent
            hoverEnabled: root.available
            cursorShape: root.available ? Qt.PointingHandCursor : Qt.ArrowCursor

            function updateFromPos(mouseX) {
                var norm = Math.max(0.0, Math.min(1.0, mouseX / parent.width));
                var newVal = Math.round(root.from + norm * (root.to - root.from));
                root.moved(newVal);
            }

            onPressed: (mouse) => updateFromPos(mouse.x)
            onPositionChanged: (mouse) => {
                if (pressed) updateFromPos(mouse.x);
            }
        }
    }
}
