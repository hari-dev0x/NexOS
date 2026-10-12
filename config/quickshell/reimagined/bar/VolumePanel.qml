// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   V O L U M E   P A N E L          │
// │   Dedicated audio panel expanding from volume indicator chip             │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import "../tokens"
import "../motion"
import "../components"

Item {
    id: root

    property real masterVolume: 0.70
    property bool isMuted: false

    implicitWidth: 300
    implicitHeight: 180

    Column {
        anchors.fill: parent
        spacing: Tokens.s3

        // Panel Title
        Row {
            width: parent.width
            spacing: Tokens.s2

            Text {
                text: "󰕾"
                font.family: Tokens.fontMono
                font.pixelSize: 18
                color: root.isMuted ? Tokens.danger : Tokens.accent
            }

            Text {
                text: "Audio Output"
                font.family: Tokens.fontSans
                font.pixelSize: Tokens.tBody
                font.weight: Tokens.weightBold
                color: Tokens.textPrimary
            }
        }

        // Master Volume Slider
        SpatialSlider {
            width: parent.width
            label: "Master Volume"
            value: root.masterVolume
            enabled: !root.isMuted
            onValueModified: (v) => { root.masterVolume = v }
        }

        // Mute Toggle
        SpatialToggle {
            label: "Mute Output"
            description: "Silence all audio playback"
            checked: root.isMuted
            onToggled: (checked) => { root.isMuted = checked }
        }
    }
}
