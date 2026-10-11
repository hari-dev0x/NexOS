import QtQuick

// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   I M P A S T O   B A R   C H I P                                        │
// │   one bar item, placed in a status capsule                               │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

Item {
    id: root

    property string icon: ""
    property string text: ""
    property color tint: ImpastoTheme.text
    property bool alone: false
    property bool active: false
    property bool showTextAlways: false
    signal clicked()

    readonly property bool hasText: text !== ""
    property real reveal: showTextAlways ? 1.0 : (mouse.containsMouse || active ? 1.0 : 0.0)

    Behavior on reveal {
        NumberAnimation { duration: ImpastoTheme.durationFast; easing.type: Easing.OutCubic }
    }

    implicitHeight: ImpastoTheme.capsuleHeight
    implicitWidth: {
        var base = alone ? 34 : 28;
        if (hasText && reveal > 0) {
            return base + (figureTxt.implicitWidth + 8) * reveal;
        }
        return base;
    }

    // Highlight on hover and while active
    Rectangle {
        anchors.centerIn: parent
        width: Math.max(0, parent.width - (root.alone ? 2 : 4))
        height: root.alone ? parent.height - 2 : ImpastoTheme.capsuleHeight - 8
        radius: height / 2
        color: ImpastoTheme.islandSurfaceHover
        opacity: mouse.containsMouse || root.active ? 1.0 : 0.0

        Behavior on opacity { NumberAnimation { duration: ImpastoTheme.durationFast } }
    }

    Row {
        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            font.family: ImpastoTheme.fontMono
            font.pixelSize: Math.round(ImpastoTheme.capsuleHeight * 0.44)
            color: root.tint

            Behavior on color { ColorAnimation { duration: ImpastoTheme.durationFast } }
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.hasText && root.reveal > 0
            width: Math.max(0, figureTxt.implicitWidth * root.reveal)
            height: figureTxt.implicitHeight
            clip: true

            Text {
                id: figureTxt
                anchors.verticalCenter: parent.verticalCenter
                text: root.text
                font.family: ImpastoTheme.fontFamily
                font.pixelSize: ImpastoTheme.fontSizeSmall
                font.weight: Font.DemiBold
                color: ImpastoTheme.text
                opacity: Math.max(0, (root.reveal - 0.2) / 0.8)
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
