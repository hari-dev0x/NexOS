pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common

/**
 * LivingBarState — Persistent state manager for the Nex Living Bar.
 *
 * Manages:
 *  - Floating desktop coordinates (x, y) with monitor bounds.
 *  - Persistent file collection (drag & drop references, verified accessibility).
 *  - User preferences for Agy activity display, local spelling, and Contextual AI.
 */
Singleton {
    id: root

    readonly property string stateFilePath: {
        const basePath = (typeof Directories !== "undefined" && Directories.statePath)
            ? Directories.statePath
            : (Quickshell.env("HOME") + "/.local/state/inir")
        return basePath + "/livingbar.json"
    }

    // --- Floating Position ---
    property real posX: 0
    property real posY: 8
    property bool hasCustomPos: false
    property string screenName: ""

    // --- Persistent File Collection ---
    // List of { path: string, name: string, exists: bool, size: int, addedAt: int }
    property var files: []

    // --- Contextual AI Preferences ---
    property string aiProvider: "ollama" // "ollama" | "gemini" | "none"
    property string aiModel: "qwen2.5:3b-instruct"
    property string aiEndpoint: "http://localhost:11434"
    property bool attachFilesToAi: false // STRICT DEFAULT: Never auto-attach without explicit user action

    // --- Spelling Preferences ---
    property string spellingLanguage: "en_US"
    property var recentSpellingChecks: []

    // --- Internal State Persistence ---
    property bool _loaded: false

    // Process to verify existence and metadata of held shelf files without blocking QML UI
    Process {
        id: fileVerifyProc
        property string rawResult: ""
        command: []

        stdout: SplitParser {
            onRead: chunk => {
                fileVerifyProc.rawResult += chunk
            }
        }

        onExited: (code, status) => {
            if (code === 0 && fileVerifyProc.rawResult.length > 0) {
                try {
                    const verified = JSON.parse(fileVerifyProc.rawResult)
                    if (Array.isArray(verified) && verified.length === root.files.length) {
                        let changed = false
                        const updated = root.files.map((f, i) => {
                            const info = verified[i]
                            if (info && (f.exists !== info.exists || f.size !== info.size)) {
                                changed = true
                                return Object.assign({}, f, { exists: !!info.exists, size: info.size || 0 })
                            }
                            return f
                        })
                        if (changed) {
                            root.files = updated
                        }
                    }
                } catch (e) {}
            }
        }
    }

    function reconcileFiles(): void {
        if (!root.files || root.files.length === 0) return
        fileVerifyProc.rawResult = ""
        const paths = root.files.map(f => f.path)
        fileVerifyProc.command = [
            "/usr/bin/python3",
            "-c",
            "import os, sys, json; paths=json.loads(sys.argv[1]); res=[{'exists': os.path.exists(p), 'size': os.path.getsize(p) if os.path.exists(p) else 0} for p in paths]; print(json.dumps(res))",
            JSON.stringify(paths)
        ]
        fileVerifyProc.running = true
    }

    FileView {
        id: stateFileView
        path: root.stateFilePath

        onLoaded: {
            root._loadFromJson(stateFileView.text())
        }

        onLoadFailed: error => {
            // New state or directory not yet created
            root._loaded = true
        }
    }

    Timer {
        id: saveDebounce
        interval: 300
        repeat: false
        onTriggered: root._saveToJson()
    }

    function scheduleSave(): void {
        if (!root._loaded) return
        saveDebounce.restart()
    }

    function setPosition(newX: real, newY: real, targetScreen: string): void {
        root.posX = newX
        root.posY = newY
        root.hasCustomPos = true
        root.screenName = targetScreen || ""
        root.scheduleSave()
    }

    function resetPosition(): void {
        root.hasCustomPos = false
        root.posX = 0
        root.posY = 8
        root.scheduleSave()
    }

    function addFile(urlOrPath: string): bool {
        if (!urlOrPath || urlOrPath.length === 0) return false

        let cleanPath = urlOrPath.toString()
        if (cleanPath.startsWith("file://")) {
            cleanPath = cleanPath.substring(7)
        }
        // Decode URL components (e.g. %20 -> space)
        try {
            cleanPath = decodeURIComponent(cleanPath)
        } catch (e) {}

        cleanPath = cleanPath.trim()
        if (cleanPath.length === 0) return false

        // Check duplicates
        for (let i = 0; i < root.files.length; ++i) {
            if (root.files[i].path === cleanPath) {
                return false
            }
        }

        const name = cleanPath.split("/").pop() || cleanPath
        const entry = {
            path: cleanPath,
            name: name,
            exists: true, // Will be verified dynamically
            size: 0,
            addedAt: Date.now()
        }

        const next = [...root.files, entry]
        root.files = next
        root.scheduleSave()
        root.reconcileFiles()
        return true
    }

    function removeFile(pathToRemove: string): void {
        const next = root.files.filter(f => f.path !== pathToRemove)
        if (next.length !== root.files.length) {
            root.files = next
            root.scheduleSave()
        }
    }

    function removeFileAt(index: int): void {
        if (index >= 0 && index < root.files.length) {
            const next = [...root.files]
            next.splice(index, 1)
            root.files = next
            root.scheduleSave()
        }
    }

    function clearFiles(): void {
        if (root.files.length > 0) {
            root.files = []
            root.scheduleSave()
        }
    }

    function markFileInaccessible(path: string): void {
        let changed = false
        const next = root.files.map(f => {
            if (f.path === path && f.exists) {
                changed = true
                return Object.assign({}, f, { exists: false })
            }
            return f
        })
        if (changed) {
            root.files = next
            root.scheduleSave()
        }
    }

    function _loadFromJson(rawJson: string): void {
        if (!rawJson || rawJson.trim().length === 0) {
            root._loaded = true
            return
        }
        try {
            const data = JSON.parse(rawJson)
            if (data.position) {
                root.posX = Number(data.position.x) || 0
                root.posY = Number(data.position.y) || 8
                root.hasCustomPos = !!data.position.hasCustomPos
                root.screenName = data.position.screenName || ""
            }
            if (Array.isArray(data.files)) {
                root.files = data.files.filter(f => f && typeof f.path === "string").map(f => ({
                    path: f.path,
                    name: f.name || f.path.split("/").pop() || "file",
                    exists: f.exists !== false,
                    size: Number(f.size) || 0,
                    addedAt: Number(f.addedAt) || Date.now()
                }))
                root.reconcileFiles()
            }
            if (data.ai) {
                root.aiProvider = data.ai.provider || "ollama"
                root.aiModel = data.ai.model || "qwen2.5:3b-instruct"
                root.aiEndpoint = data.ai.endpoint || "http://localhost:11434"
                // Never restore attachFilesToAi as true — user must explicitly enable each session
                root.attachFilesToAi = false
            }
            if (data.spelling) {
                root.spellingLanguage = data.spelling.language || "en_US"
            }
        } catch (e) {
            console.warn("[LivingBarState] Failed to parse state JSON:", e)
        }
        root._loaded = true
    }

    function _saveToJson(): void {
        const data = {
            version: 1,
            updatedAt: Date.now(),
            position: {
                x: root.posX,
                y: root.posY,
                hasCustomPos: root.hasCustomPos,
                screenName: root.screenName
            },
            files: root.files,
            ai: {
                provider: root.aiProvider,
                model: root.aiModel,
                endpoint: root.aiEndpoint
            },
            spelling: {
                language: root.spellingLanguage
            }
        }
        try {
            stateFileView.setText(JSON.stringify(data, null, 2))
        } catch (e) {
            console.warn("[LivingBarState] Failed to write state JSON:", e)
        }
    }
}
