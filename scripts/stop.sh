#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PID_FILE="$PROJECT_DIR/.mihomo.pid"

log_info()  { echo "[INFO] $*"; }
log_ok()    { echo "[OK] $*"; }
log_err()   { echo "[ERROR] $*" >&2; }

if [[ ! -f "$PID_FILE" ]]; then
    PIDS=$(pgrep -f "mihomo" 2>/dev/null || true)
    if [[ -n "$PIDS" ]]; then
        log_info "No PID file found, but mihomo process detected. Killing..."
        kill $PIDS 2>/dev/null || true
        log_ok "mihomo stopped"
    else
        log_info "mihomo is not running"
    fi
    exit 0
fi

PID=$(cat "$PID_FILE")

if kill -0 "$PID" 2>/dev/null; then
    kill "$PID"
    sleep 1
    if kill -0 "$PID" 2>/dev/null; then
        kill -9 "$PID" 2>/dev/null || true
    fi
    log_ok "mihomo stopped (PID: $PID)"
else
    log_info "mihomo process (PID: $PID) is not running"
fi

rm -f "$PID_FILE"
