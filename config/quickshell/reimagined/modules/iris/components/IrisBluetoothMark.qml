import QtQuick
import QtQuick.Shapes
import qs.modules.iris.style

// macOS-style clean vector Bluetooth mark: slender Nordic bindrune with round caps and joins, zero background box.
Item {
    id: root

    property bool btEnabled: true
    property bool connected: false
    property color tint: IrisStyle.text
    property color faint: Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.3)
    property real markSize: Math.round(18 * IrisStyle.density)

    implicitWidth: root.markSize
    implicitHeight: root.markSize

    readonly property bool radioOn: root.btEnabled && root.enabled
    readonly property real s: Math.min(root.width, root.height) / 18
    readonly property real cx: root.width / 2
    readonly property real cy: root.height / 2
    readonly property real dx: 3.6 * root.s
    readonly property real dy: 3.6 * root.s
    readonly property real yTop: root.cy - 6.8 * root.s
    readonly property real yBottom: root.cy + 6.8 * root.s
    readonly property real sw: Math.max(1.3, 1.55 * root.s)

    readonly property color activeColor: !root.radioOn ? root.faint : root.tint


    Shape {
        id: btShape
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        // Slender bindrune path
        ShapePath {
            strokeColor: root.activeColor
            strokeWidth: root.sw
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            fillColor: "transparent"

            startX: root.cx - root.dx
            startY: root.cy + root.dy

            PathLine { x: root.cx + root.dx; y: root.cy - root.dy }
            PathLine { x: root.cx; y: root.yTop }
            PathLine { x: root.cx; y: root.yBottom }
            PathLine { x: root.cx + root.dx; y: root.cy + root.dy }
            PathLine { x: root.cx - root.dx; y: root.cy - root.dy }
        }

        // Disabled slash when !radioOn
        ShapePath {
            strokeColor: !root.radioOn ? root.tint : "transparent"
            strokeWidth: Math.max(1.2, 1.4 * root.s)
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            startX: root.cx - 5.5 * root.s
            startY: root.cy - 6.5 * root.s
            PathLine {
                x: root.cx + 5.5 * root.s
                y: root.cy + 6.5 * root.s
            }
        }
    }
}
