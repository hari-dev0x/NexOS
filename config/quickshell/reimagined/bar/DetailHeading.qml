// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   D E T A I L   H E A D I N G                                            │
// │   Expanded surface header · Back button, title, and current device info  │
// │                                                                          │
// │   Reused & adapted from Impasto (github.com/andreumassanet/impasto)      │
// │   License: GPL-3.0 · Adapted for NexOS Reimagined                        │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../tokens"
import "../motion"

RowLayout {
    id: root

    property string title: ""
    property string detail: ""
    property bool isLive: true

    signal back()

    Layout.fillWidth: true
    Layout.preferredHeight: 38
    spacing: Tokens.s3

    // Back / Close button
    Rectangle {
        Layout.preferredWidth: 28
        Layout.preferredHeight: 28
        Layout.alignment: Qt.AlignVCenter
        radius: 14
        color: backMouse.containsMouse ? Tokens.surfaceHover : Tokens.surface
        border.width: 1
        border.color: Tokens.borderGlass

        Text {
            anchors.centerIn: parent
            text: "󰅁"
            font.family: Tokens.fontMono
            font.pixelSize: 14
            color: Tokens.textPrimary
        }

        MouseArea {
            id: backMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.back()
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        spacing: 1

        RowLayout {
            spacing: Tokens.s2

            Text {
                text: root.title
                font.family: Tokens.fontSans
                font.pixelSize: Tokens.tBody
                font.weight: Tokens.weightBold
                color: Tokens.textPrimary
            }

            Rectangle {
                visible: root.isLive
                Layout.preferredWidth: 6
                Layout.preferredHeight: 6
                radius: 3
                color: Tokens.success
            }
        }

        Text {
            visible: text !== ""
            text: root.detail
            font.family: Tokens.fontSans
            font.pixelSize: Tokens.tCaption
            color: Tokens.textSecondary
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }
}
