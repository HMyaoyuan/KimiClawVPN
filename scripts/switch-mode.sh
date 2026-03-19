#!/usr/bin/env bash
set -euo pipefail

API="http://127.0.0.1:9090"

log_ok()   { echo "[OK] $*"; }
log_err()  { echo "[ERROR] $*" >&2; }
log_info() { echo "[INFO] $*"; }

if [[ $# -lt 1 ]]; then
    echo "Usage: bash scripts/switch-mode.sh <rule|global|direct>"
    echo ""
    echo "Modes:"
    echo "  rule   - Smart routing: Chinese sites direct, foreign sites via proxy (recommended)"
    echo "  global - All traffic goes through proxy"
    echo "  direct - All traffic goes direct (proxy disabled)"
    exit 1
fi

MODE="$1"
case "$MODE" in
    rule|global|direct) ;;
    *)
        log_err "Invalid mode: $MODE. Must be one of: rule, global, direct"
        exit 1
        ;;
esac

RESPONSE=$(curl -s -w "\n%{http_code}" -X PATCH "$API/configs" \
    -H "Content-Type: application/json" \
    -d "{\"mode\": \"$MODE\"}" 2>/dev/null || echo -e "\n000")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)

if [[ "$HTTP_CODE" == "204" || "$HTTP_CODE" == "200" ]]; then
    log_ok "Switched to $MODE mode"
else
    log_err "Failed to switch mode (HTTP $HTTP_CODE). Is mihomo running?"
    exit 1
fi
