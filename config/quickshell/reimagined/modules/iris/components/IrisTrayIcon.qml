pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import qs.services
import qs.modules.iris.style

// A tray icon. Modernizes legacy system tray items (e.g. blueman's blue box and nm-applet's dated signal bars)
// to clean macOS-style vector marks, while rendering standard tray app icons untouched with theme tinting.
Item {
    id: root

    property var source: ""
    property var item: null
    property real implicitSize: 18
    property color tint: IrisStyle.light ? IrisStyle.inkOnLight : IrisStyle.text

    implicitWidth: root.implicitSize
    implicitHeight: root.implicitSize

    readonly property string srcStr: String(root.source ?? "").toLowerCase()
    readonly property string itemId: String(root.item?.id ?? "").toLowerCase()

    readonly property bool isBluetooth: root.srcStr.includes("blueman") || root.srcStr.includes("bluetooth")
        || root.itemId.includes("blueman") || root.itemId.includes("bluetooth")
    readonly property bool isWifi: root.srcStr.includes("nm-signal") || root.srcStr.includes("nm-applet") || root.srcStr.includes("wifi")
        || root.itemId.includes("nm-applet") || root.itemId.includes("wifi")

    readonly property int wifiSignal: {
        const match = root.srcStr.match(/nm-signal-(\d+)/)
        if (match) return parseInt(match[1])
        return Network.networkStrength
    }

    IrisWifiMark {
        anchors.fill: parent
        visible: root.isWifi
        wifiEnabled: Network.wifiEnabled
        connected: Network.wifiStatus === "connected" || Network.wifiStatus === "limited" || root.wifiSignal > 0
        strength: root.wifiSignal
        tint: root.tint
    }

    IrisBluetoothMark {
        anchors.fill: parent
        visible: root.isBluetooth
        btEnabled: BluetoothStatus.enabled
        connected: BluetoothStatus.connected || BluetoothStatus.activeDeviceCount > 0
        tint: root.tint
    }

    IconImage {
        id: stdIcon
        visible: !root.isBluetooth && !root.isWifi
        anchors.fill: parent
        source: root.source
        readonly property bool template: /mono|symbolic|panel|-light|_light|white/i.test(String(stdIcon.source))
        layer.enabled: IrisStyle.light && stdIcon.template
        layer.effect: MultiEffect { brightness: -1 }
    }
}
