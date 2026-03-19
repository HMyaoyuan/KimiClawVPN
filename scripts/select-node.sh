#!/usr/bin/env bash
set -euo pipefail

API="http://127.0.0.1:9090"
GROUP_NAME="PROXY"

log_ok()   { echo "[OK] $*"; }
log_err()  { echo "[ERROR] $*" >&2; }
log_info() { echo "[INFO] $*"; }

show_usage() {
    echo "Usage:"
    echo "  bash scripts/select-node.sh list          - List all available nodes"
    echo "  bash scripts/select-node.sh select <name> - Select a specific node"
    echo "  bash scripts/select-node.sh current       - Show current node"
}

list_nodes() {
    local DATA
    DATA=$(curl -s "$API/proxies/$GROUP_NAME" 2>/dev/null || echo "")
    if [[ -z "$DATA" ]]; then
        log_err "Cannot connect to mihomo API. Is mihomo running?"
        exit 1
    fi

    local CURRENT
    CURRENT=$(echo "$DATA" | grep -o '"now":"[^"]*"' | head -1 | cut -d'"' -f4)
    log_info "Current node: $CURRENT"
    echo ""
    echo "Available nodes:"
    echo "---"

    echo "$DATA" | grep -o '"all":\[[^]]*\]' | tr ',' '\n' | grep -o '"[^"]*"' | tr -d '"' | while read -r NODE; do
        if [[ "$NODE" == "$CURRENT" ]]; then
            echo "  * $NODE  (active)"
        else
            echo "    $NODE"
        fi
    done
    echo "---"
}

select_node() {
    local NODE_NAME="$1"
    local RESPONSE
    RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$API/proxies/$GROUP_NAME" \
        -H "Content-Type: application/json" \
        -d "{\"name\": \"$NODE_NAME\"}" 2>/dev/null || echo -e "\n000")

    local HTTP_CODE
    HTTP_CODE=$(echo "$RESPONSE" | tail -1)

    if [[ "$HTTP_CODE" == "204" || "$HTTP_CODE" == "200" ]]; then
        log_ok "Switched to node: $NODE_NAME"
    else
        log_err "Failed to switch node (HTTP $HTTP_CODE). Check if the node name is correct."
        log_info "Run 'bash scripts/select-node.sh list' to see available nodes."
        exit 1
    fi
}

show_current() {
    local DATA
    DATA=$(curl -s "$API/proxies/$GROUP_NAME" 2>/dev/null || echo "")
    if [[ -z "$DATA" ]]; then
        log_err "Cannot connect to mihomo API. Is mihomo running?"
        exit 1
    fi
    local CURRENT
    CURRENT=$(echo "$DATA" | grep -o '"now":"[^"]*"' | head -1 | cut -d'"' -f4)
    log_ok "Current node: $CURRENT"
}

if [[ $# -lt 1 ]]; then
    show_usage
    exit 1
fi

case "$1" in
    list)
        list_nodes
        ;;
    select)
        if [[ $# -lt 2 ]]; then
            log_err "Please specify a node name"
            show_usage
            exit 1
        fi
        select_node "$2"
        ;;
    current)
        show_current
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
