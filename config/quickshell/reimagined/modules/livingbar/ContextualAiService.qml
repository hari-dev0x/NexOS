pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

/**
 * ContextualAiService — Provider-independent AI interface for Nex Living Bar.
 *
 * Capabilities:
 *  - Supports local Ollama-compatible endpoints (http://localhost:11434) with zero remote leakage.
 *  - Optional remote provider (Gemini) strictly opt-in.
 *  - Fully functional and useful even when no AI provider is configured or available.
 *  - Strict safety: NEVER uploads or sends persistent files automatically. Explicit attachment
 *    must be user-toggled per query.
 */
Singleton {
    id: root

    property string provider: LivingBarState.aiProvider // "ollama" | "gemini" | "none"
    property string model: LivingBarState.aiModel
    property string endpoint: LivingBarState.aiEndpoint
    property bool isGenerating: false
    property string responseText: ""
    property string errorText: ""
    property bool localOllamaOnline: false
    property var localModels: []

    // Explicit confirmation toggle: MUST be true to attach file contents
    property bool explicitAttachAllowed: false

    // Health check process for local Ollama
    Process {
        id: healthCheckProc
        command: ["/usr/bin/curl", "-s", "--connect-timeout", "2", root.endpoint + "/api/tags"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const res = JSON.parse(data)
                    if (Array.isArray(res.models)) {
                        root.localOllamaOnline = true
                        root.localModels = res.models.map(m => m.name)
                        if (root.localModels.length > 0 && !root.localModels.includes(root.model)) {
                            root.model = root.localModels[0]
                        }
                    }
                } catch (e) {
                    root.localOllamaOnline = false
                }
            }
        }
        onExited: (code, status) => {
            if (code !== 0) {
                root.localOllamaOnline = false
            }
        }
    }

    Timer {
        id: healthCheckTimer
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (root.provider === "ollama") {
                healthCheckProc.running = true
            }
        }
    }

    // Query execution process via local curl
    Process {
        id: queryProc
        property string rawResponse: ""

        onStarted: {
            queryProc.rawResponse = ""
            root.isGenerating = true
            root.errorText = ""
            root.responseText = ""
        }

        stdout: SplitParser {
            onRead: chunk => {
                queryProc.rawResponse += chunk
            }
        }

        onExited: (code, status) => {
            root.isGenerating = false
            if (code !== 0) {
                root.errorText = "Request failed or timed out (exit code: " + code + ")"
                return
            }
            try {
                const res = JSON.parse(queryProc.rawResponse)
                if (res.response) {
                    root.responseText = res.response.trim()
                } else if (res.message && res.message.content) {
                    root.responseText = res.message.content.trim()
                } else if (res.error) {
                    root.errorText = String(res.error)
                } else {
                    root.responseText = queryProc.rawResponse.trim()
                }
            } catch (e) {
                root.responseText = queryProc.rawResponse.trim()
            }
            if (root.responseText.length === 0 && root.errorText.length === 0) {
                root.errorText = "No response generated"
            }
        }
    }

    function checkHealth(): void {
        healthCheckProc.running = true
    }

    function cancel(): void {
        if (queryProc.running) {
            queryProc.running = false
        }
        root.isGenerating = false
    }

    function query(userPrompt: string, filesToAttach: var): void {
        if (!userPrompt || userPrompt.trim().length === 0) return

        root.errorText = ""
        root.responseText = ""

        // Handle offline/disabled provider mode gracefully
        if (root.provider === "none") {
            root._generateOfflineHelp(userPrompt)
            return
        }

        // Construct context safely
        let finalPrompt = userPrompt.trim()

        // STRICT POLICY: Only attach files if user explicitly enabled attachment
        if (root.explicitAttachAllowed && Array.isArray(filesToAttach) && filesToAttach.length > 0) {
            let fileContext = "=== ATTACHED LOCAL FILE REFERENCES ===\n"
            for (let i = 0; i < filesToAttach.length; ++i) {
                const f = filesToAttach[i]
                fileContext += `[File: ${f.name} (${f.path})]\n`
            }
            fileContext += "======================================\n\n"
            finalPrompt = fileContext + finalPrompt
        }

        if (root.provider === "ollama") {
            if (!root.localOllamaOnline) {
                root.errorText = "Local Ollama service not detected on " + root.endpoint
                return
            }

            const payload = JSON.stringify({
                model: root.model,
                prompt: finalPrompt,
                stream: false
            })

            queryProc.command = [
                "/usr/bin/curl",
                "-s",
                "--connect-timeout", "5",
                "--max-time", "120",
                "-X", "POST",
                root.endpoint + "/api/generate",
                "-H", "Content-Type: application/json",
                "-d", payload
            ]
            queryProc.running = true
        } else if (root.provider === "gemini") {
            // Optional remote provider
            const apiKey = Quickshell.env("GEMINI_API_KEY") || ""
            if (apiKey.length === 0) {
                root.errorText = "GEMINI_API_KEY environment variable not set. Please set it or switch to local Ollama."
                return
            }

            const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`
            const payload = JSON.stringify({
                contents: [{ parts: [{ text: finalPrompt }] }]
            })

            queryProc.command = [
                "/usr/bin/curl",
                "-s",
                "--connect-timeout", "5",
                "--max-time", "60",
                "-X", "POST",
                url,
                "-H", "Content-Type: application/json",
                "-d", payload
            ]
            queryProc.running = true
        }
    }

    // Pure local utility when no AI provider is configured
    function _generateOfflineHelp(userPrompt: string): void {
        const lower = userPrompt.toLowerCase().trim()
        const wordCount = userPrompt.trim().split(/\s+/).length
        const charCount = userPrompt.length

        let result = `[Local Mode — No Remote AI Provider Configured]\n\n`
        result += `• Prompt Metrics: ${wordCount} words, ${charCount} characters.\n`
        if (lower.includes("file") || lower.includes("collection")) {
            result += `• Persistent Collection: ${LivingBarState.files.length} file(s) currently held.\n`
        }
        if (lower.includes("spell") || lower.includes("check")) {
            result += `• Tip: Use the Spelling tab for private, offline word analysis.\n`
        }
        if (lower.includes("help")) {
            result += `• Available local modes: Ollama (port 11434), Local Offline Tools, Spelling Assistant.\n`
        } else {
            result += `• Select 'Ollama' in settings to use local offline models like Qwen2.5 without network calls.`
        }

        root.responseText = result
    }
}
