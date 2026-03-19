#!/usr/bin/env bash
# This script MUST be sourced, not executed:
#   source scripts/set-proxy-env.sh

export HTTP_PROXY="http://127.0.0.1:7890"
export HTTPS_PROXY="http://127.0.0.1:7890"
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"
export ALL_PROXY="socks5://127.0.0.1:7891"
export all_proxy="socks5://127.0.0.1:7891"
export NO_PROXY="localhost,127.0.0.1,::1"
export no_proxy="localhost,127.0.0.1,::1"

echo "[OK] Proxy environment variables set"
echo "  HTTP_PROXY=$HTTP_PROXY"
echo "  HTTPS_PROXY=$HTTPS_PROXY"
echo "  ALL_PROXY=$ALL_PROXY"
