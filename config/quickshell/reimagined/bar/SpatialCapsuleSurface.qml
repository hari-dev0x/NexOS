// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   S P A T I A L   C A P S U L E   S U R F A C E                          │
// │   Native morphing control surface · Origin-based horizontal & vertical    │
// │   expansion directly from the top-bar capsule                            │
// │                                                                          │
// │   Derived from Impasto & transitions.dev spatial geometry models         │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../tokens"
import "../motion"
import "../components"

Item {
    id: root

    property string activeControl: ""
    property var activeTriggerItem: null
    property real targetWidth: 440
    property real targetHeight: 380

    readonly property bool isOpen: activeControl !== ""

    signal dismissed()

    function close() {
        if (root.isOpen) {
            root.activeControl = "";
            root.activeTriggerItem = null;
            root.dismissed();
        }
    }

    function toggle(controlId, triggerItem, reqWidth, reqHeight) {
        if (root.activeControl === controlId) {
            root.close();
            return;
        }
        root.open(controlId, triggerItem, reqWidth, reqHeight);
    }

    function open(controlId, triggerItem, reqWidth, reqHeight) {
        root.activeTriggerItem = triggerItem;
        root.targetWidth = reqWidth;
        root.targetHeight = reqHeight;
        root.activeControl = controlId;
    }

    implicitWidth: parent ? parent.width : 1920
    implicitHeight: parent ? parent.height : 1080

    // Full-screen outside click dismiss layer (only active when surface is open)
    MouseArea {
        id: dismissBackdrop
        anchors.fill: parent
        enabled: root.isOpen
        z: 90
        onClicked: (mouse) => {
            root.close();
        }
    }

    // Geometry math: track origin of active trigger
    readonly property real triggerRelX: {
        if (!activeTriggerItem || !root.parent)
            return (root.width - targetWidth) / 2;
        var p = activeTriggerItem.mapToItem(root, 0, 0);
        return p.x;
    }

    readonly property real triggerRelWidth: activeTriggerItem ? activeTriggerItem.width : 40
    readonly property real triggerRelHeight: activeTriggerItem ? activeTriggerItem.height : Tokens.barHeight
    readonly property real triggerCenterX: triggerRelX + (triggerRelWidth / 2)

    // Clamped target bounds
    readonly property real clampedTargetX: {
        var ideal = triggerCenterX - (targetWidth / 2);
        return Math.max(Tokens.barSideMargin, Math.min(root.width - targetWidth - Tokens.barSideMargin, ideal));
    }

    // ── Physical Morphing Capsule Body ─────────────────────────────────────
    Rectangle {
        id: morphBody
        z: 100

        // Single coordinated geometry interpolation per axis
        x: root.isOpen ? root.clampedTargetX : root.triggerRelX
        y: Tokens.barTopMargin
        width: root.isOpen ? root.targetWidth : root.triggerRelWidth
        height: root.isOpen ? root.targetHeight : Tokens.barHeight
        radius: root.isOpen ? Tokens.rMajor : (Tokens.barHeight / 2)

        color: Tokens.surfaceElevatedGlass
        border.width: 1
        border.color: root.isOpen ? Tokens.borderAccent : Tokens.borderGlass

        opacity: root.isOpen ? 1.0 : 0.0
        visible: opacity > 0.001 || height > Tokens.barHeight + 4
        clip: true

        // Top specular hairline rim
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 1
            anchors.leftMargin: Math.max(4, parent.radius * 0.4)
            anchors.rightMargin: Math.max(4, parent.radius * 0.4)
            height: 1
            color: root.isOpen ? Tokens.alpha(Tokens.accent, 0.4) : Tokens.specularRim
        }

        // Animated geometry transitions (Impasto durationMorph / Easing.OutCubic)
        Behavior on x {
            NumberAnimation {
                duration: MotionEngine.durationMerge
                easing.type: Easing.OutCubic
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: MotionEngine.durationMerge
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: MotionEngine.durationMerge
                easing.type: Easing.OutCubic
            }
        }
        Behavior on radius {
            NumberAnimation {
                duration: MotionEngine.durationFast
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: MotionEngine.durationFast
                easing.type: Easing.OutCubic
            }
        }
        Behavior on border.color {
            ColorAnimation { duration: MotionEngine.durationFast }
        }

        // Internal content hosting area
        Flickable {
            id: contentFlickable
            anchors.fill: parent
            anchors.margins: Tokens.s4
            contentWidth: width
            contentHeight: contentLoader.implicitHeight
            clip: true
            opacity: (morphBody.height > Tokens.barHeight + 20) ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: MotionEngine.durationFast
                    easing.type: Easing.OutCubic
                }
            }

            Loader {
                id: contentLoader
                width: parent.width
                sourceComponent: {
                    switch (root.activeControl) {
                        case "sound":
                        case "volume":
                            return soundComponent;
                        case "island":
                            return islandComponent;
                        case "controlcenter":
                            return controlCenterComponent;
                        default:
                            return null;
                    }
                }
            }
        }

        // Consume all clicks inside the expanded surface so they never close the panel
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: {}
        }
    }

    // ── Pre-loaded Components for Zero-Latency Switching ───────────────────
    Component {
        id: soundComponent
        SoundDetail {
            onCloseRequested: root.close()
        }
    }

    Component {
        id: islandComponent
        IslandExpandedPanel {}
    }

    Component {
        id: controlCenterComponent
        ControlCenterPanel {}
    }

    // Keyboard dismiss on Escape
    Keys.onEscapePressed: {
        root.close();
    }
}
