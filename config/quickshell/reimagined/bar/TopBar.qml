// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   T O P   B A R                    │
// │   Unified spatial control surface with native morphing capsule expansion │
// │                                                                          │
// │   Derived from Impasto & transitions.dev spatial geometry models         │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import "../tokens"
import "../motion"
import "../components"
import "../services"

Item {
    id: root

    property alias openPanel: spatialSurface.activeControl

    function closeAllPanels() {
        spatialSurface.close();
    }

    implicitWidth: 1920
    implicitHeight: spatialSurface.isOpen ? (spatialSurface.targetHeight + Tokens.barTopMargin + 20) : (Tokens.barHeight + Tokens.barTopMargin)

    // ── 1. Compact Resting Top Bar Capsule ─────────────────────────────────
    Rectangle {
        id: barCapsule
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Tokens.barTopMargin
        anchors.leftMargin: Tokens.barSideMargin
        anchors.rightMargin: Tokens.barSideMargin
        height: Tokens.barHeight
        radius: height / 2
        z: 50

        // Glass Substrate styling
        color: Tokens.surfaceGlass
        border.width: 1
        border.color: Tokens.borderGlass

        // Specular top rim
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 1
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            height: 1
            color: Tokens.specularRim
        }

        // ── Left Cluster (Logo + Workspaces) ───────────────────────────
        Row {
            id: leftCluster
            anchors.left: parent.left
            anchors.leftMargin: Tokens.s2
            anchors.verticalCenter: parent.verticalCenter
            spacing: Tokens.s3

            // Official Nex Mark
            Rectangle {
                id: logoTrigger
                width: 28
                height: 28
                radius: 14
                color: logoMouse.containsMouse ? Tokens.accentContainer : "transparent"
                border.width: 1
                border.color: logoMouse.containsMouse ? Tokens.accent : "transparent"

                NexLogo {
                    anchors.centerIn: parent
                    size: 18
                    color: logoMouse.containsMouse ? Tokens.accent : Tokens.textPrimary
                }

                MouseArea {
                    id: logoMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        spatialSurface.toggle("island", centerIsland, 360, 260);
                    }
                }
            }

            // Workspaces Indicators
            WorkspacesIndicator {
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ── Geometrically Centered Floating Island ─────────────────────
        // Stable centering: strictly anchored to parent.horizontalCenter
        FloatingIsland {
            id: centerIsland
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            expanded: spatialSurface.activeControl === "island"
            onClicked: {
                spatialSurface.toggle("island", centerIsland, 360, 260);
            }
        }

        // ── Right Cluster (System Status & Quick Toggles) ──────────────
        StatusCluster {
            id: rightCluster
            anchors.right: parent.right
            anchors.rightMargin: Tokens.s2
            anchors.verticalCenter: parent.verticalCenter

            onVolumeTriggered: {
                spatialSurface.toggle("sound", rightCluster.volumeChipItem, AudioService.panelWidth, AudioService.panelHeight);
            }
            onNetworkTriggered: {
                spatialSurface.toggle("controlcenter", rightCluster.controlCenterChipItem, 380, 420);
            }
            onControlCenterTriggered: {
                spatialSurface.toggle("controlcenter", rightCluster.controlCenterChipItem, 380, 420);
            }
        }
    }

    // ── 2. Native Morphing Spatial Capsule Surface ─────────────────────────
    // Expands outward both horizontally and vertically directly from the clicked control's origin
    SpatialCapsuleSurface {
        id: spatialSurface
        anchors.fill: parent
        z: 100
    }
}
