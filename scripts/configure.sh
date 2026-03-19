#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_DIR/config"
TEMPLATE="$CONFIG_DIR/config-template.yaml"
OUTPUT="$CONFIG_DIR/config.yaml"
ENV_FILE="$PROJECT_DIR/.env"

log_info()  { echo "[INFO] $*"; }
log_ok()    { echo "[OK] $*"; }
log_err()   { echo "[ERROR] $*" >&2; }

if [[ ! -f "$ENV_FILE" ]]; then
    log_err ".env file not found at $ENV_FILE"
    log_err "Create it with: echo 'SUBSCRIBE_URL=your_link_here' > $ENV_FILE"
    exit 1
fi

source "$ENV_FILE"

if [[ -z "${SUBSCRIBE_URL:-}" ]]; then
    log_err "SUBSCRIBE_URL is not set in .env"
    exit 1
fi

log_info "Subscription URL loaded"

if [[ ! -f "$TEMPLATE" ]]; then
    log_err "Config template not found at $TEMPLATE"
    exit 1
fi

sed "s|SUBSCRIBE_URL_PLACEHOLDER|${SUBSCRIBE_URL}|g" "$TEMPLATE" > "$OUTPUT"

mkdir -p "$CONFIG_DIR/proxy-providers"
mkdir -p "$CONFIG_DIR/logs"

log_ok "Configuration generated at $OUTPUT"
