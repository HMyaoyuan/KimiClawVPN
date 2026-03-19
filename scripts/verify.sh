#!/usr/bin/env bash
set -euo pipefail

log_test() { echo "[TEST] $*"; }
log_ok()   { echo "[OK] $*"; }
log_fail() { echo "[FAIL] $*"; }

PROXY="http://127.0.0.1:7890"
PASSED=true

log_test "Testing proxy connection..."

log_test "Checking if proxy port is listening..."
if command -v ss &>/dev/null; then
    if ss -tlnp 2>/dev/null | grep -q ":7890"; then
        log_ok "Port 7890 is listening"
    else
        log_fail "Port 7890 is not listening. Is mihomo running?"
        log_fail "Run: bash scripts/start.sh"
        exit 1
    fi
elif command -v netstat &>/dev/null; then
    if netstat -tlnp 2>/dev/null | grep -q ":7890"; then
        log_ok "Port 7890 is listening"
    else
        log_fail "Port 7890 is not listening. Is mihomo running?"
        exit 1
    fi
fi

log_test "Testing Google connectivity..."
if curl -sx "$PROXY" --connect-timeout 10 --max-time 15 "https://www.google.com" -o /dev/null 2>/dev/null; then
    log_ok "Google connectivity: OK"
else
    log_fail "Cannot reach Google via proxy"
    PASSED=false
fi

log_test "Checking exit IP..."
IP_INFO=$(curl -sx "$PROXY" --connect-timeout 10 --max-time 15 "https://ipinfo.io/json" 2>/dev/null || echo "")
if [[ -n "$IP_INFO" ]]; then
    IP=$(echo "$IP_INFO" | grep -o '"ip": *"[^"]*"' | head -1 | grep -o '"[^"]*"$' | tr -d '"')
    COUNTRY=$(echo "$IP_INFO" | grep -o '"country": *"[^"]*"' | head -1 | grep -o '"[^"]*"$' | tr -d '"')
    log_ok "Current IP: $IP ($COUNTRY)"
else
    log_fail "Cannot retrieve IP info"
    PASSED=false
fi

echo ""
if [[ "$PASSED" == true ]]; then
    log_ok "Proxy is working correctly!"
else
    log_fail "Some tests failed. See skills/06-troubleshoot.md for help."
    exit 1
fi
