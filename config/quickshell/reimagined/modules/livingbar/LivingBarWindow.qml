pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.livingbar

/**
 * LivingBarWindow — Dedicated layer-shell surface for the floating Living Bar.
 *
 * Implements:
 *  - Floating desktop placement with drag-and-drop repositioning.
 *  - Persistent coordinate restoration via LivingBarState.
 *  - Screen boundary clamping (cannot be dragged off-screen).
 *  - Zero Niri window interference: layer-shell mask is strictly restricted to
 *    the active capsule bounds, passing through all clicks outside the capsule.
 */
PanelWindow {
    id: root

    property var targetScreen: {
        if (LivingBarState.screenName && LivingBarState.screenName.length > 0) {
            for (let i = 0; i < Quickshell.screens.length; ++i) {
                if (Quickshell.screens[i].name === LivingBarState.screenName) {
                    return Quickshell.screens[i]
                }
            }
        }
        return Quickshell.screens[0] ?? null
    }
    screen: targetScreen
    visible: true
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusiveZone: 0 // Do not push or resize Niri tiled windows
    WlrLayershell.namespace: "nex:livingbar"
    WlrLayershell.layer: WlrLayer.Top
    // Allow keyboard focus on demand when expanded so TextInput can receive keystrokes on Wayland
    WlrLayershell.keyboardFocus: livingBar.expanded ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // Mask strictly set to the capsule item so the rest of the screen clicks through
    mask: Region { item: barContainer }

    readonly property real screenW: targetScreen?.width ?? 1920
    readonly property real screenH: targetScreen?.height ?? 1080

    property real dragOffsetX: 0
    property real dragOffsetY: 0

    readonly property real basePosX: {
        if (LivingBarState.hasCustomPos) {
            return Math.max(8, Math.min(screenW - barContainer.width - 8, LivingBarState.posX))
        }
        return Math.round((screenW - barContainer.width) / 2)
    }

    readonly property real basePosY: {
        if (LivingBarState.hasCustomPos) {
            return Math.max(8, Math.min(screenH - barContainer.height - 8, LivingBarState.posY))
        }
        return 8
    }

    Item {
        id: barContainer
        x: root.basePosX + root.dragOffsetX
        y: root.basePosY + root.dragOffsetY
        width: livingBar.implicitWidth
        height: livingBar.implicitHeight

        LivingBar {
            id: livingBar
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            onDragMoved: (deltaX, deltaY) => {
                const tentativeX = root.basePosX + root.dragOffsetX + deltaX
                const tentativeY = root.basePosY + root.dragOffsetY + deltaY
                const clampedX = Math.max(8, Math.min(root.screenW - barContainer.width - 8, tentativeX))
                const clampedY = Math.max(8, Math.min(root.screenH - barContainer.height - 8, tentativeY))
                root.dragOffsetX = clampedX - root.basePosX
                root.dragOffsetY = clampedY - root.basePosY
            }

            onDragReleased: {
                const finalX = root.basePosX + root.dragOffsetX
                const finalY = root.basePosY + root.dragOffsetY
                root.dragOffsetX = 0
                root.dragOffsetY = 0
                LivingBarState.setPosition(finalX, finalY, root.targetScreen?.name ?? "")
            }
        }
    }
}
