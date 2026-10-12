// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   S P A T I A L   S L I D E R      │
// │   Interactive precision slider · Accent filled track & specular thumb    │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import "../tokens"
import "../motion"

Item {
    id: root

    property real value: 0.5
    property real minimumValue: 0.0
    property real maximumValue: 1.0
    property real stepSize: 0.05
    property string label: ""
    property string icon: ""
    property bool enabled: true

    signal valueModified(real newValue)

    activeFocusOnTab: root.enabled
    implicitWidth: 220
    implicitHeight: 38
    opacity: root.enabled ? 1.0 : 0.45

    Keys.onPressed: (event) => {
        if (!root.enabled) return;
        if (event.key === Qt.Key_Left || event.key === Qt.Key_Down) {
            root.value = Math.max(root.minimumValue, root.value - root.stepSize);
            root.valueModified(root.value);
            event.accepted = true;
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Up) {
            root.value = Math.min(root.maximumValue, root.value + root.stepSize);
            root.valueModified(root.value);
            event.accepted = true;
        }
    }

    Column {
        anchors.fill: parent
        spacing: 4

        // Header Row (Label + Percentage Display)
        Item {
            width: parent.width
            height: 18
            visible: root.label !== ""

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: root.label
                font.family: Tokens.fontSans
                font.pixelSize: Tokens.tSmall
                font.weight: Tokens.weightMedium
                color: Tokens.textSecondary
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(root.value * 100) + "%"
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.tSmall
                font.weight: Tokens.weightMedium
                color: Tokens.textPrimary
            }
        }

        // Track & Thumb Area
        Item {
            id: trackContainer
            width: parent.width
            height: 24

            // Background Track
            Rectangle {
                id: trackBg
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 6
                radius: 3
                color: Tokens.elevated
                border.width: root.activeFocus ? 1 : 0
                border.color: Tokens.accent

                // Filled Accent Track
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: Math.max(6, Math.min(trackBg.width, (root.value - root.minimumValue) / (root.maximumValue - root.minimumValue) * trackBg.width))
                    radius: 3
                    color: Tokens.accent
                }
            }

            // Interactive Thumb
            Rectangle {
                id: thumb
                property real normalizedValue: (root.value - root.minimumValue) / (root.maximumValue - root.minimumValue)
                x: Math.max(0, Math.min(trackContainer.width - width, normalizedValue * (trackContainer.width - width)))
                anchors.verticalCenter: parent.verticalCenter
                width: sliderMouse.containsMouse || sliderMouse.pressed ? 18 : 16
                height: width
                radius: width / 2
                color: Tokens.textPrimary
                border.width: 1
                border.color: Tokens.borderGlass

                // Specular rim
                Rectangle {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 1
                    width: parent.width - 4
                    height: 1
                    radius: 1
                    color: Qt.rgba(1, 1, 1, 0.4)
                }

                Behavior on width {
                    NumberAnimation {
                        duration: MotionEngine.durationMicro
                        easing.type: Easing.Bezier
                        easing.bezierCurve: MotionEngine.easeEntry
                    }
                }
            }

            MouseArea {
                id: sliderMouse
                anchors.fill: parent
                hoverEnabled: root.enabled
                cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                function updateFromPos(mouseX) {
                    var norm = Math.max(0.0, Math.min(1.0, (mouseX - (thumb.width / 2)) / (trackContainer.width - thumb.width)));
                    root.value = root.minimumValue + norm * (root.maximumValue - root.minimumValue);
                    root.valueModified(root.value);
                }

                onPressed: (mouse) => {
                    root.forceActiveFocus();
                    updateFromPos(mouse.x);
                }
                onPositionChanged: (mouse) => {
                    if (pressed) {
                        updateFromPos(mouse.x);
                    }
                }
            }
        }
    }
}
