#!/usr/bin/env bash
# This script MUST be sourced, not executed:
#   source scripts/unset-proxy-env.sh

unset HTTP_PROXY
unset HTTPS_PROXY
unset http_proxy
unset https_proxy
unset ALL_PROXY
unset all_proxy
unset NO_PROXY
unset no_proxy

echo "[OK] Proxy environment variables cleared"
