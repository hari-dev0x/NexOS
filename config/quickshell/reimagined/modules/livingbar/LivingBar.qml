pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.livingbar

/**
 * LivingBar — Independent, living desktop bar component for NexUI.
 *
 * Capabilities:
 *  - Responsive floating spatial capsule with draggable positioning & screen bounds.
 *  - Persistent file collection (drag-and-drop, verification, explicit removal).
 *  - Real Antigravity (Agy) activity monitoring adapter.
 *  - Offline, private spelling assistant (Wayland explicit clipboard paste, local edit-distance suggestions).
 *  - Contextual AI with local Ollama integration and explicit file attachment controls.
 *  - Zero external app launch shortcuts. No mascots, cartoon faces, or RGB effects.
 */
Item {
    id: root

    property bool compact: false
    property bool expanded: false
    property string activeTab: "media" // "media" | "files" | "agy" | "spelling" | "ai"

    // Positioning and dragging signals/properties
    property bool isDragging: false
    property real dragStartX: 0
    property real dragStartY: 0
    signal dragMoved(real deltaX, real deltaY)
    signal dragReleased()

    implicitWidth: mainCapsule.width
    implicitHeight: mainCapsule.height

    // Living dynamics & telemetry
    readonly property bool hasMedia: MprisController.isPlaying
    readonly property var activePlayer: MprisController.activePlayer
    readonly property string trackTitle: MprisController.titleOf(activePlayer) || ""
    readonly property string trackArtist: MprisController.artistOf(activePlayer) || ""
    readonly property real batteryPct: Battery.available ? Battery.percentage : 100
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isAudioMuted: Audio.sink?.audio?.muted ?? false
    readonly property real audioVol: Audio.sink?.audio?.volume ?? 0

    // Hover state
    readonly property bool isHovered: capsuleMouse.containsMouse || root.expanded || dropZone.containsDrag

    Rectangle {
        id: mainCapsule
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.expanded ? 520 : (root.compact ? 52 : Math.max(260, capsuleRow.implicitWidth + 24))
        height: root.expanded ? expandedBody.implicitHeight + 56 : 38
        radius: root.expanded ? 16 : 19

        color: {
            if (dropZone.containsDrag) return Appearance.colors.colPrimaryContainer
            if (capsuleMouse.containsPress) return Appearance.colors.colLayer2
            if (root.isHovered) return Appearance.colors.colLayer1
            return Appearance.colors.colLayer0
        }

        border.width: dropZone.containsDrag ? 2 : (root.expanded ? 1.5 : 1)
        border.color: {
            if (dropZone.containsDrag) return Appearance.colors.colPrimary
            if (root.expanded) return Appearance.colors.colPrimary
            if (root.isHovered) return Appearance.colors.colOutline
            return Appearance.colors.colOutlineVariant
        }

        Behavior on width {
            NumberAnimation { duration: Appearance.animation.elementMoveDuration; easing.type: Easing.OutCubic }
        }
        Behavior on height {
            NumberAnimation { duration: Appearance.animation.elementMoveDuration; easing.type: Easing.OutCubic }
        }
        Behavior on radius {
            NumberAnimation { duration: Appearance.animation.elementMoveDuration }
        }
        Behavior on color {
            ColorAnimation { duration: Appearance.animation.elementFadeDuration }
        }
        Behavior on border.color {
            ColorAnimation { duration: Appearance.animation.elementFadeDuration }
        }

        // DropArea for persistent file collection
        DropArea {
            id: dropZone
            anchors.fill: parent
            onEntered: drag => {
                drag.acceptProposedAction()
            }
            onDropped: drop => {
                if (drop.hasUrls) {
                    for (let i = 0; i < drop.urls.length; ++i) {
                        LivingBarState.addFile(drop.urls[i])
                    }
                    root.activeTab = "files"
                    root.expanded = true
                    drop.acceptProposedAction()
                }
            }
        }

        // ── TOP HEADER / REST BAR ROW ───────────────────────────────────────
        RowLayout {
            id: capsuleRow
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 38
            spacing: 8

            Item { Layout.preferredWidth: 6 }

            // Drag Handle
            Rectangle {
                id: dragHandle
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignVCenter
                radius: 4
                color: dragMouse.containsMouse ? Appearance.colors.colLayer2 : "transparent"

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "drag_indicator"
                    iconSize: 15
                    color: dragMouse.containsMouse ? Appearance.colors.colOnLayer0 : Appearance.colors.colSubtext
                }

                MouseArea {
                    id: dragMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.SizeAllCursor

                    onPressed: mouse => {
                        root.isDragging = true
                        root.dragStartX = mouse.x
                        root.dragStartY = mouse.y
                    }
                    onPositionChanged: mouse => {
                        if (root.isDragging) {
                            const dx = mouse.x - root.dragStartX
                            const dy = mouse.y - root.dragStartY
                            root.dragStartX = mouse.x
                            root.dragStartY = mouse.y
                            root.dragMoved(dx, dy)
                        }
                    }
                    onReleased: {
                        root.isDragging = false
                        root.dragReleased()
                    }
                }
            }

            // Living Breathing Beacon (Gentle, low-overhead ambient pulse)
            Item {
                id: beaconContainer
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    radius: 7
                    color: root.hasMedia ? Appearance.colors.colPrimary : (AgyActivityAdapter.lastStatus === "running" ? Appearance.colors.colTertiary : Appearance.colors.colSecondary)
                    opacity: 0.25

                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        running: root.visible
                        NumberAnimation { to: 1.35; duration: root.hasMedia ? 1200 : 2600; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 0.95; duration: root.hasMedia ? 1200 : 2600; easing.type: Easing.InOutQuad }
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 8
                    height: 8
                    radius: 4
                    color: root.hasMedia ? Appearance.colors.colPrimary : (AgyActivityAdapter.lastStatus === "running" ? Appearance.colors.colTertiary : Appearance.colors.colSecondary)
                }
            }

            // Main Label / Status
            StyledText {
                visible: !root.compact
                text: {
                    if (AgyActivityAdapter.lastStatus === "running") {
                        return "Agy: " + (AgyActivityAdapter.lastAction || "Working...")
                    }
                    if (root.hasMedia && root.trackTitle.length > 0) {
                        return root.trackArtist.length > 0 ? (root.trackArtist + " • " + root.trackTitle) : root.trackTitle
                    }
                    return "Living Bar"
                }
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer0
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.maximumWidth: root.expanded ? 340 : 180
            }

            // Mini visualizer wave when music is playing
            Row {
                visible: !root.compact && root.hasMedia && !root.expanded
                spacing: 2
                Layout.alignment: Qt.AlignVCenter

                Repeater {
                    model: 3
                    Rectangle {
                        required property int index
                        width: 2.5
                        height: 6 + (index * 3)
                        radius: 1
                        color: Appearance.colors.colPrimary
                        SequentialAnimation on height {
                            loops: Animation.Infinite
                            running: root.hasMedia && root.visible
                            NumberAnimation { to: 4 + ((index + 1) * 4); duration: 320 + (index * 110); easing.type: Easing.InOutSine }
                            NumberAnimation { to: 3 + (index * 2); duration: 320 + (index * 110); easing.type: Easing.InOutSine }
                        }
                    }
                }
            }

            // Files Badge (shows count of collected files)
            Rectangle {
                visible: LivingBarState.files.length > 0 && !root.compact && !root.expanded
                Layout.preferredHeight: 18
                Layout.preferredWidth: fileBadgeText.implicitWidth + 10
                radius: 9
                color: Appearance.colors.colLayer2

                StyledText {
                    id: fileBadgeText
                    anchors.centerIn: parent
                    text: LivingBarState.files.length + " files"
                    font.pixelSize: Appearance.font.pixelSize.tiny
                    color: Appearance.colors.colSubtext
                }
            }

            // Expand / Collapse Chevron Button
            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                Layout.alignment: Qt.AlignVCenter
                radius: 12
                color: expandBtnMouse.containsMouse ? Appearance.colors.colLayer2 : "transparent"

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: root.expanded ? "expand_less" : "expand_more"
                    iconSize: 18
                    color: Appearance.colors.colOnLayer0
                }

                MouseArea {
                    id: expandBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.expanded = !root.expanded
                }
            }

            Item { Layout.preferredWidth: 4 }
        }

        // Tap on capsule (outside drag handle) toggles expansion
        MouseArea {
            id: capsuleMouse
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 38
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            z: -1
            onClicked: root.expanded = !root.expanded
        }

        // ── EXPANDED SURFACE ────────────────────────────────────────────────
        ColumnLayout {
            id: expandedBody
            anchors.top: capsuleRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            visible: root.expanded
            opacity: root.expanded ? 1 : 0
            spacing: 12

            Behavior on opacity {
                NumberAnimation { duration: Appearance.animation.elementFadeDuration }
            }

            // Tab Bar Navigation
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [
                        { id: "media", label: "Media & Status", icon: "graphic_eq" },
                        { id: "files", label: "Files (" + LivingBarState.files.length + ")", icon: "folder_open" },
                        { id: "agy", label: "Agy Activity", icon: "terminal" },
                        { id: "spelling", label: "Spelling", icon: "spellcheck" },
                        { id: "ai", label: "Contextual AI", icon: "chat_bubble_outline" }
                    ]

                    Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        radius: 6
                        color: root.activeTab === modelData.id ? Appearance.colors.colPrimaryContainer : (tabMouse.containsMouse ? Appearance.colors.colLayer2 : Appearance.colors.colLayer1)

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            MaterialSymbol {
                                text: modelData.icon
                                iconSize: 14
                                color: root.activeTab === modelData.id ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
                            }

                            StyledText {
                                text: modelData.label
                                font.pixelSize: Appearance.font.pixelSize.tiny
                                font.weight: root.activeTab === modelData.id ? Font.DemiBold : Font.Normal
                                color: root.activeTab === modelData.id ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer0
                            }
                        }

                        MouseArea {
                            id: tabMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activeTab = modelData.id
                        }
                    }
                }
            }

            // Separator line
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Appearance.colors.colOutlineVariant
            }

            // ── TAB 1: MEDIA & STATUS ───────────────────────────────────────
            ColumnLayout {
                visible: root.activeTab === "media"
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // Media Artwork / Placeholder
                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: 8
                        color: Appearance.colors.colLayer2

                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: root.hasMedia ? "music_note" : "headset"
                            iconSize: 24
                            color: root.hasMedia ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
                        }
                    }

                    // Track & Artist Info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            text: root.hasMedia ? (root.trackTitle || "Playing Media") : "No media playing"
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.DemiBold
                            color: Appearance.colors.colOnLayer0
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: root.hasMedia ? (root.trackArtist || "Unknown Artist") : "System Audio Idle"
                            font.pixelSize: Appearance.font.pixelSize.tiny
                            color: Appearance.colors.colSubtext
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Native Playback Controls
                    RowLayout {
                        spacing: 6

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: prevBtnMouse.containsMouse ? Appearance.colors.colLayer2 : "transparent"

                            MaterialSymbol { anchors.centerIn: parent; text: "skip_previous"; iconSize: 20; color: Appearance.colors.colOnLayer0 }
                            MouseArea { id: prevBtnMouse; anchors.fill: parent; hoverEnabled: true; onClicked: MprisController.previous() }
                        }

                        Rectangle {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            radius: 18
                            color: Appearance.colors.colPrimaryContainer

                            MaterialSymbol { anchors.centerIn: parent; text: root.hasMedia ? "pause" : "play_arrow"; iconSize: 22; color: Appearance.colors.colPrimary }
                            MouseArea { anchors.fill: parent; hoverEnabled: true; onClicked: MprisController.togglePlaying() }
                        }

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: nextBtnMouse.containsMouse ? Appearance.colors.colLayer2 : "transparent"

                            MaterialSymbol { anchors.centerIn: parent; text: "skip_next"; iconSize: 20; color: Appearance.colors.colOnLayer0 }
                            MouseArea { id: nextBtnMouse; anchors.fill: parent; hoverEnabled: true; onClicked: MprisController.next() }
                        }
                    }
                }

                // Volume & Battery Quick Sliders
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // Volume Chip
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        radius: 6
                        color: Appearance.colors.colLayer1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 6

                            MaterialSymbol {
                                text: root.isAudioMuted ? "volume_off" : "volume_up"
                                iconSize: 16
                                color: root.isAudioMuted ? Appearance.colors.colError : Appearance.colors.colOnLayer0
                            }
                            StyledText {
                                text: "Vol: " + Math.round(root.audioVol * 100) + "%"
                                font.pixelSize: Appearance.font.pixelSize.tiny
                                color: Appearance.colors.colOnLayer0
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Audio.toggleMute()
                        }
                    }

                    // Battery Chip
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        radius: 6
                        color: Appearance.colors.colLayer1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 6

                            MaterialSymbol {
                                text: root.isCharging ? "battery_charging_full" : "battery_std"
                                iconSize: 16
                                color: root.batteryPct < 20 ? Appearance.colors.colError : Appearance.colors.colOnLayer0
                            }
                            StyledText {
                                text: "Bat: " + Math.round(root.batteryPct) + "%" + (root.isCharging ? " (Charging)" : "")
                                font.pixelSize: Appearance.font.pixelSize.tiny
                                color: Appearance.colors.colOnLayer0
                            }
                        }
                    }
                }
            }

            // ── TAB 2: PERSISTENT FILE COLLECTION ───────────────────────────
            ColumnLayout {
                visible: root.activeTab === "files"
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: "Persistent File Shelf (" + LivingBarState.files.length + ")"
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.DemiBold
                        color: Appearance.colors.colOnLayer0
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        visible: LivingBarState.files.length > 0
                        Layout.preferredHeight: 22
                        Layout.preferredWidth: 64
                        radius: 4
                        color: clearFilesMouse.containsMouse ? Appearance.colors.colErrorContainer : Appearance.colors.colLayer2

                        StyledText {
                            anchors.centerIn: parent
                            text: "Clear All"
                            font.pixelSize: Appearance.font.pixelSize.tiny
                            color: clearFilesMouse.containsMouse ? Appearance.colors.colError : Appearance.colors.colSubtext
                        }
                        MouseArea { id: clearFilesMouse; anchors.fill: parent; hoverEnabled: true; onClicked: LivingBarState.clearFiles() }
                    }
                }

                // Drop notification prompt
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: 8
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        MaterialSymbol { text: "file_download"; iconSize: 18; color: Appearance.colors.colPrimary }
                        StyledText {
                            text: "Drag & drop files onto this capsule to persist references"
                            font.pixelSize: Appearance.font.pixelSize.tiny
                            color: Appearance.colors.colSubtext
                        }
                    }
                }

                // File List
                ListView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(130, LivingBarState.files.length * 36)
                    clip: true
                    model: LivingBarState.files
                    spacing: 4

                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: ListView.view.width
                        height: 32
                        radius: 6
                        color: fileItemMouse.containsMouse ? Appearance.colors.colLayer2 : Appearance.colors.colLayer1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 8

                            MaterialSymbol {
                                text: modelData.exists ? "description" : "warning"
                                iconSize: 16
                                color: modelData.exists ? Appearance.colors.colPrimary : Appearance.colors.colError
                            }

                            StyledText {
                                text: modelData.name
                                font.pixelSize: Appearance.font.pixelSize.tiny
                                font.weight: Font.Medium
                                color: Appearance.colors.colOnLayer0
                                elide: Text.ElideRight
                                Layout.preferredWidth: 140
                            }

                            StyledText {
                                text: modelData.path
                                font.pixelSize: Appearance.font.pixelSize.tiny
                                color: Appearance.colors.colSubtext
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }

                            // Remove button
                            Rectangle {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                radius: 10
                                color: removeMouse.containsMouse ? Appearance.colors.colErrorContainer : "transparent"

                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "close"
                                    iconSize: 14
                                    color: removeMouse.containsMouse ? Appearance.colors.colError : Appearance.colors.colSubtext
                                }
                                MouseArea {
                                    id: removeMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: LivingBarState.removeFileAt(index)
                                }
                            }
                        }

                        MouseArea {
                            id: fileItemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            z: -1
                        }
                    }
                }
            }

            // ── TAB 3: AGY ACTIVITY MONITOR ─────────────────────────────────
            ColumnLayout {
                visible: root.activeTab === "agy"
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: "Observed Antigravity Events"
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.DemiBold
                        color: Appearance.colors.colOnLayer0
                    }
                    Item { Layout.fillWidth: true }
                    StyledText {
                        text: AgyActivityAdapter.lastStatus.toUpperCase()
                        font.pixelSize: Appearance.font.pixelSize.tiny
                        font.weight: Font.Bold
                        color: AgyActivityAdapter.lastStatus === "running" ? Appearance.colors.colTertiary : (AgyActivityAdapter.lastStatus === "error" ? Appearance.colors.colError : Appearance.colors.colPrimary)
                    }
                }

                // Recent Events Log (Strictly verified events, no invented data)
                ListView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 130
                    clip: true
                    model: AgyActivityAdapter.events
                    spacing: 4

                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view.width
                        height: 36
                        radius: 6
                        color: Appearance.colors.colLayer1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 8

                            Rectangle {
                                Layout.preferredWidth: 6
                                Layout.fillHeight: true
                                radius: 3
                                color: modelData.status === "running" ? Appearance.colors.colTertiary : (modelData.status === "error" ? Appearance.colors.colError : Appearance.colors.colPrimary)
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                StyledText {
                                    text: modelData.summary || modelData.tool
                                    font.pixelSize: Appearance.font.pixelSize.tiny
                                    font.weight: Font.DemiBold
                                    color: Appearance.colors.colOnLayer0
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                StyledText {
                                    text: `[Step ${modelData.step}] ${modelData.action || modelData.tool}`
                                    font.pixelSize: Appearance.font.pixelSize.tiny
                                    color: Appearance.colors.colSubtext
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }

            // ── TAB 4: PRIVATE SPELLING ASSISTANT ────────────────────────────
            ColumnLayout {
                visible: root.activeTab === "spelling"
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: "Private Spelling Assistant"
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.DemiBold
                        color: Appearance.colors.colOnLayer0
                    }
                    Item { Layout.fillWidth: true }
                    // Paste from clipboard button
                    Rectangle {
                        Layout.preferredHeight: 24
                        Layout.preferredWidth: 104
                        radius: 4
                        color: pasteBtnMouse.containsMouse ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer2

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            MaterialSymbol { text: "content_paste"; iconSize: 14; color: Appearance.colors.colPrimary }
                            StyledText { text: "Paste Clip"; font.pixelSize: Appearance.font.pixelSize.tiny; color: Appearance.colors.colOnLayer0 }
                        }
                        MouseArea {
                            id: pasteBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: SpellingService.pasteFromClipboard()
                        }
                    }
                }

                // Text Input Field for manual typing / checking
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    radius: 6
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: Appearance.colors.colOutlineVariant

                    TextInput {
                        id: spellInput
                        anchors.fill: parent
                        anchors.margins: 6
                        text: SpellingService.textToCheck
                        color: Appearance.colors.colOnLayer0
                        font.pixelSize: Appearance.font.pixelSize.small
                        selectByMouse: true
                        onTextChanged: SpellingService.checkText(text)
                    }
                }

                StyledText {
                    text: SpellingService.statusText
                    font.pixelSize: Appearance.font.pixelSize.tiny
                    color: Appearance.colors.colSubtext
                }

                // Suggestions list
                ListView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(80, SpellingService.issues.length * 36)
                    clip: true
                    model: SpellingService.issues
                    spacing: 4

                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view.width
                        height: 32
                        radius: 6
                        color: Appearance.colors.colLayer1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 8

                            StyledText {
                                text: modelData.word + " →"
                                font.pixelSize: Appearance.font.pixelSize.tiny
                                font.weight: Font.Bold
                                color: Appearance.colors.colError
                            }

                            Row {
                                spacing: 6
                                Repeater {
                                    model: modelData.suggestions
                                    Rectangle {
                                        required property string modelData
                                        width: suggText.implicitWidth + 12
                                        height: 22
                                        radius: 4
                                        color: suggMouse.containsMouse ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer2

                                        StyledText {
                                            id: suggText
                                            anchors.centerIn: parent
                                            text: modelData
                                            font.pixelSize: Appearance.font.pixelSize.tiny
                                            color: Appearance.colors.colPrimary
                                        }

                                        MouseArea {
                                            id: suggMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                spellInput.text = SpellingService.replaceWord(spellInput.text, modelData.word, modelData)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── TAB 5: CONTEXTUAL AI (LOCAL OLLAMA + SAFETY CONTROLS) ─────────
            ColumnLayout {
                visible: root.activeTab === "ai"
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: "Contextual AI"
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.DemiBold
                        color: Appearance.colors.colOnLayer0
                    }
                    Item { Layout.fillWidth: true }
                    // Provider / Local status badge
                    Rectangle {
                        Layout.preferredHeight: 20
                        Layout.preferredWidth: providerBadgeText.implicitWidth + 12
                        radius: 4
                        color: ContextualAiService.localOllamaOnline ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer2

                        StyledText {
                            id: providerBadgeText
                            anchors.centerIn: parent
                            text: ContextualAiService.provider === "ollama" ? (ContextualAiService.localOllamaOnline ? `Ollama (${ContextualAiService.model})` : "Ollama Offline") : ContextualAiService.provider
                            font.pixelSize: Appearance.font.pixelSize.tiny
                            color: ContextualAiService.localOllamaOnline ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
                        }
                    }
                }

                // Explicit File Attachment Permission Checkbox (Never auto-uploaded)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 26
                    radius: 4
                    color: Appearance.colors.colLayer1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 6

                        Rectangle {
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            radius: 3
                            border.width: 1
                            border.color: ContextualAiService.explicitAttachAllowed ? Appearance.colors.colPrimary : Appearance.colors.colOutline
                            color: ContextualAiService.explicitAttachAllowed ? Appearance.colors.colPrimary : "transparent"

                            MaterialSymbol {
                                anchors.centerIn: parent
                                visible: ContextualAiService.explicitAttachAllowed
                                text: "check"
                                iconSize: 12
                                color: Appearance.colors.colOnPrimary
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: ContextualAiService.explicitAttachAllowed = !ContextualAiService.explicitAttachAllowed
                            }
                        }

                        StyledText {
                            text: "Explicitly attach " + LivingBarState.files.length + " persistent file reference(s) to prompt"
                            font.pixelSize: Appearance.font.pixelSize.tiny
                            color: ContextualAiService.explicitAttachAllowed ? Appearance.colors.colOnLayer0 : Appearance.colors.colSubtext
                            Layout.fillWidth: true
                        }
                    }
                }

                // Prompt Input Box
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        radius: 6
                        color: Appearance.colors.colLayer1
                        border.width: 1
                        border.color: Appearance.colors.colOutlineVariant

                        TextInput {
                            id: aiPromptInput
                            anchors.fill: parent
                            anchors.margins: 6
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colOnLayer0
                            selectByMouse: true
                            onAccepted: sendAiQuery()
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 34
                        radius: 6
                        color: ContextualAiService.isGenerating ? Appearance.colors.colErrorContainer : Appearance.colors.colPrimaryContainer

                        StyledText {
                            anchors.centerIn: parent
                            text: ContextualAiService.isGenerating ? "Stop" : "Ask"
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.DemiBold
                            color: ContextualAiService.isGenerating ? Appearance.colors.colError : Appearance.colors.colPrimary
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (ContextualAiService.isGenerating) {
                                    ContextualAiService.cancel()
                                } else {
                                    sendAiQuery()
                                }
                            }
                        }
                    }
                }

                function sendAiQuery(): void {
                    const text = aiPromptInput.text.trim()
                    if (text.length > 0) {
                        ContextualAiService.query(text, LivingBarState.files)
                        aiPromptInput.text = ""
                    }
                }

                // AI Response Text Box
                Rectangle {
                    visible: ContextualAiService.responseText.length > 0 || ContextualAiService.errorText.length > 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: 6
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: ContextualAiService.errorText.length > 0 ? Appearance.colors.colError : Appearance.colors.colOutlineVariant

                    Flickable {
                        anchors.fill: parent
                        anchors.margins: 8
                        contentWidth: width
                        contentHeight: aiResponseText.implicitHeight
                        clip: true

                        StyledText {
                            id: aiResponseText
                            width: parent.width
                            text: ContextualAiService.errorText.length > 0 ? ContextualAiService.errorText : ContextualAiService.responseText
                            font.pixelSize: Appearance.font.pixelSize.tiny
                            color: ContextualAiService.errorText.length > 0 ? Appearance.colors.colError : Appearance.colors.colOnLayer0
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: 4 }
        }
    }

    StyledToolTip {
        visible: capsuleMouse.containsMouse && !root.expanded && !dropZone.containsDrag
        text: root.hasMedia ? `Living Bar — ${root.trackTitle}` : "Living Bar (Click to expand)"
    }

    Accessible.name: "NexUI Living Bar"
    Accessible.description: root.expanded ? "Living Bar expanded surface" : "Living Bar floating capsule"
    Accessible.role: Accessible.ToolBar
}
