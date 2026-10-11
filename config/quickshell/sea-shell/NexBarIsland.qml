import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   D Y N A M I C   I S L A N D                                            │
// │   morphing centre capsule · hosts every island layer                     │
// │   exact UI port from upstream andreumassanet/impasto                     │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

Rectangle {
    id: root

    // References to shell and theme
    property var rootRef: null
    property var theme: null
    property var barRef: null

    // Audio & Power hardware bindings
    readonly property var audioSink: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
    readonly property int currentVol: audioSink ? Math.round(audioSink.volume * 100) : 0
    readonly property bool isVolMuted: audioSink ? audioSink.muted : false

    function setVolume(pct) {
        if (audioSink) {
            audioSink.muted = false;
            audioSink.volume = Math.max(0, Math.min(1.0, pct / 100));
        }
    }

    // Layer state arbitration:
    // "modules"      rest/media capsule
    // "summary"      hover dwell glance card
    // "osd"          transient volume/brightness overlay
    // "notification" transient incoming notification
    // "panel"        expanded calendar, media, or controls card
    readonly property string layerModules: "modules"
    readonly property string layerSummary: "summary"
    readonly property string layerOsd: "osd"
    readonly property string layerNotification: "notification"
    readonly property string layerPanel: "panel"

    property string openPanel: ""   // "cal" | "mpris" | "controls" | ""
    property bool summary: false
    property bool forcedSummary: false
    property bool hovered: hoverHandler.hovered
    property bool summaryHeld: false
    property bool landing: false

    // Transient OSD properties
    property bool transientActive: false
    property string transientIcon: ""
    property string transientLabel: ""
    property real transientProgress: -1

    readonly property bool expanded: openPanel !== ""

    readonly property string currentLayer: {
        if (expanded) return layerPanel;
        if (rootRef && rootRef.notiPopup && rootRef.notiPopup.visible) return layerNotification;
        if (transientActive) return layerOsd;
        if (summary || forcedSummary) return layerSummary;
        return layerModules;
    }

    // Media presence check
    readonly property bool hasMedia: rootRef && rootRef.cfgMpris && rootRef.player !== null && (rootRef.player.isPlaying || rootRef.player.playbackStatus === 1 || (rootRef.player.trackTitle && rootRef.player.trackTitle !== ""))

    // Lit where a click does something: clock at rest and glance. Not while landing from a panel.
    readonly property bool lit: hovered && !landing && (currentLayer === layerModules || currentLayer === layerSummary)

    // Upstream layer sizes
    readonly property var panelSizes: ({
        cal:      { width: 340, height: 330 },
        calendar: { width: 340, height: 330 },
        mpris:    { width: 380, height: 150 },
        media:    { width: 380, height: 150 },
        controls: { width: 420, height: 320 }
    })

    readonly property var activePanelSize: panelSizes[openPanel] ?? panelSizes.controls

    readonly property real targetWidth: {
        if (currentLayer === layerPanel) {
            return activePanelSize.width;
        }
        if (currentLayer === layerNotification) {
            return 430;
        }
        if (currentLayer === layerOsd) {
            return 260;
        }
        if (currentLayer === layerSummary) {
            return 384;
        }
        // modules (rest): 278 when media split, 240 quiet
        return hasMedia ? 278 : 240;
    }

    readonly property real targetHeight: {
        if (currentLayer === layerPanel) {
            return activePanelSize.height;
        }
        if (currentLayer === layerNotification) {
            return 68;
        }
        if (currentLayer === layerOsd) {
            return ImpastoTheme.capsuleHeight;
        }
        if (currentLayer === layerSummary) {
            return hasMedia ? 168 : 116;
        }
        // modules
        return ImpastoTheme.capsuleHeight;
    }

    readonly property real targetRadius: {
        if (currentLayer === layerPanel || currentLayer === layerNotification || currentLayer === layerSummary) {
            return ImpastoTheme.radiusLarge; // 18px
        }
        return ImpastoTheme.capsuleHeight / 2; // 17px pill
    }

    // Physical dimensions & simultaneous morphing animations
    width: targetWidth
    height: targetHeight
    radius: targetRadius

    Behavior on width {
        NumberAnimation { duration: ImpastoTheme.durationMorph; easing.type: ImpastoTheme.easing }
    }
    Behavior on height {
        NumberAnimation { duration: ImpastoTheme.durationMorph; easing.type: ImpastoTheme.easing }
    }
    Behavior on radius {
        NumberAnimation { duration: ImpastoTheme.durationMedium; easing.type: ImpastoTheme.easing }
    }
    Behavior on color {
        ColorAnimation { duration: ImpastoTheme.durationFast }
    }

    // Upstream visual tokens: pure black surface, #262626 border, surface hover on lit
    color: expanded ? ImpastoTheme.island : (lit ? ImpastoTheme.islandSurfaceHover : ImpastoTheme.island)
    border.color: ImpastoTheme.islandBorder
    border.width: 1
    clip: true

    // Hover glance dwell timer (80ms intent delay) and grace timer (260ms exit)
    Timer {
        id: dwellTimer
        interval: 80
        onTriggered: {
            if (root.hovered && !root.expanded && !root.landing && !root.summaryHeld) {
                root.summary = true;
            }
        }
    }

    Timer {
        id: graceTimer
        interval: 260
        onTriggered: {
            if (!root.hovered) {
                root.summary = false;
            }
        }
    }

    // Landing guard: prevents glance from abruptly re-opening right when closing a panel
    Timer {
        id: landingTimer
        interval: ImpastoTheme.durationMorph
        onTriggered: root.landing = false
    }

    onExpandedChanged: {
        if (!expanded) {
            root.landing = true;
            landingTimer.restart();
        }
    }

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            if (hovered) {
                graceTimer.stop();
                if (!root.summary && !root.expanded && !root.landing) {
                    dwellTimer.restart();
                }
            } else {
                dwellTimer.stop();
                graceTimer.restart();
                root.summaryHeld = false;
            }
        }
    }

    // Expiry for transient OSD
    Timer {
        id: osdExpiry
        interval: 1800
        onTriggered: root.transientActive = false
    }

    function triggerOsd(icon, label, progress) {
        if (root.expanded) return;
        root.transientIcon = icon;
        root.transientLabel = label;
        root.transientProgress = progress;
        root.transientActive = true;
        osdExpiry.restart();
    }

    function open(panel) {
        root.transientActive = false;
        osdExpiry.stop();
        root.summary = false;
        root.openPanel = panel;
        if (rootRef) rootRef.openPop = panel;
    }

    function close() {
        root.openPanel = "";
        if (rootRef && (rootRef.openPop === "cal" || rootRef.openPop === "mpris" || rootRef.openPop === "controls")) {
            rootRef.openPop = "";
        }
    }

    function toggle(panel) {
        if (root.openPanel === panel) root.close();
        else root.open(panel);
    }

    // System clock for Island
    SystemClock {
        id: islandClock
        precision: SystemClock.Minutes
    }

    // =========================================================================
    // LAYER: COLLAPSED (Modules · Hover Summary · OSD · Notification)
    // =========================================================================
    Item {
        id: collapsedLayer
        anchors.fill: parent
        opacity: root.expanded ? 0 : 1
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 110; easing.type: ImpastoTheme.easing }
        }

        // MouseArea for collapsed interaction
        MouseArea {
            id: collapsedMa
            anchors.fill: parent
            enabled: !root.expanded
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (mouse) => {
                root.summaryHeld = true;
                if (mouse.button === Qt.RightButton) {
                    if (root.hasMedia && rootRef && rootRef.player) rootRef.player.togglePlaying();
                    return;
                }
                // Contextual targets: if media is active, clicking the media art or spectrum targets media;
                // clicking the central clock area opens the calendar.
                if (root.hasMedia && (mouse.x <= 48 || mouse.x >= parent.width - 48)) {
                    root.toggle("mpris");
                } else {
                    root.toggle("cal");
                }
            }
            onWheel: (wheel) => {
                if (!root.hasMedia || !rootRef || !rootRef.player) return;
                if (wheel.angleDelta.y > 0) rootRef.player.next();
                else rootRef.player.previous();
            }
        }

        // --- SUB-LAYER: REST (IslandRest.qml exact port) ---
        Item {
            id: restLayer
            anchors.fill: parent
            visible: root.currentLayer === root.layerModules
            opacity: visible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: ImpastoTheme.durationFast } }

            // Leading media mark (20x20 artwork or note glyph)
            Item {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                height: 20
                visible: root.hasMedia

                Rectangle {
                    anchors.fill: parent
                    radius: width * ImpastoTheme.pictureCorner // 4.8px
                    color: ImpastoTheme.islandSurfaceHover
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: (rootRef && rootRef.player && rootRef.player.artUrl) ? rootRef.player.artUrl : ""
                        visible: source != "" && status === Image.Ready
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 40
                        sourceSize.height: 40
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰎇"
                        font.family: ImpastoTheme.fontMono
                        font.pixelSize: 11
                        color: ImpastoTheme.indicator
                    }
                }
            }

            // Center: Clock (Time 13px DemiBold + Date 11px Medium, Space Grotesk tabular)
            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDateTime(islandClock.date, "HH:mm")
                    font.family: "Space Grotesk"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    font.features: { "tnum": 1 }
                    color: ImpastoTheme.text
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDateTime(islandClock.date, "ddd d MMM")
                    font.family: "Space Grotesk"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    font.features: { "tnum": 1 }
                    color: ImpastoTheme.textMuted
                }
            }

            // Trailing: CAVA Spectrum bars
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                height: 14
                spacing: 2
                visible: root.hasMedia

                Repeater {
                    model: 5
                    delegate: Rectangle {
                        required property int index
                        width: 2
                        radius: 1
                        anchors.verticalCenter: parent.verticalCenter
                        height: {
                            if (!rootRef || !rootRef.player || !rootRef.player.isPlaying) return 2;
                            if (rootRef.vizBars && rootRef.vizBars.length > index) {
                                return Math.max(2, Math.min(14, (rootRef.vizBars[index] || 0) / 100 * 14));
                            }
                            return (index % 2 === 0) ? 9 : 13;
                        }
                        color: ImpastoTheme.indicator
                        Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutQuad } }
                    }
                }
            }
        }

        // --- SUB-LAYER: HOVER GLANCE (IslandSummary.qml exact port) ---
        Item {
            id: summaryLayer
            anchors.fill: parent
            visible: root.currentLayer === root.layerSummary
            opacity: visible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: ImpastoTheme.durationFast } }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 14
                anchors.bottomMargin: 14
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 11

                // Row 1: Large 34px Time · Weekday & Day Month · Weather
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        text: Qt.formatDateTime(islandClock.date, "HH:mm")
                        font.family: "Space Grotesk"
                        font.pixelSize: 34
                        font.weight: Font.DemiBold
                        font.features: { "tnum": 1 }
                        color: ImpastoTheme.text
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 0

                        Text {
                            text: Qt.formatDate(islandClock.date, "dddd")
                            font.family: "Space Grotesk"
                            font.pixelSize: ImpastoTheme.fontSizeSmall
                            font.features: { "tnum": 1 }
                            color: ImpastoTheme.textMuted
                        }

                        Text {
                            text: Qt.formatDate(islandClock.date, "d MMMM")
                            font.family: "Space Grotesk"
                            font.pixelSize: ImpastoTheme.fontSizeMedium
                            font.weight: Font.DemiBold
                            font.features: { "tnum": 1 }
                            color: ImpastoTheme.text
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Row {
                        spacing: 6
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "󰖐"
                            font.family: ImpastoTheme.fontMono
                            font.pixelSize: 20
                            color: ImpastoTheme.text
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: (rootRef && rootRef.weatherTemp !== undefined) ? (rootRef.weatherTemp + "°") : "21°"
                            font.family: ImpastoTheme.fontFamily
                            font.pixelSize: ImpastoTheme.fontSizeMedium
                            font.weight: Font.DemiBold
                            color: ImpastoTheme.text
                        }
                    }
                }

                // Divider line (hairline #20ffffff)
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: ImpastoTheme.hairline
                }

                // Row 2: Media row (when active)
                RowLayout {
                    Layout.fillWidth: true
                    visible: root.hasMedia
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        radius: width * ImpastoTheme.pictureCorner // 8.16px
                        color: ImpastoTheme.islandSurfaceHover
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: (rootRef && rootRef.player && rootRef.player.artUrl) ? rootRef.player.artUrl : ""
                            visible: source != "" && status === Image.Ready
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 68
                            sourceSize.height: 68
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰎇"
                            font.family: ImpastoTheme.fontMono
                            font.pixelSize: 17
                            color: ImpastoTheme.indicator
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            Layout.fillWidth: true
                            text: (rootRef && rootRef.player) ? (rootRef.player.trackTitle || "Playing") : ""
                            elide: Text.ElideRight
                            font.family: ImpastoTheme.fontFamily
                            font.pixelSize: ImpastoTheme.fontSizeSmall
                            font.weight: Font.DemiBold
                            color: ImpastoTheme.text
                        }

                        Text {
                            Layout.fillWidth: true
                            text: (rootRef && rootRef.player) ? (rootRef.player.trackArtist || "") : ""
                            elide: Text.ElideRight
                            font.family: ImpastoTheme.fontFamily
                            font.pixelSize: ImpastoTheme.fontSizeSmall
                            color: ImpastoTheme.textMuted
                        }
                    }

                    Row {
                        Layout.preferredHeight: 14
                        spacing: 2
                        Repeater {
                            model: 6
                            delegate: Rectangle {
                                required property int index
                                width: 2
                                radius: 1
                                anchors.verticalCenter: parent.verticalCenter
                                height: {
                                    if (!rootRef || !rootRef.player || !rootRef.player.isPlaying) return 2;
                                    if (rootRef.vizBars && rootRef.vizBars.length > index) {
                                        return Math.max(2, Math.min(14, (rootRef.vizBars[index] || 0) / 100 * 14));
                                    }
                                    return (index % 2 === 0) ? 9 : 13;
                                }
                                color: ImpastoTheme.indicator
                                Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutQuad } }
                            }
                        }
                    }
                }

                // Row 3: Telemetry Readings (Battery · Volume · Notifications)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    // Battery
                    Row {
                        spacing: 6
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: (rootRef && rootRef.batIcon) ? rootRef.batIcon : "󰁹"
                            font.family: ImpastoTheme.fontMono
                            font.pixelSize: 13
                            color: {
                                var p = rootRef ? rootRef.batPct : 100;
                                if (p <= 15 && !rootRef.batCharging) return ImpastoTheme.indicatorBad;
                                if (p <= 25 && !rootRef.batCharging) return ImpastoTheme.indicatorWarn;
                                return ImpastoTheme.textMuted;
                            }
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: (rootRef && rootRef.batPct !== undefined) ? ("" + rootRef.batPct + "%") : "100%"
                            font.family: ImpastoTheme.fontFamily
                            font.pixelSize: ImpastoTheme.fontSizeSmall
                            color: ImpastoTheme.textMuted
                        }
                    }

                    // Volume
                    Row {
                        spacing: 6
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.isVolMuted ? "󰝟" : (root.currentVol <= 0 ? "󰕿" : (root.currentVol < 50 ? "󰖀" : "󰕾"))
                            font.family: ImpastoTheme.fontMono
                            font.pixelSize: 13
                            color: ImpastoTheme.textMuted
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.isVolMuted ? "Muted" : (root.currentVol + "%")
                            font.family: ImpastoTheme.fontFamily
                            font.pixelSize: ImpastoTheme.fontSizeSmall
                            color: ImpastoTheme.textMuted
                        }
                    }

                    // Notifications
                    Row {
                        spacing: 6
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "󰂚"
                            font.family: ImpastoTheme.fontMono
                            font.pixelSize: 13
                            color: ImpastoTheme.textMuted
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: (rootRef && rootRef.notiHistory) ? ("" + rootRef.notiHistory.length) : "0"
                            font.family: ImpastoTheme.fontFamily
                            font.pixelSize: ImpastoTheme.fontSizeSmall
                            color: ImpastoTheme.textMuted
                        }
                    }

                    Item { Layout.fillWidth: true }
                }
            }
        }

        // --- SUB-LAYER: OSD (OsdLayer.qml exact port) ---
        Item {
            id: osdLayer
            anchors.fill: parent
            visible: root.currentLayer === root.layerOsd
            opacity: visible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: ImpastoTheme.durationFast } }

            Row {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.transientIcon
                    font.family: ImpastoTheme.fontMono
                    font.pixelSize: 15
                    color: ImpastoTheme.indicator
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.transientProgress >= 0
                    width: 130
                    height: 4
                    radius: height / 2
                    color: ImpastoTheme.islandSurfaceHover

                    Rectangle {
                        width: Math.max(parent.height, parent.width * Math.min(1, Math.max(0, root.transientProgress)))
                        height: parent.height
                        radius: height / 2
                        color: ImpastoTheme.accent

                        Behavior on width {
                            NumberAnimation { duration: ImpastoTheme.durationFast; easing.type: ImpastoTheme.easing }
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(34, implicitWidth)
                    horizontalAlignment: Text.AlignRight
                    text: root.transientLabel
                    font.family: ImpastoTheme.fontFamily
                    font.pixelSize: ImpastoTheme.fontSizeSmall
                    font.weight: Font.DemiBold
                    color: ImpastoTheme.text
                }
            }
        }
    }

    // =========================================================================
    // LAYER: EXPANDED PANELS (FocusScope with Escape dismiss)
    // =========================================================================
    FocusScope {
        id: panelScope
        anchors.fill: parent
        focus: root.expanded
        opacity: root.expanded ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: ImpastoTheme.durationMedium; easing.type: ImpastoTheme.easing }
        }

        Keys.onEscapePressed: root.close()

        // Swallow clicks inside the panel so they don't hit the outside dismiss area
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            z: -1
        }

        // --- EXPANDED PANEL: CALENDAR (CalendarCard.qml exact port) ---
        Item {
            id: calPanel
            anchors.fill: parent
            anchors.margins: 16
            visible: root.openPanel === "cal" || root.openPanel === "calendar"

            property int offsetMonths: 0
            readonly property date today: islandClock.date
            readonly property date shown: new Date(today.getFullYear(), today.getMonth() + offsetMonths, 1)
            readonly property int year: shown.getFullYear()
            readonly property int month: shown.getMonth()
            readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()
            readonly property int daysInPrev: new Date(year, month, 0).getDate()
            readonly property int leadingBlanks: (new Date(year, month, 1).getDay() + 6) % 7
            readonly property bool showingThisMonth: offsetMonths === 0

            ColumnLayout {
                anchors.fill: parent
                spacing: 9

                // Month header row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: Qt.formatDateTime(calPanel.shown, "MMMM")
                        font.family: ImpastoTheme.fontFamily
                        font.pixelSize: ImpastoTheme.fontSizeMedium
                        font.weight: Font.DemiBold
                        color: ImpastoTheme.text
                    }

                    Text {
                        text: "" + calPanel.year
                        font.family: ImpastoTheme.fontFamily
                        font.pixelSize: ImpastoTheme.fontSizeMedium
                        color: ImpastoTheme.textMuted
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: Qt.formatDateTime(calPanel.today, "dddd")
                        visible: calPanel.showingThisMonth
                        font.family: ImpastoTheme.fontFamily
                        font.pixelSize: ImpastoTheme.fontSizeSmall
                        color: ImpastoTheme.accent
                    }

                    Rectangle {
                        visible: !calPanel.showingThisMonth
                        implicitHeight: 22
                        implicitWidth: todayTxt.implicitWidth + 16
                        radius: height / 2
                        color: ImpastoTheme.islandSurfaceHover
                        border.color: ImpastoTheme.islandBorder
                        border.width: 1

                        Text {
                            id: todayTxt
                            anchors.centerIn: parent
                            text: "Today"
                            font.family: ImpastoTheme.fontFamily
                            font.pixelSize: ImpastoTheme.fontSizeSmall
                            color: ImpastoTheme.text
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: calPanel.offsetMonths = 0
                        }
                    }

                    // Prev month button
                    Rectangle {
                        implicitWidth: 24
                        implicitHeight: 22
                        radius: ImpastoTheme.radiusSmall
                        color: prevMa.containsMouse ? ImpastoTheme.islandSurfaceHover : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "󰅁"
                            font.family: ImpastoTheme.fontMono
                            font.pixelSize: 12
                            color: ImpastoTheme.text
                        }
                        MouseArea {
                            id: prevMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: calPanel.offsetMonths -= 1
                        }
                    }

                    // Next month button
                    Rectangle {
                        implicitWidth: 24
                        implicitHeight: 22
                        radius: ImpastoTheme.radiusSmall
                        color: nextMa.containsMouse ? ImpastoTheme.islandSurfaceHover : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "󰅂"
                            font.family: ImpastoTheme.fontMono
                            font.pixelSize: 12
                            color: ImpastoTheme.text
                        }
                        MouseArea {
                            id: nextMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: calPanel.offsetMonths += 1
                        }
                    }
                }

                // 7-column weekday headers: M T W T F S S
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 7
                    rowSpacing: 2
                    columnSpacing: 2

                    Repeater {
                        model: ["M", "T", "W", "T", "F", "S", "S"]
                        Text {
                            required property string modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 16
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            font.family: ImpastoTheme.fontFamily
                            font.pixelSize: ImpastoTheme.fontSizeLabel
                            font.weight: Font.DemiBold
                            color: ImpastoTheme.textMuted
                        }
                    }

                    // Always 42 cells (6 rows x 7 cols)
                    Repeater {
                        model: 42
                        delegate: Item {
                            required property int index
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            readonly property int dayNumber: index - calPanel.leadingBlanks + 1
                            readonly property bool inMonth: dayNumber >= 1 && dayNumber <= calPanel.daysInMonth
                            readonly property bool isToday: calPanel.showingThisMonth && inMonth && dayNumber === calPanel.today.getDate()
                            readonly property int displayDay: inMonth ? dayNumber : (dayNumber < 1 ? (calPanel.daysInPrev + dayNumber) : (dayNumber - calPanel.daysInMonth))

                            Rectangle {
                                anchors.centerIn: parent
                                width: Math.min(parent.width, parent.height, 28)
                                height: width
                                radius: width / 2
                                color: isToday ? ImpastoTheme.accent : (cellMa.containsMouse && inMonth ? ImpastoTheme.islandSurfaceHover : "transparent")

                                Text {
                                    anchors.centerIn: parent
                                    text: "" + displayDay
                                    font.family: ImpastoTheme.fontFamily
                                    font.pixelSize: ImpastoTheme.fontSizeSmall
                                    font.weight: isToday ? Font.DemiBold : Font.Normal
                                    color: isToday ? ImpastoTheme.accentText : (inMonth ? ImpastoTheme.text : ImpastoTheme.indicatorDim)
                                }

                                MouseArea {
                                    id: cellMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: inMonth
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }
                }
            }
        }

        // --- EXPANDED PANEL: MEDIA CARD (MediaCard.qml exact port) ---
        Item {
            id: mprisPanel
            anchors.fill: parent
            anchors.margins: 14
            visible: root.openPanel === "mpris" || root.openPanel === "media"

            ColumnLayout {
                anchors.fill: parent
                spacing: 11

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // 58x58 artwork
                    Rectangle {
                        Layout.preferredWidth: 58
                        Layout.preferredHeight: 58
                        radius: width * ImpastoTheme.pictureCorner // 13.92px
                        color: ImpastoTheme.islandSurfaceHover
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: (rootRef && rootRef.player && rootRef.player.artUrl) ? rootRef.player.artUrl : ""
                            visible: source != "" && status === Image.Ready
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 116
                            sourceSize.height: 116
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰎇"
                            font.family: ImpastoTheme.fontMono
                            font.pixelSize: 22
                            color: ImpastoTheme.accent
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: (rootRef && rootRef.player) ? (rootRef.player.trackTitle || "Nothing Playing") : "Nothing Playing"
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.Wrap
                            font.family: ImpastoTheme.fontFamily
                            font.pixelSize: ImpastoTheme.fontSizeRegular
                            font.weight: Font.DemiBold
                            color: ImpastoTheme.text
                        }

                        Text {
                            Layout.fillWidth: true
                            text: (rootRef && rootRef.player) ? (rootRef.player.trackArtist || "") : ""
                            elide: Text.ElideRight
                            font.family: ImpastoTheme.fontFamily
                            font.pixelSize: ImpastoTheme.fontSizeSmall
                            color: ImpastoTheme.textMuted
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Progress seek bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 3
                    radius: 1.5
                    color: ImpastoTheme.islandSurfaceHover

                    Rectangle {
                        width: {
                            if (!rootRef || !rootRef.player || !rootRef.player.length || rootRef.player.length <= 0) return 0;
                            var frac = (rootRef.player.position || 0) / rootRef.player.length;
                            return Math.max(0, Math.min(parent.width, parent.width * frac));
                        }
                        height: parent.height
                        radius: parent.radius
                        color: ImpastoTheme.accent

                        Behavior on width {
                            NumberAnimation { duration: 900; easing.type: Easing.Linear }
                        }
                    }
                }

                // Transport buttons row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: {
                            var sec = (rootRef && rootRef.player) ? (rootRef.player.position || 0) : 0;
                            var m = Math.floor(sec / 60);
                            var s = Math.floor(sec % 60);
                            return m + ":" + (s < 10 ? "0" : "") + s;
                        }
                        font.family: ImpastoTheme.fontMono
                        font.pixelSize: ImpastoTheme.fontSizeLabel
                        color: ImpastoTheme.textMuted
                    }

                    Item { Layout.fillWidth: true }

                    // Previous
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 28
                        radius: ImpastoTheme.radiusSmall
                        color: prevTrackMa.containsMouse ? ImpastoTheme.islandSurfaceHover : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "󰒮"
                            font.family: ImpastoTheme.fontMono
                            font.pixelSize: 15
                            color: ImpastoTheme.text
                        }
                        MouseArea {
                            id: prevTrackMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (rootRef && rootRef.player) rootRef.player.previous()
                        }
                    }

                    // Play / Pause
                    Rectangle {
                        implicitWidth: 36
                        implicitHeight: 30
                        radius: ImpastoTheme.radiusSmall
                        color: playMa.containsMouse ? ImpastoTheme.islandSurfaceHover : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: (rootRef && rootRef.player && rootRef.player.isPlaying) ? "󰏤" : "󰐊"
                            font.family: ImpastoTheme.fontMono
                            font.pixelSize: 18
                            color: ImpastoTheme.text
                        }
                        MouseArea {
                            id: playMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (rootRef && rootRef.player) rootRef.player.togglePlaying()
                        }
                    }

                    // Next
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 28
                        radius: ImpastoTheme.radiusSmall
                        color: nextTrackMa.containsMouse ? ImpastoTheme.islandSurfaceHover : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "󰒭"
                            font.family: ImpastoTheme.fontMono
                            font.pixelSize: 15
                            color: ImpastoTheme.text
                        }
                        MouseArea {
                            id: nextTrackMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (rootRef && rootRef.player) rootRef.player.next()
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: {
                            var sec = (rootRef && rootRef.player) ? (rootRef.player.length || 0) : 0;
                            var m = Math.floor(sec / 60);
                            var s = Math.floor(sec % 60);
                            return m + ":" + (s < 10 ? "0" : "") + s;
                        }
                        font.family: ImpastoTheme.fontMono
                        font.pixelSize: ImpastoTheme.fontSizeLabel
                        color: ImpastoTheme.textMuted
                    }
                }
            }
        }

        // --- EXPANDED PANEL: CONTROLS (ControlsPanel & PowerRow exact port) ---
        Item {
            id: controlsPanel
            anchors.fill: parent
            anchors.margins: 18
            visible: root.openPanel === "controls"

            ColumnLayout {
                anchors.fill: parent
                spacing: 14

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Control Center"
                        font.family: ImpastoTheme.fontFamily
                        font.pixelSize: ImpastoTheme.fontSizeMedium
                        font.weight: Font.DemiBold
                        color: ImpastoTheme.text
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        implicitWidth: 24
                        implicitHeight: 24
                        radius: ImpastoTheme.radiusSmall
                        color: closeMa.containsMouse ? ImpastoTheme.islandSurfaceHover : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 12
                            color: ImpastoTheme.textMuted
                        }
                        MouseArea {
                            id: closeMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.close()
                        }
                    }
                }

                // Volume slider row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Text {
                        text: "󰕾"
                        font.family: ImpastoTheme.fontMono
                        font.pixelSize: 16
                        color: ImpastoTheme.textMuted
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        radius: 3
                        color: ImpastoTheme.islandSurfaceHover
                        Rectangle {
                            width: parent.width * Math.min(1.0, Math.max(0.0, root.currentVol / 100))
                            height: parent.height
                            radius: parent.radius
                            color: root.isVolMuted ? ImpastoTheme.textMuted : ImpastoTheme.accent
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => {
                                var pct = Math.round((mouse.x / width) * 100);
                                root.setVolume(pct);
                            }
                        }
                    }
                    Text {
                        Layout.preferredWidth: 36
                        text: root.isVolMuted ? "0%" : (root.currentVol + "%")
                        font.family: ImpastoTheme.fontFamily
                        font.pixelSize: ImpastoTheme.fontSizeSmall
                        color: ImpastoTheme.text
                    }
                }

                // Brightness slider row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Text {
                        text: "󰃟"
                        font.family: ImpastoTheme.fontMono
                        font.pixelSize: 16
                        color: ImpastoTheme.textMuted
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        radius: 3
                        color: ImpastoTheme.islandSurfaceHover
                        Rectangle {
                            width: parent.width * Math.min(1.0, Math.max(0.0, (rootRef && rootRef.brightPct !== undefined ? rootRef.brightPct : 75) / 100))
                            height: parent.height
                            radius: parent.radius
                            color: ImpastoTheme.accent
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => {
                                if (!rootRef) return;
                                var pct = Math.round((mouse.x / width) * 100);
                                if (rootRef.setBrightness) rootRef.setBrightness(Math.max(5, Math.min(100, pct)));
                            }
                        }
                    }
                    Text {
                        Layout.preferredWidth: 36
                        text: (rootRef && rootRef.brightPct !== undefined ? rootRef.brightPct : 75) + "%"
                        font.family: ImpastoTheme.fontFamily
                        font.pixelSize: ImpastoTheme.fontSizeSmall
                        color: ImpastoTheme.text
                    }
                }

                Item { Layout.fillHeight: true }

                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: ImpastoTheme.hairline
                }

                // Power Row: Session actions with 2-step armed destructive confirmation (PowerRow.qml)
                RowLayout {
                    id: powerRow
                    Layout.fillWidth: true
                    spacing: 6
                    property string armed: ""

                    Timer {
                        id: disarmTimer
                        interval: 3000
                        onTriggered: powerRow.armed = ""
                    }

                    readonly property var actions: [
                        { id: "lock",     label: "Lock",     icon: "󰌾", destructive: false },
                        { id: "logout",   label: "Log out",  icon: "󰍃", destructive: true },
                        { id: "reboot",   label: "Restart",  icon: "󰜉", destructive: true },
                        { id: "poweroff", label: "Shut down", icon: "󰐥", destructive: true }
                    ]

                    Repeater {
                        model: powerRow.actions
                        delegate: Rectangle {
                            id: actBtn
                            required property var modelData
                            readonly property bool isArmed: powerRow.armed === modelData.id

                            Layout.preferredWidth: isArmed ? actLbl.implicitWidth + 34 : 34
                            Layout.preferredHeight: 30
                            radius: ImpastoTheme.radiusSmall

                            color: isArmed ? ImpastoTheme.red : (actMa.containsMouse ? ImpastoTheme.islandSurfaceHover : "transparent")
                            border.color: isArmed ? ImpastoTheme.red : (actMa.containsMouse ? ImpastoTheme.islandBorder : "transparent")
                            border.width: 1

                            Behavior on Layout.preferredWidth {
                                NumberAnimation { duration: ImpastoTheme.durationFast; easing.type: ImpastoTheme.easing }
                            }
                            Behavior on color { ColorAnimation { duration: ImpastoTheme.durationFast } }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: actBtn.modelData.icon
                                    font.family: ImpastoTheme.fontMono
                                    font.pixelSize: 15
                                    color: actBtn.isArmed ? ImpastoTheme.accentText : (actMa.containsMouse ? ImpastoTheme.accent : ImpastoTheme.text)
                                }

                                Text {
                                    id: actLbl
                                    visible: actBtn.isArmed
                                    text: actBtn.modelData.label
                                    font.family: ImpastoTheme.fontFamily
                                    font.pixelSize: ImpastoTheme.fontSizeSmall
                                    font.weight: Font.DemiBold
                                    color: ImpastoTheme.accentText
                                }
                            }

                            MouseArea {
                                id: actMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!actBtn.modelData.destructive || actBtn.isArmed) {
                                        powerRow.armed = "";
                                        disarmTimer.stop();
                                        root.close();
                                        if (rootRef && rootRef.sessionRun) {
                                            rootRef.sessionRun(actBtn.modelData.id);
                                        } else {
                                            if (actBtn.modelData.id === "lock") Hyprland.dispatch("exec hyprlock");
                                            else if (actBtn.modelData.id === "logout") Hyprland.dispatch("exit");
                                            else if (actBtn.modelData.id === "reboot") Hyprland.dispatch("exec systemctl reboot");
                                            else if (actBtn.modelData.id === "poweroff") Hyprland.dispatch("exec systemctl poweroff");
                                        }
                                        return;
                                    }
                                    powerRow.armed = actBtn.modelData.id;
                                    disarmTimer.restart();
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }
                }
            }
        }
    }
}
