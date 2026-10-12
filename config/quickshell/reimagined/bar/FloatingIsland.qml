// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   F L O A T I N G   I S L A N D    │
// │   Centrally anchored compact island capsule with stable geometry         │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import "../tokens"
import "../motion"

Item {
    id: root

    property bool expanded: false
    property string activeTitle: "NexOS Reimagined"
    property string subtitle: "Phase 1 Shell"
    property bool hasMedia: true
    property bool isPlaying: true

    signal clicked()

    implicitWidth: capsuleBody.width
    implicitHeight: Tokens.islandRestHeight

    Rectangle {
        id: capsuleBody
        anchors.centerIn: parent
        width: Tokens.islandRestWidth
        height: Tokens.islandRestHeight
        radius: height / 2

        color: {
            if (islandMouse.containsMouse)
                return Tokens.surfaceElevated;
            return Tokens.islandBackground;
        }

        border.width: 1
        border.color: {
            if (root.expanded)
                return Tokens.accent;
            if (islandMouse.containsMouse)
                return Tokens.specularHighlight;
            return Tokens.borderGlass;
        }

        // Top specular hairline
        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 1
            width: parent.width - 24
            height: 1
            radius: 1
            color: root.expanded ? Tokens.alpha(Tokens.accent, 0.4) : Tokens.specularRim
        }

        // Content Row
        Row {
            anchors.centerIn: parent
            spacing: Tokens.s2

            // Tiny dynamic activity indicator (waveform / pulse)
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Repeater {
                    model: 3
                    Rectangle {
                        property real animHeight: 4 + (index * 3)
                        width: 2
                        height: root.isPlaying ? animHeight : 3
                        radius: 1
                        color: Tokens.accent

                        SequentialAnimation on height {
                            running: root.isPlaying
                            loops: Animation.Infinite
                            PropertyAnimation {
                                to: 12 - (index * 2)
                                duration: 250 + (index * 120)
                                easing.type: Easing.InOutQuad
                            }
                            PropertyAnimation {
                                to: 4 + (index * 2)
                                duration: 250 + (index * 120)
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }
            }

            // Central Status Label
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.activeTitle
                font.family: Tokens.fontSans
                font.pixelSize: Tokens.tSmall
                font.weight: Tokens.weightMedium
                color: islandMouse.containsMouse || root.expanded ? Tokens.textPrimary : Tokens.textSecondary
                elide: Text.ElideRight
                maximumLineCount: 1

                Behavior on color {
                    ColorAnimation { duration: MotionEngine.durationMicro }
                }
            }
        }

        Behavior on color {
            ColorAnimation { duration: MotionEngine.durationFast }
        }

        Behavior on border.color {
            ColorAnimation { duration: MotionEngine.durationFast }
        }

        MouseArea {
            id: islandMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.clicked();
            }
        }
    }
}
