import QtQuick
import QtQuick.Shapes
import qs.modules.iris.style

// macOS-style clean vector Wi-Fi mark: 3 concentric wave arcs radiating from a base dot.
Item {
    id: root

    property bool wifiEnabled: true
    property bool connected: true
    property int strength: 100
    property color tint: IrisStyle.text
    property color faint: Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.28)
    property real markSize: Math.round(18 * IrisStyle.density)

    implicitWidth: root.markSize
    implicitHeight: root.markSize

    readonly property bool radioOn: root.wifiEnabled && root.enabled
    readonly property real s: Math.min(root.width, root.height) / 18
    readonly property real cx: root.width / 2
    readonly property real cy: root.height * 0.82

    readonly property bool tier1Active: root.radioOn && root.connected && root.strength > 0
    readonly property bool tier2Active: root.radioOn && root.connected && root.strength >= 35
    readonly property bool tier3Active: root.radioOn && root.connected && root.strength >= 70


    readonly property real sw: Math.max(1.3, 1.55 * root.s)

    // Base dot at the origin of the fan
    Rectangle {
        id: baseDot
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.cy - 1.25 * root.s
        width: Math.max(2, 2.5 * root.s)
        height: width
        radius: width / 2
        color: root.tier1Active ? root.tint : root.faint
    }

    Shape {
        id: wifiShape
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        // Inner arc (Tier 1)
        ShapePath {
            strokeColor: root.tier1Active ? root.tint : root.faint
            strokeWidth: root.sw
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathAngleArc {
                centerX: root.cx
                centerY: root.cy
                radiusX: 4.2 * root.s
                radiusY: 4.2 * root.s
                startAngle: -135
                sweepAngle: 90
            }
        }

        // Middle arc (Tier 2)
        ShapePath {
            strokeColor: root.tier2Active ? root.tint : root.faint
            strokeWidth: root.sw
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathAngleArc {
                centerX: root.cx
                centerY: root.cy
                radiusX: 7.8 * root.s
                radiusY: 7.8 * root.s
                startAngle: -135
                sweepAngle: 90
            }
        }

        // Outer arc (Tier 3)
        ShapePath {
            strokeColor: root.tier3Active ? root.tint : root.faint
            strokeWidth: root.sw
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathAngleArc {
                centerX: root.cx
                centerY: root.cy
                radiusX: 11.4 * root.s
                radiusY: 11.4 * root.s
                startAngle: -135
                sweepAngle: 90
            }
        }

        // Disabled slash when !radioOn
        ShapePath {
            strokeColor: !root.radioOn ? root.tint : "transparent"
            strokeWidth: Math.max(1.2, 1.4 * root.s)
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            startX: root.cx - 7 * root.s
            startY: root.cy - 12 * root.s
            PathLine {
                x: root.cx + 7 * root.s
                y: root.cy + 1 * root.s
            }
        }
    }
}
