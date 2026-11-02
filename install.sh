#!/usr/bin/env bash
# Usage: ./install.sh [--nopasswd]      install vpn (+ optional passwordless sudo)
#        ./install.sh --uninstall       remove vpn and the sudoers rule
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"
BIN_DIR="$HOME/.local/bin"
SUDOERS=/etc/sudoers.d/sing-box

install_nopasswd() {
    local tmp
    tmp=$(mktemp)
    sed "s/%USER%/$USER/" sudoers/sing-box > "$tmp"
    sudo visudo -cf "$tmp" >/dev/null
    sudo install -m 440 -o root -g root "$tmp" "$SUDOERS"
    rm -f "$tmp"
    echo "installed $SUDOERS (no password for start/stop/restart sing-box)"
}

case "${1:-}" in
    --uninstall)
        rm -f "$BIN_DIR/vpn"
        [[ -e $SUDOERS ]] && sudo rm -f "$SUDOERS"
        echo "uninstalled"
        exit 0 ;;
esac

mkdir -p "$BIN_DIR"
chmod +x bin/vpn
ln -sfn "$PWD/bin/vpn" "$BIN_DIR/vpn"
echo "linked $BIN_DIR/vpn -> $PWD/bin/vpn"

case ":$PATH:" in *":$BIN_DIR:"*) ;; *) echo "warning: $BIN_DIR is not in your PATH" ;; esac

[[ ${1:-} == --nopasswd ]] && install_nopasswd
echo "done, try: vpn help"
