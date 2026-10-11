import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   I M P A S T O   W O R K S P A C E S   W I D G E T                      │
// │   dots that stretch into a pill for the one you are on                   │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

Rectangle {
    id: root

    property bool chromeless: false

    readonly property int dotSize: 7
    readonly property int activeWidth: 26
    readonly property int slotSpacing: 10
    readonly property int activeId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    function isOccupied(wsId) {
        if (!Hyprland.workspaces) return false;
        for (var i = 0; i < Hyprland.workspaces.length; i++) {
            if (Hyprland.workspaces[i].id === wsId) return true;
        }
        return false;
    }

    implicitHeight: ImpastoTheme.capsuleHeight
    implicitWidth: layout.implicitWidth - root.slotSpacing + (root.chromeless ? 0 : 24)
    radius: ImpastoTheme.radiusPill

    color: root.chromeless ? "transparent" : ImpastoTheme.island
    border.color: ImpastoTheme.islandBorder
    border.width: root.chromeless ? 0 : 1

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 0

        Repeater {
            model: 8

            Item {
                id: slot
                required property int index
                readonly property int workspaceId: slot.index + 1
                readonly property bool occupied: root.isOccupied(slot.workspaceId)
                readonly property bool focused: root.activeId === slot.workspaceId
                readonly property bool shown: slot.workspaceId <= 4 || slot.occupied || slot.focused

                Layout.preferredWidth: slot.shown
                    ? (slot.focused ? root.activeWidth : root.dotSize) + root.slotSpacing
                    : 0
                Layout.preferredHeight: ImpastoTheme.capsuleHeight
                Layout.alignment: Qt.AlignVCenter

                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: ImpastoTheme.durationMedium; easing.type: ImpastoTheme.easing }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: Math.max(0, parent.width - root.slotSpacing)
                    height: root.dotSize
                    radius: height / 2

                    color: {
                        if (slot.focused || mouse.containsMouse)
                            return ImpastoTheme.accent;
                        return slot.occupied ? ImpastoTheme.accent : ImpastoTheme.indicatorDim;
                    }
                    opacity: slot.focused ? 1.0 : (slot.occupied ? 0.55 : 1.0)

                    Behavior on color { ColorAnimation { duration: ImpastoTheme.durationFast } }
                    Behavior on opacity { NumberAnimation { duration: ImpastoTheme.durationFast } }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        try {
                            Hyprland.dispatch("workspace " + slot.workspaceId);
                        } catch(e) {}
                    }
                }
            }
        }
    }
}
