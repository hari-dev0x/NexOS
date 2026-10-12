// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   S T A T U S   C L U S T E R      │
// │   Right-hand system telemetry chips with origin-expansion triggers       │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import "../tokens"
import "../motion"

Item {
    id: root

    property real volumeLevel: 0.70
    property string networkSsid: "Nex-Air"
    property int batteryPercentage: 92
    property string currentTime: "10:58 AM"

    // Trigger item aliases for OriginExpansion panels
    property alias volumeChipItem: volChip
    property alias networkChipItem: netChip
    property alias controlCenterChipItem: ccChip

    signal volumeTriggered()
    signal networkTriggered()
    signal controlCenterTriggered()

    implicitWidth: clusterRow.implicitWidth
    implicitHeight: 28

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var date = new Date();
            root.currentTime = Qt.formatTime(date, "hh:mm AP");
        }
    }

    Row {
        id: clusterRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.s1

        // Volume Chip
        Rectangle {
            id: volChip
            height: 24
            width: volRow.implicitWidth + (Tokens.s2 * 2)
            radius: 12
            color: volMouse.containsMouse ? Tokens.surfaceHover : Tokens.surface
            border.width: 1
            border.color: volMouse.containsMouse ? Tokens.specularHighlight : Tokens.borderSubtle

            Row {
                id: volRow
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "󰕾"
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.tSmall
                    color: Tokens.textPrimary
                }

                Text {
                    text: Math.round(root.volumeLevel * 100) + "%"
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.tCaption
                    font.weight: Tokens.weightMedium
                    color: Tokens.textSecondary
                }
            }

            MouseArea {
                id: volMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.volumeTriggered()
            }
        }

        // Network Chip
        Rectangle {
            id: netChip
            height: 24
            width: netRow.implicitWidth + (Tokens.s2 * 2)
            radius: 12
            color: netMouse.containsMouse ? Tokens.surfaceHover : Tokens.surface
            border.width: 1
            border.color: netMouse.containsMouse ? Tokens.specularHighlight : Tokens.borderSubtle

            Row {
                id: netRow
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "󰤨"
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.tSmall
                    color: Tokens.accent
                }

                Text {
                    text: root.networkSsid
                    font.family: Tokens.fontSans
                    font.pixelSize: Tokens.tCaption
                    color: Tokens.textSecondary
                }
            }

            MouseArea {
                id: netMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.networkTriggered()
            }
        }

        // Battery Chip
        Rectangle {
            id: batChip
            height: 24
            width: batRow.implicitWidth + (Tokens.s2 * 2)
            radius: 12
            color: Tokens.surface
            border.width: 1
            border.color: Tokens.borderSubtle

            Row {
                id: batRow
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "󰁹"
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.tSmall
                    color: Tokens.success
                }

                Text {
                    text: root.batteryPercentage + "%"
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.tCaption
                    color: Tokens.textSecondary
                }
            }
        }

        // Clock Chip
        Rectangle {
            id: clockChip
            height: 24
            width: clockRow.implicitWidth + (Tokens.s2 * 2)
            radius: 12
            color: Tokens.surface
            border.width: 1
            border.color: Tokens.borderSubtle

            Row {
                id: clockRow
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: root.currentTime
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.tCaption
                    font.weight: Tokens.weightMedium
                    color: Tokens.textPrimary
                }
            }
        }

        // Control Center Quick Trigger
        Rectangle {
            id: ccChip
            width: 24
            height: 24
            radius: 12
            color: ccMouse.containsMouse ? Tokens.accentContainer : Tokens.surface
            border.width: 1
            border.color: ccMouse.containsMouse ? Tokens.accent : Tokens.borderSubtle

            Text {
                anchors.centerIn: parent
                text: "󱗼"
                font.family: Tokens.fontMono
                font.pixelSize: Tokens.tSmall
                color: ccMouse.containsMouse ? Tokens.accent : Tokens.textSecondary
            }

            MouseArea {
                id: ccMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.controlCenterTriggered()
            }
        }
    }
}
