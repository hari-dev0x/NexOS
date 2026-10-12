// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   N E X O S   R E I M A G I N E D   ·   N E X   C O M P A N I O N        │
// │   Inactive compatibility contract interface & companion lifecycle states │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick

pragma Singleton

QtObject {
    id: root

    // ── Contract States ───────────────────────────────────────────────────
    readonly property string stateIdle: "idle"
    readonly property string stateFocused: "focused"
    readonly property string stateWorking: "working"
    readonly property string stateWaiting: "waiting"
    readonly property string stateUnavailable: "unavailable"

    // ── Current State Properties ──────────────────────────────────────────
    // Hidden and inactive by default: zero threads, zero network or IPC overhead
    property bool isActive: false
    property string currentState: stateUnavailable
    property string statusMessage: "Companion dormant"
    property string activeAgent: "Nex"
    property real confidenceScore: 1.0
    property string lastQuery: ""

    // ── Contract Signals ──────────────────────────────────────────────────
    signal stateTransition(string oldState, string newState)
    signal promptDispatched(string prompt)
    signal responseArrived(string response)
    signal errorReported(string message)

    // ── Public Contract Methods ───────────────────────────────────────────
    function activate(): bool {
        if (!isActive) {
            var prev = currentState;
            isActive = true;
            currentState = stateIdle;
            statusMessage = "Ready";
            stateTransition(prev, currentState);
            return true;
        }
        return false;
    }

    function deactivate(): bool {
        if (isActive) {
            var prev = currentState;
            isActive = false;
            currentState = stateUnavailable;
            statusMessage = "Companion dormant";
            stateTransition(prev, currentState);
            return true;
        }
        return false;
    }

    function dispatchQuery(promptText: string): bool {
        if (!isActive) return false;
        lastQuery = promptText;
        var prev = currentState;
        currentState = stateWorking;
        statusMessage = "Processing...";
        stateTransition(prev, currentState);
        promptDispatched(promptText);
        return true;
    }

    function cancelCurrentTask() {
        if (currentState === stateWorking || currentState === stateWaiting) {
            var prev = currentState;
            currentState = stateIdle;
            statusMessage = "Ready";
            stateTransition(prev, currentState);
        }
    }
}
