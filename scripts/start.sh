#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_DIR/config"
MIHOMO_BIN="$HOME/.local/bin/mihomo"
PID_FILE="$PROJECT_DIR/.mihomo.pid"
LOG_FILE="$CONFIG_DIR/logs/mihomo.log"

log_info()  { echo "[INFO] $*"; }
log_ok()    { echo "[OK] $*"; }
log_err()   { echo "[ERROR] $*" >&2; }

if [[ ! -x "$MIHOMO_BIN" ]]; then
    log_err "mihomo not found. Run 'bash scripts/install.sh' first."
    exit 1
fi

if [[ ! -f "$CONFIG_DIR/config.yaml" ]]; then
    log_err "config.yaml not found. Run 'bash scripts/configure.sh' first."
    exit 1
fi

if [[ -f "$PID_FILE" ]]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        log_info "mihomo is already running (PID: $OLD_PID). Stopping it first..."
        kill "$OLD_PID" 2>/dev/null || true
        sleep 1
    fi
    rm -f "$PID_FILE"
fi

mkdir -p "$CONFIG_DIR/logs"

nohup "$MIHOMO_BIN" -d "$CONFIG_DIR" > "$LOG_FILE" 2>&1 &
NEW_PID=$!
echo "$NEW_PID" > "$PID_FILE"

sleep 2

if kill -0 "$NEW_PID" 2>/dev/null; then
    log_ok "mihomo started (PID: $NEW_PID)"
    log_info "Log file: $LOG_FILE"
else
    log_err "mihomo exited unexpectedly. Check log:"
    tail -20 "$LOG_FILE" 2>/dev/null || true
    exit 1
fi
