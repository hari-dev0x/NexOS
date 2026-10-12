// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   W O R K S P A C E S              │
// │   Workspace indicator chips with smooth active pill interpolation        │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import "../tokens"
import "../motion"

Item {
    id: root

    property int activeWorkspace: 1
    property int totalWorkspaces: 4

    signal workspaceSelected(int index)

    implicitWidth: wsRow.implicitWidth
    implicitHeight: 28

    Row {
        id: wsRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.s1

        Repeater {
            model: root.totalWorkspaces

            Rectangle {
                id: wsChip
                property int wsIndex: index + 1
                property bool isActive: wsIndex === root.activeWorkspace

                width: isActive ? 24 : 18
                height: 20
                radius: 10
                anchors.verticalCenter: parent.verticalCenter

                color: {
                    if (isActive)
                        return Tokens.accent;
                    if (wsMouse.containsMouse)
                        return Tokens.surfaceHover;
                    return Tokens.muted;
                }

                border.width: 1
                border.color: isActive ? Tokens.accentHover : Tokens.borderSubtle

                Text {
                    anchors.centerIn: parent
                    text: wsChip.wsIndex
                    font.family: Tokens.fontMono
                    font.pixelSize: Tokens.tCaption
                    font.weight: wsChip.isActive ? Tokens.weightBold : Tokens.weightRegular
                    color: wsChip.isActive ? Tokens.accentOn : Tokens.textSecondary
                }

                Behavior on width {
                    NumberAnimation {
                        duration: MotionEngine.durationMicro
                        easing.type: Easing.Bezier
                        easing.bezierCurve: MotionEngine.easeEntry
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: MotionEngine.durationMicro
                    }
                }

                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.activeWorkspace = wsChip.wsIndex;
                        root.workspaceSelected(wsChip.wsIndex);
                    }
                }
            }
        }
    }
}
