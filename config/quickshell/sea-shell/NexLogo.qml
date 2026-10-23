// NexUI official mark, drawn natively from the authoritative geometric N
// Four primary monolithic components: Left Vertical Stem, Upper Diagonal Blade,
// Lower Diagonal Blade, and Right Vertical Stem.
import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property real size: 24
    property color color: "#FFFFFF"
    property color accent: "#76A9FA"
    property color card: "transparent"
    property color highlight: "#DCE8FD"
    property color rim: "transparent"

    implicitWidth: size; implicitHeight: size

    // Card background if requested (similar to badge framing)
    Rectangle {
        anchors.fill: parent
        visible: root.card !== "transparent" && root.card !== ""
        radius: Math.max(4, root.size * 0.25)
        color: root.card
        border.width: 1
        border.color: root.rim !== "transparent" ? root.rim : "transparent"
    }

    Item {
        anchors.centerIn: parent
        width: 294; height: 300
        scale: (root.size * (root.card !== "transparent" ? 0.7 : 0.95)) / 300.0

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            // Part 1: Left Vertical Stem
            ShapePath {
                fillColor: root.color; strokeColor: "transparent"
                PathSvg { path: "M0 0 L56 0 L56 300 L0 244 Z" }
            }
            // Part 2: Upper Diagonal Blade
            ShapePath {
                fillColor: root.color; strokeColor: "transparent"
                PathSvg { path: "M56 0 L128 0 L166 145 L106 145 Z" }
            }
            // Part 3: Lower Diagonal Blade
            ShapePath {
                fillColor: root.color; strokeColor: "transparent"
                PathSvg { path: "M188 155 L128 155 L166 300 L238 300 Z" }
            }
            // Part 4: Right Vertical Stem
            ShapePath {
                fillColor: root.color; strokeColor: "transparent"
                PathSvg { path: "M238 56 L294 0 L294 300 L238 300 Z" }
            }
        }
    }
}
