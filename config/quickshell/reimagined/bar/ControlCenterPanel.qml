// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   C O N T R O L   C E N T E R      │
// │   Unified spatial control surface with quick tiles, sliders & companion  │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import "../tokens"
import "../motion"
import "../components"
import "../companion"

Item {
    id: root

    property bool bluetoothOn: true
    property bool dndOn: false
    property bool nightLightOn: false
    property real brightness: 0.85
    property real systemVolume: 0.70

    implicitWidth: 360
    implicitHeight: 380

    Column {
        anchors.fill: parent
        spacing: Tokens.s3

        // Control Center Header
        Row {
            width: parent.width
            spacing: Tokens.s2

            Text {
                text: "󱗼"
                font.family: Tokens.fontMono
                font.pixelSize: 18
                color: Tokens.accent
            }

            Text {
                text: "Control Center"
                font.family: Tokens.fontSans
                font.pixelSize: Tokens.tBody
                font.weight: Tokens.weightBold
                color: Tokens.textPrimary
            }
        }

        // Quick Tile Grid (2 columns)
        Grid {
            columns: 2
            width: parent.width
            spacing: Tokens.s2

            // Bluetooth Tile
            Rectangle {
                width: (parent.width - Tokens.s2) / 2
                height: 48
                radius: Tokens.rControl
                color: root.bluetoothOn ? Tokens.accentContainer : Tokens.surface
                border.width: 1
                border.color: root.bluetoothOn ? Tokens.accent : Tokens.borderSubtle

                Row {
                    anchors.centerIn: parent
                    spacing: Tokens.s2

                    Text {
                        text: "󰂯"
                        font.family: Tokens.fontMono
                        font.pixelSize: 18
                        color: root.bluetoothOn ? Tokens.accent : Tokens.textSecondary
                    }

                    Column {
                        Text {
                            text: "Bluetooth"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tSmall
                            font.weight: Tokens.weightMedium
                            color: Tokens.textPrimary
                        }
                        Text {
                            text: root.bluetoothOn ? "Connected" : "Off"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tCaption
                            color: Tokens.textSecondary
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.bluetoothOn = !root.bluetoothOn
                }
            }

            // Do Not Disturb Tile
            Rectangle {
                width: (parent.width - Tokens.s2) / 2
                height: 48
                radius: Tokens.rControl
                color: root.dndOn ? Tokens.accentContainer : Tokens.surface
                border.width: 1
                border.color: root.dndOn ? Tokens.accent : Tokens.borderSubtle

                Row {
                    anchors.centerIn: parent
                    spacing: Tokens.s2

                    Text {
                        text: "󰂛"
                        font.family: Tokens.fontMono
                        font.pixelSize: 18
                        color: root.dndOn ? Tokens.accent : Tokens.textSecondary
                    }

                    Column {
                        Text {
                            text: "DND"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tSmall
                            font.weight: Tokens.weightMedium
                            color: Tokens.textPrimary
                        }
                        Text {
                            text: root.dndOn ? "Enabled" : "Off"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tCaption
                            color: Tokens.textSecondary
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.dndOn = !root.dndOn
                }
            }

            // Night Light Tile
            Rectangle {
                width: (parent.width - Tokens.s2) / 2
                height: 48
                radius: Tokens.rControl
                color: root.nightLightOn ? Tokens.warningContainer : Tokens.surface
                border.width: 1
                border.color: root.nightLightOn ? Tokens.warning : Tokens.borderSubtle

                Row {
                    anchors.centerIn: parent
                    spacing: Tokens.s2

                    Text {
                        text: "󱩌"
                        font.family: Tokens.fontMono
                        font.pixelSize: 18
                        color: root.nightLightOn ? Tokens.warning : Tokens.textSecondary
                    }

                    Column {
                        Text {
                            text: "Night Light"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tSmall
                            font.weight: Tokens.weightMedium
                            color: Tokens.textPrimary
                        }
                        Text {
                            text: root.nightLightOn ? "Warm Tint" : "Off"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tCaption
                            color: Tokens.textSecondary
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.nightLightOn = !root.nightLightOn
                }
            }

            // Reduced Motion Toggle Tile
            Rectangle {
                width: (parent.width - Tokens.s2) / 2
                height: 48
                radius: Tokens.rControl
                color: MotionEngine.reducedMotion ? Tokens.accentContainer : Tokens.surface
                border.width: 1
                border.color: MotionEngine.reducedMotion ? Tokens.accent : Tokens.borderSubtle

                Row {
                    anchors.centerIn: parent
                    spacing: Tokens.s2

                    Text {
                        text: "󰑮"
                        font.family: Tokens.fontMono
                        font.pixelSize: 18
                        color: MotionEngine.reducedMotion ? Tokens.accent : Tokens.textSecondary
                    }

                    Column {
                        Text {
                            text: "Motion"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tSmall
                            font.weight: Tokens.weightMedium
                            color: Tokens.textPrimary
                        }
                        Text {
                            text: MotionEngine.reducedMotion ? "Instant (0ms)" : "Fluid Bezier"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tCaption
                            color: Tokens.textSecondary
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: MotionEngine.reducedMotion = !MotionEngine.reducedMotion
                }
            }
        }

        // Sliders Section
        SpatialSlider {
            width: parent.width
            label: "Display Brightness"
            value: root.brightness
            onValueModified: (v) => { root.brightness = v }
        }

        SpatialSlider {
            width: parent.width
            label: "System Volume"
            value: root.systemVolume
            onValueModified: (v) => { root.systemVolume = v }
        }

        // Nex Companion Compatibility Status Row
        SpatialCard {
            width: parent.width
            cardColor: Tokens.surface
            padding: Tokens.s2

            Row {
                width: parent.width
                spacing: Tokens.s3

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: NexCompanionContract.isActive ? Tokens.accentContainer : Tokens.muted
                    border.width: 1
                    border.color: NexCompanionContract.isActive ? Tokens.accent : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰚩"
                        font.family: Tokens.fontMono
                        font.pixelSize: 16
                        color: NexCompanionContract.isActive ? Tokens.accent : Tokens.textSecondary
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 120

                    Text {
                        text: "Nex Companion Layer"
                        font.family: Tokens.fontSans
                        font.pixelSize: Tokens.tSmall
                        font.weight: Tokens.weightMedium
                        color: Tokens.textPrimary
                    }

                    Text {
                        text: "State: " + NexCompanionContract.currentState + " (" + NexCompanionContract.statusMessage + ")"
                        font.family: Tokens.fontMono
                        font.pixelSize: Tokens.tCaption
                        color: NexCompanionContract.isActive ? Tokens.accent : Tokens.textSecondary
                    }
                }

                // Interactive Toggle Button to test contract state transitions safely
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 68
                    height: 24
                    radius: 12
                    color: NexCompanionContract.isActive ? Tokens.accent : Tokens.elevated
                    border.width: 1
                    border.color: Tokens.borderSubtle

                    Text {
                        anchors.centerIn: parent
                        text: NexCompanionContract.isActive ? "Active" : "Activate"
                        font.family: Tokens.fontSans
                        font.pixelSize: Tokens.tCaption
                        font.weight: Tokens.weightMedium
                        color: NexCompanionContract.isActive ? Tokens.accentOn : Tokens.textPrimary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (NexCompanionContract.isActive) {
                                NexCompanionContract.deactivate();
                            } else {
                                NexCompanionContract.activate();
                            }
                        }
                    }
                }
            }
        }
    }
}
