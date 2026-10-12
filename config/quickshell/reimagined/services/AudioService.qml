// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   A U D I O   S E R V I C E                                              │
// │   Default sink volume, output selection & app streams via PipeWire       │
// │                                                                          │
// │   Reused & adapted from Impasto (github.com/andreumassanet/impasto)      │
// │   License: GPL-3.0 · Adapted for NexOS Reimagined                        │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

import "../tokens"

Singleton {
    id: root

    // ── Live PipeWire Connection ───────────────────────────────────────────
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: root.sink !== null && root.sink.ready

    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool sourceReady: root.source !== null && root.source.ready
    readonly property bool sourceMuted: root.sourceReady && root.source.audio ? root.source.audio.muted : false
    readonly property string sourceIcon: root.sourceMuted ? "󰍭" : "󰍬"

    // Volume level (0–100 percent)
    readonly property int volume: root.ready && root.sink.audio ? Math.round(root.sink.audio.volume * 100) : 0
    readonly property bool muted: root.ready && root.sink.audio ? root.sink.audio.muted : false

    readonly property string icon: {
        if (!root.ready || root.muted)
            return "󰝟";
        if (root.volume === 0)
            return "󰕿";
        return root.volume < 50 ? "󰖀" : "󰕾";
    }

    readonly property int sourceVolume: root.sourceReady && root.source.audio
        ? Math.round(root.source.audio.volume * 100) : 0

    // ── Outputs, Streams & Inputs ──────────────────────────────────────────
    // All available audio sinks
    readonly property var outputs: {
        if (!Pipewire.nodes || !Pipewire.nodes.values) return [];
        return Pipewire.nodes.values
            .filter(node => node.isSink && !node.isStream && node.audio)
            .sort((a, b) => {
                const digital = node => /HDMI|DisplayPort/.test(node.description || node.name) ? 1 : 0;
                return digital(a) - digital(b)
                    || (a.description || a.name).localeCompare(b.description || b.name, undefined, { numeric: true });
            });
    }

    // Applications currently playing audio (active audio output streams)
    readonly property var streams: {
        if (!Pipewire.nodes || !Pipewire.nodes.values) return [];
        return Pipewire.nodes.values
            .filter(node => node.type === PwNodeType.AudioOutStream && node.audio);
    }

    // Microphones and audio input sources
    readonly property var inputs: {
        if (!Pipewire.nodes || !Pipewire.nodes.values) return [];
        return Pipewire.nodes.values
            .filter(node => !node.isSink && !node.isStream && node.audio
                    && (node.properties && node.properties["media.class"] ? node.properties["media.class"] : "") === "Audio/Source");
    }

    // Recording streams
    readonly property var inStreams: {
        if (!Pipewire.nodes || !Pipewire.nodes.values) return [];
        return Pipewire.nodes.values.filter(node => node.type === PwNodeType.AudioInStream);
    }

    readonly property var captures: {
        return root.inStreams.filter(node => {
            if (!node.ready) return false;
            const props = node.properties ? node.properties : {};
            return props["stream.capture.sink"] !== "true" && props["stream.monitor"] !== "true"
                && props["application.name"] !== "cava";
        });
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
            .concat(root.outputs)
            .concat(root.streams)
            .concat(root.inputs)
            .concat(root.inStreams)
    }

    readonly property string outputPrefix: {
        const names = root.outputs.map(node => (node.description || node.name).split(" "));
        if (names.length < 2)
            return "";
        let shared = 0;
        while (names.every(words => shared < words.length - 1 && words[shared] === names[0][shared]))
            shared++;
        return names[0].slice(0, shared).join(" ");
    }

    function outputName(node) {
        if (!node) return "Default Output";
        var full = node.description || node.nickname || node.name || "Output Device";
        var shortName = root.outputPrefix !== "" && full.startsWith(root.outputPrefix)
            ? full.slice(root.outputPrefix.length).trim() : full;
        return shortName.replace(/^HDMI \/ DisplayPort (\d+) Output$/, "HDMI $1");
    }

    function choose(node) {
        if (node) {
            Pipewire.preferredDefaultAudioSink = node;
        }
    }

    function chooseInput(node) {
        if (node) {
            Pipewire.preferredDefaultAudioSource = node;
        }
    }

    function streamName(node) {
        if (!node) return "Application";
        const props = node.properties ? node.properties : {};
        const raw = props["application.name"] || props["application.process.binary"] || node.name || "Audio Stream";
        return raw.charAt(0).toUpperCase() + raw.slice(1);
    }

    function streamIcon(node) {
        if (!node) return "";
        const props = node.properties ? node.properties : {};
        const named = props["application.icon-name"] || props["application.process.binary"] || "";
        return named !== "" ? Quickshell.iconPath(named.toLowerCase(), true) : "";
    }

    function setStreamVolume(node, percent) {
        if (node && node.audio) {
            node.audio.volume = Math.max(0, Math.min(100, percent)) / 100;
        }
    }

    function toggleStreamMute(node) {
        if (node && node.audio) {
            node.audio.muted = !node.audio.muted;
        }
    }

    function setSourceVolume(percent) {
        if (root.sourceReady && root.source.audio) {
            root.source.audio.volume = Math.max(0, Math.min(100, percent)) / 100;
        }
    }

    function setVolume(percent) {
        if (!root.ready || !root.sink.audio)
            return;
        root.sink.audio.volume = Math.max(0, Math.min(100, percent)) / 100;
    }

    function toggleMute() {
        if (!root.ready || !root.sink.audio)
            return;
        root.sink.audio.muted = !root.sink.audio.muted;
    }

    function toggleSourceMute() {
        if (!root.sourceReady || !root.source.audio)
            return;
        root.source.audio.muted = !root.source.audio.muted;
    }

    // Panel layout calculations (derived from Impasto formulas adapted to Tokens)
    readonly property int panelWidth: 440
    readonly property int panelHeight: {
        const headerHeight = 44;
        const padding = Tokens.s4 * 2;
        const masterVolumeHeight = 64;
        const appsHeight = root.streams.length > 0 ? (28 + root.streams.length * 48) : 0;
        const outputsHeight = root.outputs.length > 0 ? (28 + root.outputs.length * 40) : 0;
        const inputsHeight = root.inputs.length > 0 ? (28 + 48 + root.inputs.length * 40) : 0;
        return padding + headerHeight + masterVolumeHeight + appsHeight + outputsHeight + inputsHeight;
    }
}
