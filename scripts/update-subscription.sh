#!/usr/bin/env bash
set -euo pipefail

API="http://127.0.0.1:9090"
PROVIDER_NAME="subscription"

log_info() { echo "[INFO] $*"; }
log_ok()   { echo "[OK] $*"; }
log_err()  { echo "[ERROR] $*" >&2; }

log_info "Forcing subscription update..."

RESPONSE=$(curl -s --noproxy '*' -w "\n%{http_code}" \
    -X PUT "$API/providers/proxies/$PROVIDER_NAME" 2>/dev/null || echo -e "\n000")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)

if [[ "$HTTP_CODE" == "204" || "$HTTP_CODE" == "200" ]]; then
    log_ok "Subscription updated successfully"

    sleep 3
    NODE_DATA=$(curl -s --noproxy '*' "$API/proxies/PROXY" 2>/dev/null || echo "")
    if [[ -n "$NODE_DATA" ]]; then
        NODE_COUNT=$(echo "$NODE_DATA" | grep -o '"all":\[[^]]*\]' | tr ',' '\n' | wc -l)
        CURRENT=$(echo "$NODE_DATA" | grep -o '"now":"[^"]*"' | head -1 | cut -d'"' -f4)
        log_ok "Available nodes: $NODE_COUNT, current: $CURRENT"
    fi
else
    log_err "Failed to update subscription (HTTP $HTTP_CODE)"
    log_err "Is mihomo running? Try: bash scripts/start.sh"
    exit 1
fi
