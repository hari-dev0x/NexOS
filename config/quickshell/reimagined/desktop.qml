// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   D E S K T O P   W O R K S P A C E│
// │   Phase 1 Minimum Desktop Workspace for evaluation & interaction testing  │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts
import "tokens"
import "motion"
import "components"
import "bar"
import "companion"

Item {
    id: root

    implicitWidth: 1280
    implicitHeight: 820

    // Canvas background using canonical token #0C0E14
    Rectangle {
        anchors.fill: parent
        color: Tokens.background

        // Subtle spatial ambient highlight
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.8
            height: parent.height * 0.8
            radius: width / 2
            color: Tokens.alpha(Tokens.accent, 0.02)
        }
    }

    // Top Bar Instance (Unified capsule + Centered Island + Origin Panels)
    TopBar {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: 100
    }

    // Evaluation Workspace Area below the Top Bar
    Flickable {
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Tokens.s4
        contentWidth: mainColumn.width
        contentHeight: mainColumn.implicitHeight + (Tokens.s8 * 2)
        clip: true

        Column {
            id: mainColumn
            width: Math.min(1200, root.width - (Tokens.s6 * 2))
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Tokens.s4

            // Header Banner
            SpatialCard {
                width: parent.width
                cardColor: Tokens.surface
                padding: Tokens.s4

                Row {
                    width: parent.width
                    spacing: Tokens.s4

                    Rectangle {
                        width: 48
                        height: 48
                        radius: Tokens.rControl
                        color: Tokens.elevated
                        border.width: 1
                        border.color: Tokens.borderGlass

                        NexLogo {
                            anchors.centerIn: parent
                            size: 30
                            color: Tokens.accent
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Text {
                            text: "NexOS Reimagined — Phase 1 Evaluation Workspace"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tHeading
                            font.weight: Tokens.weightBold
                            color: Tokens.textPrimary
                        }

                        Text {
                            text: "Canonical design tokens, spatial surfaces, adaptive Drop/Merge motion, and centered floating island"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tSmall
                            color: Tokens.textSecondary
                        }
                    }
                }
            }

            // Grid of 4 Interactive Evaluation Cards
            Grid {
                columns: root.width > 900 ? 2 : 1
                width: parent.width
                spacing: Tokens.s4

                // ── Card 1: Canonical Design System Tokens ──────────────────
                SpatialCard {
                    width: (parent.width - Tokens.s4) / (root.width > 900 ? 2 : 1)
                    cardColor: Tokens.surface
                    padding: Tokens.s4

                    Column {
                        width: parent.width
                        spacing: Tokens.s3

                        Text {
                            text: "1. Canonical Design System Tokens"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tSubtitle
                            font.weight: Tokens.weightBold
                            color: Tokens.textPrimary
                        }

                        // Color swatches row
                        Text {
                            text: "Color Palette & Token Mapping:"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tSmall
                            color: Tokens.textSecondary
                        }

                        Flow {
                            width: parent.width
                            spacing: Tokens.s2

                            Repeater {
                                model: [
                                    { name: "Background", color: Tokens.background, hex: "#0C0E14" },
                                    { name: "Surface", color: Tokens.surface, hex: "#12151D" },
                                    { name: "Elevated", color: Tokens.elevated, hex: "#1E2433" },
                                    { name: "Primary", color: Tokens.textPrimary, hex: "#E2E8F0" },
                                    { name: "Secondary", color: Tokens.textSecondary, hex: "#94A3B8" },
                                    { name: "Ice Blue", color: Tokens.accent, hex: "#76A9FA" },
                                    { name: "Danger", color: Tokens.danger, hex: "#F87171" },
                                    { name: "Muted", color: Tokens.muted, hex: "#475569" }
                                ]

                                Rectangle {
                                    width: 120
                                    height: 38
                                    radius: Tokens.rControl
                                    color: modelData.color
                                    border.width: 1
                                    border.color: Tokens.borderGlass

                                    Column {
                                        anchors.centerIn: parent
                                        Text {
                                            text: modelData.name
                                            font.family: Tokens.fontSans
                                            font.pixelSize: 10
                                            font.weight: Tokens.weightMedium
                                            color: (modelData.name === "Primary" || modelData.name === "Ice Blue") ? "#0C0E14" : "#E2E8F0"
                                        }
                                        Text {
                                            text: modelData.hex
                                            font.family: Tokens.fontMono
                                            font.pixelSize: 9
                                            color: (modelData.name === "Primary" || modelData.name === "Ice Blue") ? "#1E2433" : "#94A3B8"
                                        }
                                    }
                                }
                            }
                        }

                        // Nominal Radii & Spacing
                        Text {
                            text: "Nominal Radii & 4px Spacing Scale:"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tSmall
                            color: Tokens.textSecondary
                        }

                        Row {
                            spacing: Tokens.s2
                            Rectangle {
                                width: 70; height: 26; radius: Tokens.rControl
                                color: Tokens.elevated; border.width: 1; border.color: Tokens.borderSubtle
                                Text { anchors.centerIn: parent; text: "10px Ctrl"; font.family: Tokens.fontMono; font.pixelSize: 10; color: Tokens.textPrimary }
                            }
                            Rectangle {
                                width: 70; height: 26; radius: Tokens.rCard
                                color: Tokens.elevated; border.width: 1; border.color: Tokens.borderSubtle
                                Text { anchors.centerIn: parent; text: "16px Card"; font.family: Tokens.fontMono; font.pixelSize: 10; color: Tokens.textPrimary }
                            }
                            Rectangle {
                                width: 76; height: 26; radius: Tokens.rMajor
                                color: Tokens.elevated; border.width: 1; border.color: Tokens.borderSubtle
                                Text { anchors.centerIn: parent; text: "24px Major"; font.family: Tokens.fontMono; font.pixelSize: 10; color: Tokens.textPrimary }
                            }
                            Rectangle {
                                width: 60; height: 26; radius: 13
                                color: Tokens.elevated; border.width: 1; border.color: Tokens.borderSubtle
                                Text { anchors.centerIn: parent; text: "Pill"; font.family: Tokens.fontMono; font.pixelSize: 10; color: Tokens.textPrimary }
                            }
                        }
                    }
                }

                // ── Card 2: Spatial Surface & Interactive Controls ──────────
                SpatialCard {
                    width: (parent.width - Tokens.s4) / (root.width > 900 ? 2 : 1)
                    cardColor: Tokens.surface
                    padding: Tokens.s4

                    Column {
                        width: parent.width
                        spacing: Tokens.s3

                        Text {
                            text: "2. Spatial Component Language"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tSubtitle
                            font.weight: Tokens.weightBold
                            color: Tokens.textPrimary
                        }

                        // SpatialToggle Demonstration
                        SpatialToggle {
                            label: "Hardware Acceleration"
                            description: "Tactile switch with spring easing"
                            checked: true
                        }

                        SpatialToggle {
                            label: "High Contrast Inks"
                            description: "Toggle accessible text rendering"
                            checked: false
                        }

                        // SpatialSlider Demonstration
                        SpatialSlider {
                            width: parent.width
                            label: "Surface Glass Opacity"
                            value: 0.82
                        }

                        SpatialSlider {
                            width: parent.width
                            label: "Animation Velocity"
                            value: 0.60
                        }
                    }
                }

                // ── Card 3: Adaptive Drop/Merge Motion Engine ───────────────
                SpatialCard {
                    width: (parent.width - Tokens.s4) / (root.width > 900 ? 2 : 1)
                    cardColor: Tokens.surface
                    padding: Tokens.s4

                    Column {
                        width: parent.width
                        spacing: Tokens.s3

                        Text {
                            text: "3. Motion Engine (transitions.dev Bezier)"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tSubtitle
                            font.weight: Tokens.weightBold
                            color: Tokens.textPrimary
                        }

                        Text {
                            text: "Active Motion Mode: " + MotionEngine.activeMode.toUpperCase()
                            font.family: Tokens.fontMono
                            font.pixelSize: Tokens.tSmall
                            font.weight: Tokens.weightBold
                            color: Tokens.accent
                        }

                        // Mode Selector Buttons
                        Row {
                            spacing: Tokens.s2

                            Rectangle {
                                width: 90; height: 32; radius: Tokens.rControl
                                color: MotionEngine.activeMode === MotionEngine.modeAdaptive ? Tokens.accent : Tokens.elevated
                                border.width: 1; border.color: Tokens.borderGlass
                                Text {
                                    anchors.centerIn: parent
                                    text: "Adaptive"
                                    font.family: Tokens.fontSans
                                    font.pixelSize: Tokens.tSmall
                                    color: MotionEngine.activeMode === MotionEngine.modeAdaptive ? Tokens.accentOn : Tokens.textPrimary
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: MotionEngine.activeMode = MotionEngine.modeAdaptive
                                }
                            }

                            Rectangle {
                                width: 70; height: 32; radius: Tokens.rControl
                                color: MotionEngine.activeMode === MotionEngine.modeDrop ? Tokens.accent : Tokens.elevated
                                border.width: 1; border.color: Tokens.borderGlass
                                Text {
                                    anchors.centerIn: parent
                                    text: "Drop"
                                    font.family: Tokens.fontSans
                                    font.pixelSize: Tokens.tSmall
                                    color: MotionEngine.activeMode === MotionEngine.modeDrop ? Tokens.accentOn : Tokens.textPrimary
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: MotionEngine.activeMode = MotionEngine.modeDrop
                                }
                            }

                            Rectangle {
                                width: 70; height: 32; radius: Tokens.rControl
                                color: MotionEngine.activeMode === MotionEngine.modeMerge ? Tokens.accent : Tokens.elevated
                                border.width: 1; border.color: Tokens.borderGlass
                                Text {
                                    anchors.centerIn: parent
                                    text: "Merge"
                                    font.family: Tokens.fontSans
                                    font.pixelSize: Tokens.tSmall
                                    color: MotionEngine.activeMode === MotionEngine.modeMerge ? Tokens.accentOn : Tokens.textPrimary
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: MotionEngine.activeMode = MotionEngine.modeMerge
                                }
                            }
                        }

                        SpatialToggle {
                            label: "System Reduced Motion"
                            description: "Disables animations (0ms snap duration)"
                            checked: MotionEngine.reducedMotion
                            onToggled: (checked) => { MotionEngine.reducedMotion = checked }
                        }

                        // Test Origin Expansion Triggers
                        Text {
                            text: "Test Top Bar Panel Triggers:"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tSmall
                            color: Tokens.textSecondary
                        }

                        Row {
                            spacing: Tokens.s2

                            Rectangle {
                                width: 85; height: 28; radius: Tokens.rControl
                                color: Tokens.elevated; border.width: 1; border.color: Tokens.borderSubtle
                                Text { anchors.centerIn: parent; text: "Island Panel"; font.family: Tokens.fontSans; font.pixelSize: 11; color: Tokens.textPrimary }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: topBar.openPanel = (topBar.openPanel === "island") ? "" : "island"
                                }
                            }

                            Rectangle {
                                width: 85; height: 28; radius: Tokens.rControl
                                color: Tokens.elevated; border.width: 1; border.color: Tokens.borderSubtle
                                Text { anchors.centerIn: parent; text: "Volume Panel"; font.family: Tokens.fontSans; font.pixelSize: 11; color: Tokens.textPrimary }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: topBar.openPanel = (topBar.openPanel === "volume") ? "" : "volume"
                                }
                            }

                            Rectangle {
                                width: 95; height: 28; radius: Tokens.rControl
                                color: Tokens.elevated; border.width: 1; border.color: Tokens.borderSubtle
                                Text { anchors.centerIn: parent; text: "Control Center"; font.family: Tokens.fontSans; font.pixelSize: 11; color: Tokens.textPrimary }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: topBar.openPanel = (topBar.openPanel === "controlcenter") ? "" : "controlcenter"
                                }
                            }
                        }
                    }
                }

                // ── Card 4: Hidden Nex Companion Compatibility Interface ────
                SpatialCard {
                    width: (parent.width - Tokens.s4) / (root.width > 900 ? 2 : 1)
                    cardColor: Tokens.surface
                    padding: Tokens.s4

                    Column {
                        width: parent.width
                        spacing: Tokens.s3

                        Text {
                            text: "4. Nex Companion Compatibility Layer"
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tSubtitle
                            font.weight: Tokens.weightBold
                            color: Tokens.textPrimary
                        }

                        Text {
                            text: "Dormant contract interface with zero background threads or polling."
                            font.family: Tokens.fontSans
                            font.pixelSize: Tokens.tSmall
                            color: Tokens.textSecondary
                        }

                        // Contract state readout
                        Row {
                            spacing: Tokens.s2

                            Rectangle {
                                width: 14; height: 14; radius: 7
                                anchors.verticalCenter: parent.verticalCenter
                                color: {
                                    switch(NexCompanionContract.currentState) {
                                        case NexCompanionContract.stateIdle: return Tokens.success;
                                        case NexCompanionContract.stateWorking: return Tokens.accent;
                                        case NexCompanionContract.stateWaiting: return Tokens.warning;
                                        default: return Tokens.muted;
                                    }
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Current Contract State: " + NexCompanionContract.currentState.toUpperCase()
                                font.family: Tokens.fontMono
                                font.pixelSize: Tokens.tSmall
                                font.weight: Tokens.weightMedium
                                color: Tokens.textPrimary
                            }
                        }

                        // Interactive Contract Test Actions
                        Row {
                            spacing: Tokens.s2

                            Rectangle {
                                width: 80; height: 30; radius: Tokens.rControl
                                color: NexCompanionContract.isActive ? Tokens.danger : Tokens.accent
                                border.width: 1; border.color: Tokens.borderGlass
                                Text {
                                    anchors.centerIn: parent
                                    text: NexCompanionContract.isActive ? "Deactivate" : "Activate"
                                    font.family: Tokens.fontSans
                                    font.pixelSize: 11
                                    font.weight: Tokens.weightMedium
                                    color: Tokens.accentOn
                                }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (NexCompanionContract.isActive) {
                                            NexCompanionContract.deactivate();
                                        } else {
                                            NexCompanionContract.activate();
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: 95; height: 30; radius: Tokens.rControl
                                color: Tokens.elevated; border.width: 1; border.color: Tokens.borderSubtle
                                visible: NexCompanionContract.isActive
                                Text {
                                    anchors.centerIn: parent
                                    text: "Simulate Query"
                                    font.family: Tokens.fontSans
                                    font.pixelSize: 11
                                    color: Tokens.textPrimary
                                }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        NexCompanionContract.dispatchQuery("System status telemetry query");
                                    }
                                }
                            }

                            Rectangle {
                                width: 75; height: 30; radius: Tokens.rControl
                                color: Tokens.elevated; border.width: 1; border.color: Tokens.borderSubtle
                                visible: NexCompanionContract.isActive
                                Text {
                                    anchors.centerIn: parent
                                    text: "Reset (Idle)"
                                    font.family: Tokens.fontSans
                                    font.pixelSize: 11
                                    color: Tokens.textPrimary
                                }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        NexCompanionContract.cancelCurrentTask();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
