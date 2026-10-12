// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   N E T W O R K   P A N E L        │
// │   Dedicated Wi-Fi panel expanding from network indicator chip            │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import "../tokens"
import "../motion"
import "../components"

Item {
    id: root

    property bool wifiEnabled: true
    property string activeNetwork: "Nex-Air"
    property int signalStrength: 85

    implicitWidth: 320
    implicitHeight: 220

    Column {
        anchors.fill: parent
        spacing: Tokens.s3

        // Panel Title
        Row {
            width: parent.width
            spacing: Tokens.s2

            Text {
                text: "󰤨"
                font.family: Tokens.fontMono
                font.pixelSize: 18
                color: Tokens.accent
            }

            Text {
                text: "Network & Internet"
                font.family: Tokens.fontSans
                font.pixelSize: Tokens.tBody
                font.weight: Tokens.weightBold
                color: Tokens.textPrimary
            }
        }

        // Wi-Fi Master Toggle
        SpatialToggle {
            label: "Wi-Fi Interface"
            description: "Manage wireless radio connection"
            checked: root.wifiEnabled
            onToggled: (checked) => { root.wifiEnabled = checked }
        }

        // Connected Network Card
        SpatialCard {
            width: parent.width
            cardColor: Tokens.surface
            visible: root.wifiEnabled

            Row {
                width: parent.width
                spacing: Tokens.s3

                Text {
                    text: "󰤨"
                    font.family: Tokens.fontMono
                    font.pixelSize: 20
                    color: Tokens.accent
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    width: parent.width - 50

                    Text {
                        text: root.activeNetwork
                        font.family: Tokens.fontSans
                        font.pixelSize: Tokens.tSmall
                        font.weight: Tokens.weightMedium
                        color: Tokens.textPrimary
                    }

                    Text {
                        text: "Connected, Secure · " + root.signalStrength + "% signal"
                        font.family: Tokens.fontSans
                        font.pixelSize: Tokens.tCaption
                        color: Tokens.textSecondary
                    }
                }
            }
        }
    }
}
