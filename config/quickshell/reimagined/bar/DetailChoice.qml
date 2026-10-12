// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   D E T A I L   C H O I C E                                              │
// │   Selectable item row with active checkmark                              │
// │                                                                          │
// │   Reused & adapted from Impasto (github.com/andreumassanet/impasto)      │
// │   License: GPL-3.0 · Adapted for NexOS Reimagined                        │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../tokens"
import "../motion"

Rectangle {
    id: root

    property string text: ""
    property bool chosen: false
    property string icon: "󰓃"

    signal picked()

    width: parent ? parent.width : 400
    height: 36
    radius: Tokens.rControl
    color: root.chosen ? Tokens.accentContainer : (pickArea.containsMouse ? Tokens.surfaceHover : Tokens.surface)
    border.width: 1
    border.color: root.chosen ? Tokens.accent : (pickArea.containsMouse ? Tokens.specularHighlight : Tokens.borderSubtle)

    Behavior on color { ColorAnimation { duration: MotionEngine.durationFast } }
    Behavior on border.color { ColorAnimation { duration: MotionEngine.durationFast } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.s3
        anchors.rightMargin: Tokens.s3
        spacing: Tokens.s2

        Text {
            text: root.icon
            font.family: Tokens.fontMono
            font.pixelSize: 15
            color: root.chosen ? Tokens.accent : Tokens.textSecondary
        }

        Text {
            Layout.fillWidth: true
            elide: Text.ElideRight
            text: root.text
            font.family: Tokens.fontSans
            font.pixelSize: Tokens.tBody
            color: root.chosen ? Tokens.textPrimary : Tokens.textSecondary
        }

        Text {
            visible: root.chosen
            text: "󰄬"
            font.family: Tokens.fontMono
            font.pixelSize: 15
            color: Tokens.accent
        }
    }

    MouseArea {
        id: pickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.picked()
    }
}
