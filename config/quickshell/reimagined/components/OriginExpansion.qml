// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   O R I G I N   E X P A N S I O N  │
// │   Spatial origin-anchored panel container with Adaptive/Drop/Merge modes │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import "../tokens"
import "../motion"

Item {
    id: root

    property bool opened: false
    property var triggerItem: null
    property real originX: 0
    property real originY: Tokens.barHeight + Tokens.barTopMargin
    property real originWidth: 40
    property real originHeight: 32

    property real panelWidth: 360
    property real panelHeight: 280
    property real parentWidth: parent ? parent.width : 1920

    // Local override or inherit from MotionEngine
    property string motionMode: MotionEngine.activeMode

    signal dismissed()

    function close() {
        if (root.opened) {
            root.opened = false;
            root.dismissed();
        }
    }

    function toggle() {
        if (root.opened) {
            root.close();
        } else {
            root.open();
        }
    }

    function open() {
        if (triggerItem && root.parent) {
            var globalPos = triggerItem.mapToItem(root.parent, 0, 0);
            root.originX = globalPos.x;
            root.originY = globalPos.y + triggerItem.height;
            root.originWidth = triggerItem.width;
            root.originHeight = triggerItem.height;
        }
        root.opened = true;
    }

    default property alias contentData: panelContent.data
    property alias contentItem: panelContent

    // Coordinate math: center panel horizontally over triggering item
    readonly property real triggerCenterX: originX + (originWidth / 2)
    readonly property real idealX: triggerCenterX - (panelWidth / 2)
    readonly property real clampedX: Math.max(12, Math.min(parentWidth - panelWidth - 12, idealX))
    readonly property real targetY: originY + 8

    // Position and dimension interpolation depending on motion mode
    x: {
        if (motionMode === MotionEngine.modeMerge) {
            return opened ? clampedX : originX;
        }
        return clampedX;
    }

    y: {
        if (motionMode === MotionEngine.modeDrop) {
            return opened ? targetY : (originY - 14);
        } else if (motionMode === MotionEngine.modeMerge) {
            return opened ? targetY : originY;
        }
        // Adaptive mode
        return opened ? targetY : (targetY - 8);
    }

    width: (motionMode === MotionEngine.modeMerge) ? (opened ? panelWidth : originWidth) : panelWidth
    height: (motionMode === MotionEngine.modeMerge) ? (opened ? panelHeight : originHeight) : panelHeight

    opacity: opened ? 1.0 : 0.0
    scale: {
        if (motionMode === MotionEngine.modeMerge) return 1.0;
        if (motionMode === MotionEngine.modeDrop) return 1.0;
        // Adaptive
        return opened ? 1.0 : 0.94;
    }

    visible: opacity > 0.001 || height > originHeight + 4

    // Easing transitions for smooth physical movement
    Behavior on x {
        NumberAnimation {
            duration: (motionMode === MotionEngine.modeMerge) ? MotionEngine.durationMerge : MotionEngine.durationSpatial
            easing.type: Easing.Bezier
            easing.bezierCurve: root.opened ? MotionEngine.easeEntry : MotionEngine.easeExit
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: MotionEngine.durationSpatial
            easing.type: Easing.Bezier
            easing.bezierCurve: root.opened ? MotionEngine.easeEntry : MotionEngine.easeExit
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: (motionMode === MotionEngine.modeMerge) ? MotionEngine.durationMerge : MotionEngine.durationSpatial
            easing.type: Easing.Bezier
            easing.bezierCurve: root.opened ? MotionEngine.easeEntry : MotionEngine.easeExit
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: (motionMode === MotionEngine.modeMerge) ? MotionEngine.durationMerge : MotionEngine.durationSpatial
            easing.type: Easing.Bezier
            easing.bezierCurve: root.opened ? MotionEngine.easeEntry : MotionEngine.easeExit
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: MotionEngine.durationFast
            easing.type: Easing.Bezier
            easing.bezierCurve: root.opened ? MotionEngine.easeEntry : MotionEngine.easeExit
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: MotionEngine.durationSpatial
            easing.type: Easing.Bezier
            easing.bezierCurve: root.opened ? MotionEngine.easeEntry : MotionEngine.easeExit
        }
    }

    // Glass Background Container
    SpatialGlass {
        anchors.fill: parent
        radius: Tokens.rCard
        baseColor: Tokens.surface
        borderColor: Tokens.borderGlass
        specularRim: true

        // Visual indicator tab at top seam anchored to trigger center
        Rectangle {
            id: anchorIndicator
            x: Math.max(14, Math.min(parent.width - 26, (root.triggerCenterX - root.x) - 6))
            y: 0
            width: 12
            height: 2
            radius: 1
            color: Tokens.accent
            opacity: root.opened ? 0.9 : 0.0
            visible: motionMode !== MotionEngine.modeMerge || root.opened

            Behavior on opacity {
                NumberAnimation { duration: MotionEngine.durationFast }
            }
        }

        // Inner Content Container
        Item {
            id: panelContent
            anchors.fill: parent
            anchors.margins: Tokens.s4
            clip: true
            opacity: (root.height > 60) ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: MotionEngine.durationFast }
            }
        }
    }

    // Dismiss on Escape key
    Keys.onEscapePressed: {
        root.close();
    }
}
