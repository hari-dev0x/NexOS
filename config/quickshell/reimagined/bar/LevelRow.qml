// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   L E V E L   R O W                                                      │
// │   Unified control row · Device/app icon, name label, and level slider    │
// │                                                                          │
// │   Reused & adapted from Impasto (github.com/andreumassanet/impasto)      │
// │   License: GPL-3.0 · Adapted for NexOS Reimagined                        │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../tokens"
import "../motion"

Item {
    id: root

    property string glyph: ""
    property string picture: ""
    property string name: ""
    property int value: 0
    property int from: 0
    property int to: 100
    property string unit: "%"
    property bool dimmed: false
    property bool available: true

    signal moved(int value)
    signal markClicked()

    implicitWidth: parent ? parent.width : 400
    implicitHeight: 40

    RowLayout {
        anchors.fill: parent
        spacing: Tokens.s3

        // Leading glyph / application icon
        Item {
            id: mark
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignVCenter
            opacity: root.dimmed ? 0.45 : 1.0

            Image {
                anchors.fill: parent
                source: root.picture
                visible: root.picture !== "" && status === Image.Ready
                sourceSize.width: 48
                sourceSize.height: 48
                asynchronous: true
            }

            Text {
                anchors.centerIn: parent
                visible: root.picture === ""
                text: root.glyph !== "" ? root.glyph : "󰕾"
                font.family: Tokens.fontMono
                font.pixelSize: 18
                color: root.dimmed ? Tokens.textSecondary : Tokens.textPrimary
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: root.markClicked()
            }
        }

        // Name label
        Text {
            id: label
            Layout.preferredWidth: 100
            Layout.fillWidth: false
            Layout.alignment: Qt.AlignVCenter
            elide: Text.ElideRight
            text: root.name
            font.family: Tokens.fontSans
            font.pixelSize: Tokens.tBody
            font.weight: Tokens.weightMedium
            color: root.dimmed ? Tokens.textSecondary : Tokens.textPrimary
        }

        // Interactive SliderRow
        SliderRow {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            value: root.value
            from: root.from
            to: root.to
            unit: root.unit
            dimmed: root.dimmed
            available: root.available
            icon: root.glyph
            onMoved: (v) => root.moved(v)
            onIconClicked: root.markClicked()
        }
    }
}
