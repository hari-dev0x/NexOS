// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   S P A T I A L   T O G G L E      │
// │   Tactile switch · Spring easing, Ice Blue active track, keyboard focus  │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import "../tokens"
import "../motion"

Item {
    id: root

    property bool checked: false
    property string label: ""
    property string description: ""
    property bool enabled: true

    signal toggled(bool isChecked)

    function toggle() {
        if (!root.enabled) return;
        root.checked = !root.checked;
        root.toggled(root.checked);
    }

    activeFocusOnTab: root.enabled
    implicitWidth: mainRow.implicitWidth
    implicitHeight: Math.max(26, mainRow.implicitHeight)
    opacity: root.enabled ? 1.0 : 0.45

    Keys.onPressed: (event) => {
        if (!root.enabled) return;
        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return) {
            root.toggle();
            event.accepted = true;
        }
    }

    Row {
        id: mainRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.s3

        // Switch Track Body
        Rectangle {
            id: track
            width: 44
            height: 24
            radius: 12
            anchors.verticalCenter: parent.verticalCenter

            color: {
                if (root.checked)
                    return Tokens.accent;
                if (mouseArea.containsMouse)
                    return Tokens.surfaceHover;
                return Tokens.muted;
            }

            border.width: root.activeFocus ? 2 : 1
            border.color: {
                if (root.activeFocus)
                    return root.checked ? Tokens.textPrimary : Tokens.accent;
                if (root.checked)
                    return Tokens.accentHover;
                return Tokens.borderGlass;
            }

            // Tactile Sliding Thumb
            Rectangle {
                id: thumb
                width: 18
                height: 18
                radius: 9
                anchors.verticalCenter: parent.verticalCenter
                x: root.checked ? (track.width - width - 3) : 3
                color: root.checked ? Tokens.accentOn : Tokens.textPrimary

                // Subtle top specular shine
                Rectangle {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 1
                    width: parent.width - 6
                    height: 1
                    radius: 1
                    color: Qt.rgba(1, 1, 1, 0.3)
                }

                Behavior on x {
                    NumberAnimation {
                        duration: MotionEngine.durationMicro
                        easing.type: Easing.Bezier
                        easing.bezierCurve: MotionEngine.easeEntry
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: MotionEngine.durationMicro
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

        // Optional Label and Description Column
        Column {
            visible: root.label !== "" || root.description !== ""
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: root.label
                visible: root.label !== ""
                font.family: Tokens.fontSans
                font.pixelSize: Tokens.tBody
                font.weight: Tokens.weightMedium
                color: root.checked ? Tokens.textPrimary : Tokens.textSecondary
            }

            Text {
                text: root.description
                visible: root.description !== ""
                font.family: Tokens.fontSans
                font.pixelSize: Tokens.tCaption
                color: Tokens.textSecondary
                opacity: 0.8
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            root.forceActiveFocus();
            root.toggle();
        }
    }
}
