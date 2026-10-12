// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   T O P   B A R                    │
// │   Unified capsule bar with stable geometric centering & origin expansion │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import "../tokens"
import "../motion"
import "../components"

Item {
    id: root

    property string openPanel: "" // "island", "volume", "network", "controlcenter"

    function closeAllPanels() {
        openPanel = "";
    }

    implicitWidth: 1920
    implicitHeight: Tokens.barHeight + Tokens.barTopMargin

    // Fullscreen non-blocking dismiss layer when any panel is open
    MouseArea {
        id: outsideDismiss
        anchors.fill: parent
        z: 90
        visible: root.openPanel !== ""
        onClicked: root.closeAllPanels()
    }

    // Main Floating Top Bar Capsule
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
        z: 100

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

        // ── 1. Left Cluster (Logo + Workspaces) ──────────────────────────
        Row {
            id: leftCluster
            anchors.left: parent.left
            anchors.leftMargin: Tokens.s2
            anchors.verticalCenter: parent.verticalCenter
            spacing: Tokens.s3

            // Official Nex Mark
            Rectangle {
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
                        // Quick toggle island
                        root.openPanel = (root.openPanel === "island") ? "" : "island";
                    }
                }
            }

            // Workspaces Indicators
            WorkspacesIndicator {
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ── 2. Geometrically Centered Floating Island ────────────────────
        // Stable centering: strictly anchored to parent.horizontalCenter
        FloatingIsland {
            id: centerIsland
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            expanded: root.openPanel === "island"
            onClicked: {
                root.openPanel = (root.openPanel === "island") ? "" : "island";
            }
        }

        // ── 3. Right Cluster (System Status & Quick Toggles) ─────────────
        StatusCluster {
            id: rightCluster
            anchors.right: parent.right
            anchors.rightMargin: Tokens.s2
            anchors.verticalCenter: parent.verticalCenter

            onVolumeTriggered: {
                root.openPanel = (root.openPanel === "volume") ? "" : "volume";
            }
            onNetworkTriggered: {
                root.openPanel = (root.openPanel === "network") ? "" : "network";
            }
            onControlCenterTriggered: {
                root.openPanel = (root.openPanel === "controlcenter") ? "" : "controlcenter";
            }
        }
    }

    // ── 4. Origin Expansion Panels ───────────────────────────────────────
    // A. Island Expanded Panel
    OriginExpansion {
        id: islandExpansion
        triggerItem: centerIsland
        opened: root.openPanel === "island"
        panelWidth: 350
        panelHeight: 250
        parentWidth: root.width
        z: 200
        onDismissed: { if (root.openPanel === "island") root.openPanel = ""; }

        IslandExpandedPanel {}
    }

    // B. Volume Panel
    OriginExpansion {
        id: volumeExpansion
        triggerItem: rightCluster.volumeChipItem
        opened: root.openPanel === "volume"
        panelWidth: 320
        panelHeight: 180
        parentWidth: root.width
        z: 200
        onDismissed: { if (root.openPanel === "volume") root.openPanel = ""; }

        VolumePanel {}
    }

    // C. Network Panel
    OriginExpansion {
        id: networkExpansion
        triggerItem: rightCluster.networkChipItem
        opened: root.openPanel === "network"
        panelWidth: 320
        panelHeight: 220
        parentWidth: root.width
        z: 200
        onDismissed: { if (root.openPanel === "network") root.openPanel = ""; }

        NetworkPanel {}
    }

    // D. Control Center Panel
    OriginExpansion {
        id: ccExpansion
        triggerItem: rightCluster.controlCenterChipItem
        opened: root.openPanel === "controlcenter"
        panelWidth: 360
        panelHeight: 380
        parentWidth: root.width
        z: 200
        onDismissed: { if (root.openPanel === "controlcenter") root.openPanel = ""; }

        ControlCenterPanel {}
    }
}
