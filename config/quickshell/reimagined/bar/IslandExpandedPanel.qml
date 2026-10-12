// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   I S L A N D   P A N E L          │
// │   Expanded island card with media preview and real-time motion switcher  │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import "../tokens"
import "../motion"
import "../components"

Item {
    id: root

    property string trackTitle: "Liquid Glass Symphony"
    property string artistName: "NexOS Spatial Core"
    property real trackProgress: 0.42
    property bool isPlaying: true

    implicitWidth: 340
    implicitHeight: 240

    Column {
        anchors.fill: parent
        spacing: Tokens.s3

        // Media Info Header
        Row {
            width: parent.width
            spacing: Tokens.s3

            // Album Artwork Thumbnail
            Rectangle {
                width: 48
                height: 48
                radius: Tokens.rControl
                color: Tokens.elevated
                border.width: 1
                border.color: Tokens.borderGlass

                Text {
                    anchors.centerIn: parent
                    text: "󰝚"
                    font.family: Tokens.fontMono
                    font.pixelSize: 22
                    color: Tokens.accent
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                width: parent.width - 60

                Text {
                    text: root.trackTitle
                    font.family: Tokens.fontSans
                    font.pixelSize: Tokens.tBody
                    font.weight: Tokens.weightBold
                    color: Tokens.textPrimary
                    elide: Text.ElideRight
                    width: parent.width
                }

                Text {
                    text: root.artistName
                    font.family: Tokens.fontSans
                    font.pixelSize: Tokens.tSmall
                    color: Tokens.textSecondary
                    elide: Text.ElideRight
                    width: parent.width
                }
            }
        }

        // Progress Slider
        SpatialSlider {
            width: parent.width
            label: "Playback Position"
            value: root.trackProgress
            onValueModified: (v) => { root.trackProgress = v }
        }

        // Playback Controls Row
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Tokens.s4

            Rectangle {
                width: 32; height: 32; radius: 16
                color: prevMouse.containsMouse ? Tokens.surfaceHover : Tokens.surface
                border.width: 1; border.color: Tokens.borderSubtle
                Text { anchors.centerIn: parent; text: "󰒮"; font.family: Tokens.fontMono; color: Tokens.textPrimary; font.pixelSize: 14 }
                MouseArea { id: prevMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
            }

            Rectangle {
                width: 36; height: 36; radius: 18
                color: Tokens.accent
                Text { anchors.centerIn: parent; text: root.isPlaying ? "󰏤" : "󰐊"; font.family: Tokens.fontMono; color: Tokens.accentOn; font.pixelSize: 16 }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.isPlaying = !root.isPlaying
                }
            }

            Rectangle {
                width: 32; height: 32; radius: 16
                color: nextMouse.containsMouse ? Tokens.surfaceHover : Tokens.surface
                border.width: 1; border.color: Tokens.borderSubtle
                Text { anchors.centerIn: parent; text: "󰒭"; font.family: Tokens.fontMono; color: Tokens.textPrimary; font.pixelSize: 14 }
                MouseArea { id: nextMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
            }
        }

        // Motion Engine Mode Switcher Bar
        Rectangle {
            width: parent.width
            height: 32
            radius: Tokens.rControl
            color: Tokens.surface
            border.width: 1
            border.color: Tokens.borderSubtle

            Row {
                anchors.centerIn: parent
                spacing: Tokens.s1

                // Mode: Adaptive
                Rectangle {
                    width: 96; height: 24; radius: 6
                    color: MotionEngine.activeMode === MotionEngine.modeAdaptive ? Tokens.accent : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "Adaptive"
                        font.family: Tokens.fontSans
                        font.pixelSize: Tokens.tCaption
                        font.weight: Tokens.weightMedium
                        color: MotionEngine.activeMode === MotionEngine.modeAdaptive ? Tokens.accentOn : Tokens.textSecondary
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MotionEngine.activeMode = MotionEngine.modeAdaptive
                    }
                }

                // Mode: Drop
                Rectangle {
                    width: 76; height: 24; radius: 6
                    color: MotionEngine.activeMode === MotionEngine.modeDrop ? Tokens.accent : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "Drop"
                        font.family: Tokens.fontSans
                        font.pixelSize: Tokens.tCaption
                        font.weight: Tokens.weightMedium
                        color: MotionEngine.activeMode === MotionEngine.modeDrop ? Tokens.accentOn : Tokens.textSecondary
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MotionEngine.activeMode = MotionEngine.modeDrop
                    }
                }

                // Mode: Merge
                Rectangle {
                    width: 76; height: 24; radius: 6
                    color: MotionEngine.activeMode === MotionEngine.modeMerge ? Tokens.accent : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "Merge"
                        font.family: Tokens.fontSans
                        font.pixelSize: Tokens.tCaption
                        font.weight: Tokens.weightMedium
                        color: MotionEngine.activeMode === MotionEngine.modeMerge ? Tokens.accentOn : Tokens.textSecondary
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MotionEngine.activeMode = MotionEngine.modeMerge
                    }
                }
            }
        }
    }
}
