#!/usr/bin/env bash
set -euo pipefail

# Build a simple .deb for OmniTerm.
VER="${1:-1.0.0}"
PKG="omniterm"
ARCH="$(dpkg --print-architecture 2>/dev/null || echo all)"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/DEBIAN" "$STAGE/usr/local/bin" "$STAGE/usr/share/omniterm/assets" "$STAGE/usr/share/applications" "$STAGE/usr/share/doc/$PKG"

install -m 0755 kyboost "$STAGE/usr/local/bin/kyboost"
for f in bin/*; do [ -x "$f" ] && install -m 0755 "$f" "$STAGE/usr/local/bin/$(basename "$f")"; done
install -m 0644 assets/* "$STAGE/usr/share/omniterm/assets/" 2>/dev/null || true
install -m 0644 kydras-omninterm*.desktop "$STAGE/usr/share/applications/" 2>/dev/null || true
install -m 0644 README.md LICENSE "$STAGE/usr/share/doc/$PKG/" 2>/dev/null || true

printf "%s\n" \
"Package: $PKG" \
"Version: $VER" \
"Section: utils" \
"Priority: optional" \
"Architecture: $ARCH" \
"Maintainer: Kydras Systems Inc <security@kydras-systems-inc.com>" \
"Description: Kydras OmniTerm - zsh-first tmux-enhanced terminal configuration." \
" Depends: zsh, tmux" \
> "$STAGE/DEBIAN/control"

OUT="dist/${PKG}_${VER}_${ARCH}.deb"
mkdir -p dist
dpkg-deb --build "$STAGE" "$OUT" >/dev/null
echo "Built $OUT"
