#!/usr/bin/env bash
# ╭──────────────────────────────────────────────────────────────────────────╮
# │ NexUI — Primary Desktop Shell Launcher (iNiR Architecture)                │
# │ Full Island/iRiS integration on CachyOS + Niri + Quickshell               │
# ╰──────────────────────────────────────────────────────────────────────────╯

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_RUNNER="$SCRIPT_DIR/config/quickshell/reimagined/run-reimagined.sh"

if [[ ! -f "$TARGET_RUNNER" ]]; then
    echo "ERROR: Shell runner not found at $TARGET_RUNNER" >&2
    exit 1
fi

exec "$TARGET_RUNNER" "$@"
