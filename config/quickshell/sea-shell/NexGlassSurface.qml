import QtQuick
import QtQuick.Effects
import Quickshell

Item {
    id: glass

    property real radius: Tok.rCard
    property real glassOpacity: 0.72
    property color baseColor: Tok.surface
    property color accentColor: Tok.accent
    property bool floating: true
    property bool interactive: false
    property bool hovered: false
    property bool active: false
    property bool specularRim: true
    property alias contentChildren: contentContainer.data

    default property alias data: contentContainer.data

    // Outer soft ambient shadow for floating material depth
    Rectangle {
        id: shadowBackdrop
        anchors.fill: parent
        anchors.margins: -1
        anchors.topMargin: 0
        anchors.bottomMargin: -4
        radius: glass.radius + 2
        visible: glass.floating && glass.glassOpacity > 0.1
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.18)
        opacity: glass.floating ? 1.0 : 0.0
        z: -2

        // Soft ambient shadow gradient
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            anchors.topMargin: 2
            anchors.bottomMargin: -6
            radius: glass.radius + 4
            color: Qt.rgba(0, 0, 0, 0.12)
            z: -3
            visible: glass.floating
        }
    }

    // Main translucent glass body
    Rectangle {
        id: glassBody
        anchors.fill: parent
        radius: glass.radius
        z: -1
        clip: true

        // Base translucent crystalline tint
        color: {
            var c = glass.baseColor;
            var alpha = glass.glassOpacity;
            if (glass.hovered) alpha = Math.min(0.92, alpha + 0.06);
            if (glass.active) alpha = Math.min(0.96, alpha + 0.10);
            return Qt.rgba(c.r, c.g, c.b, alpha);
        }

        Behavior on color { ColorAnimation { duration: Tok.mFast } }

        // Subtle internal light gradient (material thickness & lensing)
        Rectangle {
            anchors.fill: parent
            radius: glass.radius
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: glass.hovered
                        ? Qt.rgba(1.0, 1.0, 1.0, 0.15)
                        : Qt.rgba(1.0, 1.0, 1.0, 0.09)
                }
                GradientStop {
                    position: 0.25
                    color: Qt.rgba(1.0, 1.0, 1.0, 0.02)
                }
                GradientStop {
                    position: 0.75
                    color: Qt.rgba(0.0, 0.0, 0.0, 0.01)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(0.0, 0.0, 0.0, 0.08)
                }
            }
        }

        // Top specular optical rim catch (Fresnel reflection along top bevel)
        Rectangle {
            id: topRimCatch
            visible: glass.specularRim
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.max(1, Math.min(2, glass.radius > 6 ? 1.5 : 1))
            radius: glass.radius
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(1.0, 1.0, 1.0, 0.06) }
                GradientStop { position: 0.15; color: Qt.rgba(1.0, 1.0, 1.0, 0.32) }
                GradientStop { position: 0.5; color: Qt.rgba(1.0, 1.0, 1.0, 0.45) }
                GradientStop { position: 0.85; color: Qt.rgba(1.0, 1.0, 1.0, 0.32) }
                GradientStop { position: 1.0; color: Qt.rgba(1.0, 1.0, 1.0, 0.06) }
            }
            opacity: glass.hovered ? 1.0 : 0.85
            Behavior on opacity { NumberAnimation { duration: Tok.mFast } }
        }

        // Outer optical border (hairline subtle contrast rule)
        border.width: 1
        border.color: {
            if (glass.active) return Qt.rgba(glass.accentColor.r, glass.accentColor.g, glass.accentColor.b, 0.55);
            if (glass.hovered) return Qt.rgba(1.0, 1.0, 1.0, 0.25);
            return Qt.rgba(1.0, 1.0, 1.0, 0.14);
        }

        Behavior on border.color { ColorAnimation { duration: Tok.mFast } }
    }

    // Inner container for children
    Item {
        id: contentContainer
        anchors.fill: parent
    }
}
