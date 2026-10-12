// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   S O U N D   D E T A I L                                                │
// │   Comprehensive audio control surface · Master, apps, outputs & inputs   │
// │                                                                          │
// │   Reused & adapted from Impasto (github.com/andreumassanet/impasto)      │
// │   License: GPL-3.0 · Adapted for NexOS Reimagined                        │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../tokens"
import "../services"

ColumnLayout {
    id: root

    signal closeRequested()

    spacing: Tokens.s3
    Layout.fillWidth: true

    // Heading row with active output name and back button
    DetailHeading {
        title: "Sound & Audio Routing"
        detail: AudioService.ready ? AudioService.outputName(AudioService.sink) : "PipeWire Audio Server"
        isLive: AudioService.ready
        onBack: root.closeRequested()
    }

    // ── 1. Master Output Volume Section ────────────────────────────────────
    DetailSection {
        title: "Master Output"

        LevelRow {
            glyph: AudioService.icon
            name: AudioService.ready ? AudioService.outputName(AudioService.sink) : "Default Sink"
            value: AudioService.volume
            available: AudioService.ready
            dimmed: AudioService.muted
            onMoved: (v) => AudioService.setVolume(v)
            onMarkClicked: AudioService.toggleMute()
        }
    }

    // ── 2. Per-Application Streams Section ─────────────────────────────────
    DetailSection {
        title: "Applications (" + AudioService.streams.length + ")"
        visible: AudioService.streams.length > 0

        Repeater {
            model: AudioService.streams

            LevelRow {
                id: appRow
                required property var modelData

                picture: AudioService.streamIcon(appRow.modelData)
                name: AudioService.streamName(appRow.modelData)
                value: appRow.modelData && appRow.modelData.audio ? Math.round(appRow.modelData.audio.volume * 100) : 0
                dimmed: appRow.modelData && appRow.modelData.audio ? appRow.modelData.audio.muted : false
                available: appRow.modelData && appRow.modelData.audio !== null
                onMoved: (v) => AudioService.setStreamVolume(appRow.modelData, v)
                onMarkClicked: AudioService.toggleStreamMute(appRow.modelData)
            }
        }
    }

    // ── 3. Output Device Selection Section ─────────────────────────────────
    DetailSection {
        title: "Output Devices"
        visible: AudioService.outputs.length > 0

        Repeater {
            model: AudioService.outputs

            DetailChoice {
                required property var modelData

                text: AudioService.outputName(modelData)
                chosen: AudioService.sink === modelData
                icon: "󰓃"
                onPicked: AudioService.choose(modelData)
            }
        }
    }

    // ── 4. Microphone Input Section ────────────────────────────────────────
    DetailSection {
        title: "Microphone & Input"
        visible: AudioService.sourceReady || AudioService.inputs.length > 0

        LevelRow {
            glyph: AudioService.sourceIcon
            name: AudioService.sourceReady ? AudioService.outputName(AudioService.source) : "Input Source"
            value: AudioService.sourceVolume
            available: AudioService.sourceReady
            dimmed: AudioService.sourceMuted
            onMoved: (v) => AudioService.setSourceVolume(v)
            onMarkClicked: AudioService.toggleSourceMute()
        }

        Repeater {
            model: AudioService.inputs

            DetailChoice {
                required property var modelData

                text: AudioService.outputName(modelData)
                chosen: AudioService.source === modelData
                icon: "󰍬"
                onPicked: AudioService.chooseInput(modelData)
            }
        }
    }
}
