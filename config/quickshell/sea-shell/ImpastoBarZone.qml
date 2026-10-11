import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire

// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   I M P A S T O   B A R   Z O N E                                        │
// │   one side of the bar · its capsules in layout order                     │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

Row {
    id: root

    property var rootRef: null
    property var islandRef: null

    spacing: ImpastoTheme.capsuleSpacing // 8px

    readonly property var sink: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
    readonly property int volPct: sink ? Math.round(sink.volume * 100) : (rootRef ? rootRef.volPct : 50)
    readonly property bool volMuted: sink ? sink.muted : (rootRef ? rootRef.volMuted : false)

    readonly property var batDev: UPower.displayDevice
    readonly property int batPct: batDev ? Math.round(batDev.percentage * 100) : 100
    readonly property bool batCharging: !UPower.onBattery

    // --- Capsule 1: Notifications ---
    Rectangle {
        id: notiCapsule
        height: ImpastoTheme.capsuleHeight
        width: notiChip.implicitWidth + 8
        radius: height / 2
        color: ImpastoTheme.island
        border.color: ImpastoTheme.islandBorder
        border.width: 1

        ImpastoBarChip {
            id: notiChip
            anchors.centerIn: parent
            alone: true
            icon: (rootRef && rootRef.cfgDnd) ? "󰂛" : "󰂚"
            text: (rootRef && rootRef.notiHistory && rootRef.notiHistory.length > 0)
                ? ("" + rootRef.notiHistory.length)
                : ""
            tint: (rootRef && rootRef.cfgDnd) ? ImpastoTheme.indicatorWarn : ImpastoTheme.text
            onClicked: {
                if (rootRef) {
                    rootRef.openPop = (rootRef.openPop === "noti") ? "" : "noti";
                }
            }
        }
    }

    // --- Capsule 2: Hardware Status (Network · Bluetooth · Volume · Battery) ---
    Rectangle {
        id: statusCapsule
        height: ImpastoTheme.capsuleHeight
        width: statusRow.implicitWidth + 8
        radius: height / 2
        color: ImpastoTheme.island
        border.color: ImpastoTheme.islandBorder
        border.width: 1

        Row {
            id: statusRow
            anchors.centerIn: parent
            height: ImpastoTheme.capsuleHeight
            spacing: 0

            // Network
            ImpastoBarChip {
                id: netChip
                anchors.verticalCenter: parent.verticalCenter
                icon: (rootRef && rootRef.netIcon) ? rootRef.netIcon : "󰖩"
                text: (rootRef && rootRef.netSsid) ? rootRef.netSsid : ""
                tint: ImpastoTheme.text
                onClicked: {
                    if (rootRef) rootRef.openPop = (rootRef.openPop === "net") ? "" : "net";
                }
            }

            // Bluetooth
            ImpastoBarChip {
                id: btChip
                anchors.verticalCenter: parent.verticalCenter
                icon: (rootRef && rootRef.btActive && typeof rootRef.btIcon === "function") ? rootRef.btIcon(rootRef.btActive) : "󰂯"
                text: (rootRef && rootRef.btActive) ? (rootRef.btActive.name || "") : ""
                tint: (rootRef && rootRef.btActive) ? ImpastoTheme.accent : ImpastoTheme.textMuted
                onClicked: {
                    if (rootRef) rootRef.openPop = (rootRef.openPop === "bt") ? "" : "bt";
                }
            }

            // Volume
            ImpastoBarChip {
                id: volChip
                anchors.verticalCenter: parent.verticalCenter
                icon: {
                    if (root.volMuted) return "󰝟";
                    if (root.volPct <= 0) return "󰕿";
                    if (root.volPct < 50) return "󰖀";
                    return "󰕾";
                }
                text: root.volMuted ? "Muted" : (root.volPct + "%")
                tint: root.volMuted ? ImpastoTheme.indicatorWarn : ImpastoTheme.text
                onClicked: {
                    if (root.sink) root.sink.muted = !root.sink.muted;
                    else if (rootRef) rootRef.openPop = (rootRef.openPop === "vol") ? "" : "vol";
                }
            }

            // Battery
            ImpastoBarChip {
                id: batChip
                anchors.verticalCenter: parent.verticalCenter
                icon: {
                    if (root.batCharging) return "󰂄";
                    if (root.batPct > 90) return "󰁹";
                    if (root.batPct > 60) return "󰂀";
                    if (root.batPct > 30) return "󰁾";
                    return "󰁻";
                }
                text: root.batPct + "%"
                tint: {
                    if (!root.batCharging && root.batPct <= 15) return ImpastoTheme.indicatorBad;
                    if (!root.batCharging && root.batPct <= 25) return ImpastoTheme.indicatorWarn;
                    return ImpastoTheme.text;
                }
                onClicked: {
                    if (rootRef) rootRef.openPop = (rootRef.openPop === "pwr") ? "" : "pwr";
                }
            }
        }
    }

    // --- Capsule 3: Control Center / Session Button ---
    Rectangle {
        id: controlsCapsule
        height: ImpastoTheme.capsuleHeight
        width: ImpastoTheme.capsuleHeight
        radius: height / 2
        color: ImpastoTheme.island
        border.color: ImpastoTheme.islandBorder
        border.width: 1

        ImpastoBarChip {
            anchors.centerIn: parent
            alone: true
            icon: "󰨚"
            tint: ImpastoTheme.text
            onClicked: {
                if (islandRef) {
                    islandRef.toggle("controls");
                }
            }
        }
    }
}
