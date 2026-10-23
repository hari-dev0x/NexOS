pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

/**
 * AgyActivityAdapter — Observable event adapter for Antigravity (Agy) sessions.
 *
 * Discovers and streams actual verified agent events from legitimate system logs:
 *   - Transcript logs: ~/.gemini/antigravity-cli/brain/<conv-id>/.system_generated/logs/transcript.jsonl
 *   - Recent history: ~/.gemini/antigravity-cli/history.jsonl
 *
 * Strict policy:
 *   - ONLY displays confirmed observed events (tool call, command, file edit, result, error).
 *   - NEVER invents fake progress percentages or unverified activities.
 */
Singleton {
    id: root

    property string transcriptPath: ""
    property bool isMonitoring: false
    property bool hasActivity: false

    // Last observed state
    property string lastSummary: "Idle"
    property string lastAction: "Waiting for task"
    property string lastToolName: ""
    property string lastStatus: "idle" // "running" | "done" | "error" | "idle"
    property string lastTimestamp: ""
    property int lastStepIndex: -1

    // Verified event log list: [{ step: int, type: string, tool: string, summary: string, action: string, status: string, time: string }]
    property var events: []
    property int _lastParsedLength: 0

    // Dynamic discovery process to find active conversation transcript without hardcoded IDs
    Process {
        id: convDiscoverProc
        command: ["/usr/bin/sh", "-c", "ls -t $HOME/.gemini/antigravity-cli/brain/*/.system_generated/logs/transcript.jsonl 2>/dev/null | head -n 1"]
        stdout: SplitParser {
            onRead: data => {
                const found = data.trim()
                if (found.length > 0 && found !== root.transcriptPath) {
                    root.setTranscriptPath(found)
                }
            }
        }
    }

    // Dynamic discovery timer checks for conversation switches/starts
    Timer {
        id: discoveryTimer
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!convDiscoverProc.running) {
                convDiscoverProc.running = true
            }
        }
    }

    FileView {
        id: transcriptFileView
        path: root.transcriptPath

        onLoaded: {
            root._parseTranscript(transcriptFileView.text())
        }

        onLoadFailed: error => {
            root.hasActivity = false
            root.lastStatus = "idle"
        }
    }

    Timer {
        id: pollTimer
        interval: 2000
        repeat: true
        running: root.transcriptPath.length > 0
        onTriggered: {
            if (transcriptFileView.path.length > 0) {
                transcriptFileView.reload()
            }
        }
    }

    function setTranscriptPath(filePath: string): void {
        if (!filePath || filePath === root.transcriptPath) return
        root.transcriptPath = filePath
        root._lastParsedLength = 0
        root.isMonitoring = true
        transcriptFileView.path = filePath
        transcriptFileView.reload()
    }

    function loadFixtureContent(jsonlContent: string): void {
        root._lastParsedLength = 0
        root._parseTranscript(jsonlContent)
    }

    function _parseTranscript(rawText: string): void {
        if (!rawText || rawText.trim().length === 0) return
        if (rawText.length === root._lastParsedLength) return
        root._lastParsedLength = rawText.length

        const lines = rawText.split("\n")
        const parsedEvents = []
        let latestStep = -1
        let latestSummary = "Idle"
        let latestAction = "No active task"
        let latestTool = ""
        let latestStatus = "idle"
        let latestTime = ""

        // Process recent lines (bounded for responsiveness and low memory usage)
        const startIdx = Math.max(0, lines.length - 100)
        for (let i = startIdx; i < lines.length; ++i) {
            const line = lines[i].trim()
            if (line.length === 0) continue

            try {
                const entry = JSON.parse(line)
                const step = entry.step_index ?? i
                const timeStr = entry.created_at || ""

                if (entry.type === "PLANNER_RESPONSE" && Array.isArray(entry.tool_calls) && entry.tool_calls.length > 0) {
                    for (let j = 0; j < entry.tool_calls.length; ++j) {
                        const call = entry.tool_calls[j]
                        const toolName = call.name || "tool"
                        const args = call.args || {}
                        const summary = args.toolSummary || (toolName === "run_command" ? "Shell Command" : toolName)
                        const action = args.toolAction || summary

                        latestStep = step
                        latestSummary = summary
                        latestAction = action
                        latestTool = toolName
                        latestStatus = "running"
                        latestTime = timeStr

                        parsedEvents.push({
                            step: step,
                            type: "tool_call",
                            tool: toolName,
                            summary: summary,
                            action: action,
                            status: "running",
                            time: timeStr
                        })
                    }
                } else if (entry.type === "GENERIC" && entry.source === "MODEL") {
                    // Result step for the last tool call
                    if (parsedEvents.length > 0) {
                        parsedEvents[parsedEvents.length - 1].status = (entry.status === "ERROR") ? "error" : "done"
                    }
                    latestStatus = (entry.status === "ERROR") ? "error" : "done"
                    latestTime = timeStr
                } else if (entry.type === "USER_INPUT") {
                    latestStep = step
                    latestSummary = "User Request Received"
                    latestAction = "Processing prompt"
                    latestTool = "user_input"
                    latestStatus = "running"
                    latestTime = timeStr

                    parsedEvents.push({
                        step: step,
                        type: "user_input",
                        tool: "user_input",
                        summary: "User Prompt",
                        action: "Processing instructions",
                        status: "done",
                        time: timeStr
                    })
                }
            } catch (e) {
                // Ignore malformed lines
            }
        }

        if (parsedEvents.length > 0) {
            root.hasActivity = true
            root.lastStepIndex = latestStep
            root.lastSummary = latestSummary
            root.lastAction = latestAction
            root.lastToolName = latestTool
            root.lastStatus = latestStatus
            root.lastTimestamp = latestTime
            // Retain the last 15 verified events in reverse chronological order
            root.events = parsedEvents.slice(-15).reverse()
        }
    }
}
