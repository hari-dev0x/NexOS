#!/usr/bin/env bash
# ╭──────────────────────────────────────────────────────────────────────────╮
# │ NexUI — Authoritative Desktop Shell Supervisor                           │
# │ Resilient, isolated background supervisor on CachyOS + Niri + Quickshell │
# ╰──────────────────────────────────────────────────────────────────────────╯

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Identify the graphical session (compositor + Wayland display)
get_session_id() {
    local comp="generic"
    if [[ -n "${NIRI_SOCKET:-}" ]] || [[ "${XDG_CURRENT_DESKTOP:-}" =~ [Nn]iri ]]; then
        comp="niri"
    elif [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] || [[ "${XDG_CURRENT_DESKTOP:-}" =~ [Hh]yprland ]]; then
        comp="hyprland"
    elif [[ -n "${XDG_CURRENT_DESKTOP:-}" ]]; then
        comp="$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]_-')"
    fi

    local disp="${WAYLAND_DISPLAY:-default}"
    disp="$(echo "$disp" | tr -cd '[:alnum:]_-')"

    echo "${comp}-${disp}"
}

SESSION_ID="$(get_session_id)"
RUNTIME_BASE="${XDG_RUNTIME_DIR:-/tmp}/nexui"
mkdir -p "$RUNTIME_BASE" 2>/dev/null || RUNTIME_BASE="/tmp"

# Session-scoped lock, PID, and log files
LOCK_FILE="${RUNTIME_BASE}/supervisor-${SESSION_ID}.lock"
SUPERVISOR_PID_FILE="${RUNTIME_BASE}/supervisor-${SESSION_ID}.pid"
PID_FILE="${RUNTIME_BASE}/shell-${SESSION_ID}.pid"
LOG_FILE="/tmp/nexui-shell-${SESSION_ID}.log"

# Backward compatibility paths for legacy session
LEGACY_PID_FILE="/tmp/nexos-shell.pid"
LEGACY_SUPERVISOR_PID_FILE="/tmp/nexos-shell-supervisor.pid"
LEGACY_LOG_FILE="/tmp/nexos-shell.log"
LEGACY_LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/nexos-shell-supervisor.lock"

# Session-aware supervisor PID resolution
is_inir_service_active() {
    command -v systemctl >/dev/null 2>&1 && (systemctl --user is-active --quiet nexui.service 2>/dev/null || systemctl --user is-active --quiet inir.service 2>/dev/null)
}

get_active_service_name() {
    if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet nexui.service 2>/dev/null; then
        echo "nexui.service"
    else
        echo "inir.service"
    fi
}

get_inir_service_pid() {
    local pid
    pid="$(systemctl --user show -p MainPID --value nexui.service 2>/dev/null || true)"
    if [[ -z "$pid" || "$pid" == "0" ]]; then
        pid="$(systemctl --user show -p MainPID --value inir.service 2>/dev/null || true)"
    fi
    echo "$pid"
}

get_active_supervisor_pid() {
    # 0. Check systemd user service
    if is_inir_service_active; then
        local svc
        svc="$(get_active_service_name)"
        echo "systemd($svc)"
        return 0
    fi

    # 1. Check session-specific PID file
    if [[ -f "$SUPERVISOR_PID_FILE" ]]; then
        local spid
        spid="$(cat "$SUPERVISOR_PID_FILE" 2>/dev/null || true)"
        if [[ -n "$spid" ]] && kill -0 "$spid" 2>/dev/null; then
            echo "$spid"
            return 0
        fi
    fi

    # 2. Check legacy PID file (if matching current Wayland display or Hyprland session)
    if [[ -f "$LEGACY_SUPERVISOR_PID_FILE" ]]; then
        local lpid
        lpid="$(cat "$LEGACY_SUPERVISOR_PID_FILE" 2>/dev/null || true)"
        if [[ -n "$lpid" ]] && kill -0 "$lpid" 2>/dev/null; then
            local p_disp
            p_disp=$(grep -z '^WAYLAND_DISPLAY=' "/proc/$lpid/environ" 2>/dev/null | tr -d '\0' | cut -d= -f2 || true)
            if [[ "$p_disp" == "${WAYLAND_DISPLAY:-wayland-1}" ]] || { [[ -z "$p_disp" ]] && [[ "$SESSION_ID" =~ hyprland ]]; }; then
                echo "$lpid"
                return 0
            fi
        fi
    fi

    # 3. Fallback when called from non-Wayland shell/TTY (return any active supervisor)
    if [[ "$SESSION_ID" == "generic-default" ]]; then
        for pf in "$RUNTIME_BASE"/supervisor-*.pid; do
            if [[ -f "$pf" ]]; then
                local spid
                spid="$(cat "$pf" 2>/dev/null || true)"
                if [[ -n "$spid" ]] && kill -0 "$spid" 2>/dev/null; then
                    echo "$spid"
                    return 0
                fi
            fi
        done
    fi

    return 1
}

# Session-aware shell PID resolution
get_active_shell_pid() {
    # 0. Check systemd user service
    if is_inir_service_active; then
        local spid
        spid="$(get_inir_service_pid)"
        if [[ -n "$spid" && "$spid" != "0" ]] && kill -0 "$spid" 2>/dev/null; then
            echo "$spid"
            return 0
        fi
    fi

    # 1. Check session-specific PID file
    if [[ -f "$PID_FILE" ]]; then
        local shpid
        shpid="$(cat "$PID_FILE" 2>/dev/null || true)"
        if [[ -n "$shpid" ]] && kill -0 "$shpid" 2>/dev/null; then
            echo "$shpid"
            return 0
        fi
    fi

    # 2. Check legacy PID file
    if [[ -f "$LEGACY_PID_FILE" ]]; then
        local lshpid
        lshpid="$(cat "$LEGACY_PID_FILE" 2>/dev/null || true)"
        if [[ -n "$lshpid" ]] && kill -0 "$lshpid" 2>/dev/null; then
            local p_disp
            p_disp=$(grep -z '^WAYLAND_DISPLAY=' "/proc/$lshpid/environ" 2>/dev/null | tr -d '\0' | cut -d= -f2 || true)
            if [[ "$p_disp" == "${WAYLAND_DISPLAY:-wayland-1}" ]] || { [[ -z "$p_disp" ]] && [[ "$SESSION_ID" =~ hyprland ]]; }; then
                echo "$lshpid"
                return 0
            fi
        fi
    fi

    # 3. Fallback when called from non-Wayland shell/TTY
    if [[ "$SESSION_ID" == "generic-default" ]]; then
        for pf in "$RUNTIME_BASE"/shell-*.pid; do
            if [[ -f "$pf" ]]; then
                local shpid
                shpid="$(cat "$pf" 2>/dev/null || true)"
                if [[ -n "$shpid" ]] && kill -0 "$shpid" 2>/dev/null; then
                    echo "$shpid"
                    return 0
                fi
            fi
        done
    fi

    return 1
}

usage() {
    echo "Usage: $0 [run|start|stop|restart|status|logs|check|settings]"
    echo "  run|start      Launch supervised NexUI shell in background"
    echo "  stop           Safely stop the running NexUI supervisor and shell"
    echo "  restart        Cleanly restart the running NexUI shell instance"
    echo "  status         Check status of the running supervisor and shell"
    echo "  logs [-n N]    Inspect recent runtime log output"
    echo "  check          Validate QML files and environment configuration"
    echo "  settings       Launch settings & theme customizer in standalone window"
    exit 1
}

MODE="${1:-status}"
shift || true

# Safety guard: Ensure host sea-shell is never touched
assert_not_seashell() {
    local target_pid="$1"
    if [[ "$target_pid" == "2211" ]]; then
        echo "ERROR: Protected process ID 2211 (sea-shell) detected! Refusing action." >&2
        exit 1
    fi
}

case "$MODE" in
    check)
        echo "=== [NexUI] Checking QML files and configuration ==="
        echo "Checking root entry points..."
        test -f "$SCRIPT_DIR/shell.qml" && echo "  ✓ shell.qml"
        test -f "$SCRIPT_DIR/GlobalStates.qml" && echo "  ✓ GlobalStates.qml"
        test -f "$SCRIPT_DIR/ShellIrisPanels.qml" && echo "  ✓ ShellIrisPanels.qml"
        test -f "$SCRIPT_DIR/defaults/config.json" && echo "  ✓ defaults/config.json"
        test -f "$SCRIPT_DIR/assets/fonts/MaterialSymbolsRounded.ttf" && echo "  ✓ assets/fonts/MaterialSymbolsRounded.ttf"
        test -f "$SCRIPT_DIR/version.json" && echo "  ✓ version.json"

        echo "Checking panelFamily in defaults/config.json:"
        grep -n '"panelFamily"' "$SCRIPT_DIR/defaults/config.json" || true

        echo "✓ All core modules and assets accounted for."
        ;;

    _supervisor)
        # Internal daemon supervisor loop
        exec 9>"$LOCK_FILE"
        flock -n 9 || {
            echo "Supervisor lock already held for session $SESSION_ID. Exiting duplicate supervisor." >> "$LOG_FILE"
            exit 0
        }

        echo $$ > "$SUPERVISOR_PID_FILE"
        if [[ "$SESSION_ID" =~ hyprland ]]; then
            echo $$ > "$LEGACY_SUPERVISOR_PID_FILE" 2>/dev/null || true
        fi

        child=""
        cleanup() {
            trap - TERM INT HUP EXIT
            if [[ -n "$child" ]] && kill -0 "$child" 2>/dev/null; then
                kill -TERM "$child" 2>/dev/null || true
                sleep 0.5
                kill -9 "$child" 2>/dev/null || true
            fi
            rm -f "$PID_FILE" "$SUPERVISOR_PID_FILE"
            if [[ "$SESSION_ID" =~ hyprland ]]; then
                rm -f "$LEGACY_PID_FILE" "$LEGACY_SUPERVISOR_PID_FILE" 2>/dev/null || true
            fi
            exit 0
        }
        trap cleanup TERM INT HUP EXIT

        # Apply environment
        export QT_QUICK_CONTROLS_STYLE=Basic
        export QT_SCALE_FACTOR=1
        export QT_SCALE_FACTOR_ROUNDING_POLICY=RoundPreferFloor
        export QT_LOGGING_RULES="quickshell.dbus.properties=false;qt.qml.settings.warning=false;qt.core.qsettings.warning=false;kf.xmlgui=false;kf.coreaddons=false;kf.config.core=false;kf.iconthemes=false;qt.qpa.wayland.textinput.warning=false"
        export INIR_RUNTIME_DIR="$SCRIPT_DIR"
        export INIR_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/inir"
        export PATH="$HOME/.local/bin:$PATH"

        fails=0
        while :; do
            start_time=$(date +%s)
            quickshell -p "$SCRIPT_DIR" >> "$LOG_FILE" 2>&1 &
            child=$!
            echo "$child" > "$PID_FILE"
            if [[ "$SESSION_ID" =~ hyprland ]]; then
                echo "$child" > "$LEGACY_PID_FILE" 2>/dev/null || true
            fi
            wait "$child" || true
            rc=$?
            child=""
            end_time=$(date +%s)
            run_duration=$((end_time - start_time))

            echo "$(date '+%F %T') [Supervisor-$SESSION_ID] quickshell exited with code $rc after ${run_duration}s" >> "$LOG_FILE"

            # Check if stopped by external signal or flag
            if [[ ! -f "$SUPERVISOR_PID_FILE" ]] && [[ ! -f "$LEGACY_SUPERVISOR_PID_FILE" ]]; then
                break
            fi

            if (( run_duration >= 10 )); then
                fails=0
                sleep 1
            else
                fails=$((fails + 1))
                if (( fails >= 5 )); then
                    echo "$(date '+%F %T') [Supervisor-$SESSION_ID] ERROR: Shell failed repeatedly (5 attempts in <10s each). Halting supervisor." >> "$LOG_FILE"
                    command -v notify-send >/dev/null 2>&1 && notify-send -u critical "NexUI Shell" "Shell failed repeatedly at startup in session [$SESSION_ID]. Supervisor stopped. See $LOG_FILE"
                    rm -f "$PID_FILE" "$SUPERVISOR_PID_FILE"
                    if [[ "$SESSION_ID" =~ hyprland ]]; then
                        rm -f "$LEGACY_PID_FILE" "$LEGACY_SUPERVISOR_PID_FILE" 2>/dev/null || true
                    fi
                    exit 1
                fi
                sleep 2
            fi
        done
        rm -f "$PID_FILE" "$SUPERVISOR_PID_FILE"
        if [[ "$SESSION_ID" =~ hyprland ]]; then
            rm -f "$LEGACY_PID_FILE" "$LEGACY_SUPERVISOR_PID_FILE" 2>/dev/null || true
        fi
        exit 0
        ;;

    run|start)
        echo "=== [NexUI] Launching authoritative NexUI shell supervisor [$SESSION_ID] ==="
        # Idempotency check: is systemd user service already running the shell?
        if is_inir_service_active; then
            inir_pid="$(get_inir_service_pid)"
            svc="$(get_active_service_name)"
            echo "NexUI shell is already running via systemd $svc (Main PID: ${inir_pid:-unknown})."
            exit 0
        fi

        # Idempotency check: is supervisor already running for this session?
        SUP_PID="$(get_active_supervisor_pid || true)"
        if [[ -n "$SUP_PID" ]]; then
            SHELL_PID="$(get_active_shell_pid || echo "unknown")"
            echo "NexUI shell supervisor is already running for session [$SESSION_ID] (Supervisor PID: $SUP_PID, Shell PID: $SHELL_PID)."
            exit 0
        fi

        # Also check if a standalone shell instance is already running for this session
        SHELL_PID="$(get_active_shell_pid || true)"
        if [[ -n "$SHELL_PID" ]]; then
            echo "NexUI shell is already running for session [$SESSION_ID] (PID: $SHELL_PID)."
            exit 0
        fi

        # Launch supervisor daemon in background detached from controlling terminal
        setsid "$0" _supervisor >> "$LOG_FILE" 2>&1 &
        sleep 1.2

        SUP_PID="$(get_active_supervisor_pid || true)"
        if [[ -n "$SUP_PID" ]]; then
            SHELL_PID="$(get_active_shell_pid || echo "pending")"
            echo "✓ NexUI shell supervisor active for session [$SESSION_ID] (Supervisor PID: $SUP_PID, Shell PID: $SHELL_PID)"
            echo "Logs: $LOG_FILE"
            exit 0
        else
            echo "⚠ Supervisor failed to start or exited immediately. Log output:"
            tail -n 25 "$LOG_FILE" 2>/dev/null || true
            exit 1
        fi
        ;;

    stop)
        echo "=== [NexUI] Stopping shell supervisor and instances for session [$SESSION_ID] ==="
        stopped=false

        if is_inir_service_active; then
            svc="$(get_active_service_name)"
            echo "Stopping systemd $svc..."
            systemctl --user stop "$svc" 2>/dev/null || true
            stopped=true
        fi

        # Stop supervisor first so it does not auto-restart child
        SUP_PID="$(get_active_supervisor_pid || true)"
        if [[ -n "$SUP_PID" && "$SUP_PID" != systemd* ]]; then
            assert_not_seashell "$SUP_PID"
            echo "Stopping supervisor (PID: $SUP_PID)..."
            kill -TERM "$SUP_PID" 2>/dev/null || true
            sleep 0.5
            kill -9 "$SUP_PID" 2>/dev/null || true
            stopped=true
        fi
        rm -f "$SUPERVISOR_PID_FILE"
        if [[ "$SESSION_ID" =~ hyprland ]]; then
            rm -f "$LEGACY_SUPERVISOR_PID_FILE" 2>/dev/null || true
        fi

        # Stop child shell process for this session
        SHELL_PID="$(get_active_shell_pid || true)"
        if [[ -n "$SHELL_PID" ]]; then
            if ! is_inir_service_active; then
                assert_not_seashell "$SHELL_PID"
                echo "Stopping shell process (PID: $SHELL_PID)..."
                kill -TERM "$SHELL_PID" 2>/dev/null || true
                sleep 0.5
                kill -9 "$SHELL_PID" 2>/dev/null || true
                stopped=true
            fi
        fi
        rm -f "$PID_FILE"
        if [[ "$SESSION_ID" =~ hyprland ]]; then
            rm -f "$LEGACY_PID_FILE" 2>/dev/null || true
        fi

        # Clean detached quickshell processes ONLY for THIS Wayland display session
        PIDS=$(pgrep -f "^([^ ]*/)?quickshell[[:space:]]+.*$SCRIPT_DIR" || true)
        for p in $PIDS; do
            assert_not_seashell "$p"
            p_disp=$(grep -z '^WAYLAND_DISPLAY=' "/proc/$p/environ" 2>/dev/null | tr -d '\0' | cut -d= -f2 || true)
            if [[ -n "${WAYLAND_DISPLAY:-}" ]] && [[ -n "$p_disp" ]] && [[ "$p_disp" != "$WAYLAND_DISPLAY" ]]; then
                # Belongs to a different Wayland session, protect it!
                continue
            fi
            echo "Cleaning detached PID $p..."
            kill "$p" 2>/dev/null || true
        done

        rm -f "$LOCK_FILE"
        if [[ "$SESSION_ID" =~ hyprland ]]; then
            rm -f "$LEGACY_LOCK_FILE" 2>/dev/null || true
        fi
        echo "✓ NexUI shell stopped for session [$SESSION_ID]."
        ;;

    restart)
        echo "=== [NexUI] Restarting shell for session [$SESSION_ID] ==="
        if is_inir_service_active; then
            # Clean up any leftover manual supervisor if one was running
            old_sup="$(cat "$SUPERVISOR_PID_FILE" 2>/dev/null || true)"
            if [[ -n "$old_sup" ]] && kill -0 "$old_sup" 2>/dev/null; then
                kill -TERM "$old_sup" 2>/dev/null || true
            fi
            rm -f "$PID_FILE" "$SUPERVISOR_PID_FILE" "$LOCK_FILE"
            svc="$(get_active_service_name)"
            systemctl --user restart "$svc"
            echo "✓ $svc restarted."
            exit 0
        fi
        "$0" stop
        sleep 0.8
        "$0" run
        ;;

    status)
        echo "=== [NexUI] Status Check [$SESSION_ID] ==="
        if is_inir_service_active; then
            inir_pid="$(get_inir_service_pid)"
            svc="$(get_active_service_name)"
            echo "NexUI shell is RUNNING (Supervisor: systemd $svc, Shell PID: ${inir_pid:-unknown})"
            echo "Session: $SESSION_ID"
            exit 0
        fi
        sup_pid="$(get_active_supervisor_pid || true)"
        shell_pid="$(get_active_shell_pid || true)"

        if [[ -n "$sup_pid" ]] && [[ -n "$shell_pid" ]]; then
            echo "NexUI shell is RUNNING (Supervisor PID: $sup_pid, Shell PID: $shell_pid)"
            echo "Session: $SESSION_ID"
            echo "Log file: $([[ -f "$LOG_FILE" ]] && echo "$LOG_FILE" || echo "$LEGACY_LOG_FILE")"
            exit 0
        elif [[ -n "$shell_pid" ]]; then
            echo "NexUI shell is RUNNING without supervisor (Shell PID: $shell_pid)"
            echo "Session: $SESSION_ID"
            echo "Log file: $([[ -f "$LOG_FILE" ]] && echo "$LOG_FILE" || echo "$LEGACY_LOG_FILE")"
            exit 0
        else
            echo "NexUI shell is NOT running for session [$SESSION_ID]."
            exit 1
        fi
        ;;

    logs)
        if is_inir_service_active && command -v journalctl >/dev/null 2>&1 && [[ ! -f "$LOG_FILE" || ! -s "$LOG_FILE" ]]; then
            svc="$(get_active_service_name)"
            journalctl --user-unit "$svc" "${@:--n 30}" --no-pager
        else
            target_log="$LOG_FILE"
            if [[ ! -f "$target_log" ]] && [[ -f "$LEGACY_LOG_FILE" ]]; then
                target_log="$LEGACY_LOG_FILE"
            fi
            tail "${@:--n 30}" "$target_log" 2>/dev/null || echo "No log file found at $target_log"
        fi
        ;;

    settings)
        echo "=== [NexUI] Launching Settings / Appearance Customizer ==="
        export INIR_STANDALONE_WINDOW=1
        export QT_QUICK_CONTROLS_STYLE=Basic
        quickshell -p "$SCRIPT_DIR/settings.qml"
        ;;

    *)
        usage
        ;;
esac
