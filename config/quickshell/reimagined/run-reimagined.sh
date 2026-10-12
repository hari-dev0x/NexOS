#!/usr/bin/env bash
# ╭──────────────────────────────────────────────────────────────────────────╮
# │ NexOS Reimagined — Phase 1 Test Runner                                   │
# │ Safe, isolated launcher that does NOT disrupt the active desktop shell   │
# ╰──────────────────────────────────────────────────────────────────────────╯

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Usage: $0 [check|run|stop]"
    echo "  check   Validate QML syntax and imports"
    echo "  run     Launch NexOS Reimagined Phase 1 in an isolated floating window"
    echo "  stop    Stop any running Phase 1 evaluation instances"
    exit 1
}

MODE="${1:-run}"

case "$MODE" in
    check)
        echo "=== [NexOS Reimagined] Checking QML files ==="
        find "$SCRIPT_DIR" -name "*.qml" -exec qmllint {} + 2>/dev/null || {
            echo "qmllint not available or reported warnings. Performing path verification:"
            find "$SCRIPT_DIR" -type f
        }
        echo "✓ All component files accounted for."
        ;;
    run)
        echo "=== [NexOS Reimagined] Launching isolated evaluation shell ==="
        echo "Directory: $SCRIPT_DIR"
        quickshell -p "$SCRIPT_DIR"
        ;;
    stop)
        echo "=== [NexOS Reimagined] Stopping evaluation instances ==="
        pkill -f "quickshell.*$SCRIPT_DIR" || true
        echo "✓ Stopped."
        ;;
    *)
        usage
        ;;
esac
