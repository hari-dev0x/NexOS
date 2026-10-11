#!/usr/bin/env bash
# NexOS Deterministic Plymouth Termination & Handoff Synchronizer
# Ensures all 130 frames, the glitch transition, and Samsung hold complete before handoff to SDDM
set -euo pipefail

# 1. If plymouth is not running, nothing to do
if ! /usr/bin/plymouth --ping 2>/dev/null; then
    exit 0
fi

PID_FILE="/run/plymouth/pid"
if [ ! -f "$PID_FILE" ]; then
    /usr/bin/plymouth quit --retain-splash || true
    exit 0
fi

PLY_PID=$(cat "$PID_FILE" 2>/dev/null || true)
if [ -z "$PLY_PID" ] || [ ! -d "/proc/$PLY_PID" ]; then
    /usr/bin/plymouth quit --retain-splash || true
    exit 0
fi

# 2. Calculate exact elapsed time of plymouthd
# 130 frames @ 30 FPS = 4.333s
# 9 transition frames @ 30 FPS = 0.300s
# Brief stable Samsung hold = 0.600s
# Total minimum animation lifecycle = 5.233s (~5.25s)
MIN_DURATION="5.25"

STAT=($(cat "/proc/$PLY_PID/stat" 2>/dev/null || echo ""))
if [ "${#STAT[@]}" -ge 22 ]; then
    START_TICKS="${STAT[21]}"
    CLK_TCK=$(getconf CLK_TCK 2>/dev/null || echo 100)
    UPTIME=$(cat /proc/uptime 2>/dev/null | awk '{print $1}')
    
    if [ -n "$START_TICKS" ] && [ -n "$UPTIME" ]; then
        START_SEC=$(awk "BEGIN {print $START_TICKS / $CLK_TCK}")
        ELAPSED=$(awk "BEGIN {print $UPTIME - $START_SEC}")
        
        REMAIN=$(awk "BEGIN {d = $MIN_DURATION - $ELAPSED; if (d > 0) print d; else print 0}")
        if (( $(awk "BEGIN {print ($REMAIN > 0)}") )); then
            # Deterministic wait for the remaining animation lifecycle
            sleep "$REMAIN"
        fi
    fi
fi

# 3. Request clean quit retaining the splash framebuffer
/usr/bin/plymouth quit --retain-splash || true

# 4. Wait for plymouthd to finish exiting cleanly
/usr/bin/plymouth --wait || true

exit 0
