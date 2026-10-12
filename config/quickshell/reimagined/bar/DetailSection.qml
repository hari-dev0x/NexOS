// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   D E T A I L   S E C T I O N                                            │
// │   Titled group of controls inside an expanded surface                    │
// │                                                                          │
// │   Reused & adapted from Impasto (github.com/andreumassanet/impasto)      │
// │   License: GPL-3.0 · Adapted for NexOS Reimagined                        │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../tokens"

ColumnLayout {
    id: root

    property string title: ""
    default property alias rows: list.data

    Layout.fillWidth: true
    spacing: Tokens.s2

    Text {
        Layout.preferredHeight: 20
        verticalAlignment: Text.AlignVCenter
        text: root.title
        font.family: Tokens.fontSans
        font.pixelSize: Tokens.tCaption
        font.weight: Tokens.weightBold
        font.capitalization: Font.AllUppercase
        color: Tokens.textSecondary
    }

    Column {
        id: list
        Layout.fillWidth: true
        spacing: Tokens.s2
    }
}
