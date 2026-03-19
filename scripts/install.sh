#!/usr/bin/env bash
set -euo pipefail

MIHOMO_VERSION="v1.19.21"
INSTALL_DIR="$HOME/.local/bin"
MIHOMO_BIN="$INSTALL_DIR/mihomo"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BIN_DIR="$PROJECT_DIR/bin"

log_info()  { echo "[INFO] $*"; }
log_ok()    { echo "[OK] $*"; }
log_err()   { echo "[ERROR] $*" >&2; }

if [[ -x "$MIHOMO_BIN" ]]; then
    log_ok "mihomo is already installed: $($MIHOMO_BIN -v 2>&1 | head -1)"
    exit 0
fi

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  MIHOMO_ARCH="amd64" ;;
    aarch64) MIHOMO_ARCH="arm64" ;;
    armv7l)  MIHOMO_ARCH="armv7" ;;
    *)
        log_err "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

log_info "Detected architecture: $ARCH -> $MIHOMO_ARCH"
mkdir -p "$INSTALL_DIR"

LOCAL_GZ="$BIN_DIR/mihomo-linux-${MIHOMO_ARCH}.gz"
if [[ -f "$LOCAL_GZ" ]]; then
    log_info "Found pre-packaged binary: $LOCAL_GZ"
    TMP_FILE="/tmp/mihomo-$$.gz"
    trap 'rm -f "$TMP_FILE" "/tmp/mihomo-$$"' EXIT
    cp "$LOCAL_GZ" "$TMP_FILE"
    gunzip -f "$TMP_FILE"
    mv "/tmp/mihomo-$$" "$MIHOMO_BIN"
    chmod +x "$MIHOMO_BIN"
    log_ok "mihomo installed from local binary at $MIHOMO_BIN"
    log_info "Version: $($MIHOMO_BIN -v 2>&1 | head -1)"
    exit 0
fi

log_info "No local binary found, downloading from internet..."

FILENAME="mihomo-linux-${MIHOMO_ARCH}-${MIHOMO_VERSION}.gz"
GITHUB_URL="https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VERSION}/${FILENAME}"
MIRROR_URL="https://mirror.ghproxy.com/${GITHUB_URL}"

download_file() {
    local url="$1"
    local output="$2"
    log_info "Downloading from: $url"
    if curl -fSL --connect-timeout 15 --max-time 120 -o "$output" "$url"; then
        return 0
    fi
    return 1
}

TMP_FILE="/tmp/mihomo-$$.gz"
trap 'rm -f "$TMP_FILE" "/tmp/mihomo-$$"' EXIT

if ! download_file "$GITHUB_URL" "$TMP_FILE"; then
    log_info "GitHub download failed, trying mirror..."
    if ! download_file "$MIRROR_URL" "$TMP_FILE"; then
        log_err "All download sources failed. See skills/06-troubleshoot.md for manual installation."
        exit 1
    fi
fi

log_info "Extracting..."
gunzip -f "$TMP_FILE"
mv "/tmp/mihomo-$$" "$MIHOMO_BIN"
chmod +x "$MIHOMO_BIN"

log_ok "mihomo installed successfully at $MIHOMO_BIN"
log_info "Version: $($MIHOMO_BIN -v 2>&1 | head -1)"
