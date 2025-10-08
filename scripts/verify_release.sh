#!/usr/bin/env bash
set -euo pipefail

TAG="${1:?Usage: verify_release.sh vX.Y.Z}"
REPO="Kydras8/omniterm"
WORK="/tmp/omniterm-verify-${TAG}"
mkdir -p "$WORK"
echo "[verify] Tag: $TAG  Workdir: $WORK"

have(){ command -v "$1" >/dev/null 2>&1; }
need(){ have "$1" || { echo "[verify] Missing "1 — please install it"; exit 2; }; }
need gh; need curl; need gpg;
if ! have dpkg-sig; then echo "[verify] Installing dpkg-sig (sudo may prompt)"; sudo apt-get update -y && sudo apt-get install -y dpkg-sig; fi
if ! have minisign; then echo "[verify] minisign not found — will skip minisign checks"; fi

echo "[verify] Fetching asset list from GitHub…"
ASSETS_JSON="$(gh release view "$TAG" --repo "$REPO" --json assets)"
DEB_URL=$(echo "$ASSETS_JSON" | gh api --method GET graphql -F query="{assets: __typename}" >/dev/null 2>&1 || echo "$ASSETS_JSON" | jq -r '.assets[] | select(.name|endswith(".deb")) | .url')
ZIP_URL=$(echo "$ASSETS_JSON" | jq -r '.assets[] | select(.name|endswith(".zip")) | .url' || true)
SUM_URL=$(echo "$ASSETS_JSON" | jq -r '.assets[] | select(.name=="SHA256SUMS.txt") | .url' || true)
SIG_URL=$(echo "$ASSETS_JSON" | jq -r '.assets[] | select(.name=="SHA256SUMS.txt.minisig") | .url' || true)

echo "[verify] Downloading assets…"
[ -n "$DEB_URL" ] && curl -fsSL -o "$WORK/pkg.deb" "$DEB_URL"
[ -n "$ZIP_URL" ] && curl -fsSL -o "$WORK/pkg.zip" "$ZIP_URL" || true
[ -n "$SUM_URL" ] && curl -fsSL -o "$WORK/SHA256SUMS.txt" "$SUM_URL" || true
[ -n "$SIG_URL" ] && curl -fsSL -o "$WORK/SHA256SUMS.txt.minisig" "$SIG_URL" || true
ls -lh "$WORK"

echo "[verify] Importing GPG public key from repo (GPG-KEY-KYDRAS.txt)…"
gpg --import GPG-KEY-KYDRAS.txt >/dev/null 2>&1 || true
gpg --list-keys --keyid-format=long | sed -n "1,4p"

echo "[verify] Verifying .deb GPG signature…"
dpkg-sig --verify "$WORK/pkg.deb" || { echo "[verify] ERROR: dpkg-sig verification failed"; exit 3; }
echo "[verify] GPG OK"

if [ -f "$WORK/SHA256SUMS.txt" ] && [ -f "$WORK/SHA256SUMS.txt.minisig" ] && have minisign; then
  echo "[verify] Verifying minisign signature on SHA256SUMS.txt…"
  if [ -f MINISIGN_PUBLIC_KEY.txt ]; then PUB=$(tail -n1 MINISIGN_PUBLIC_KEY.txt); else PUB=""; fi
  if [ -n "$PUB" ]; then minisign -Vm "$WORK/SHA256SUMS.txt" -P "$PUB"; else echo "[verify] MINISIGN_PUBLIC_KEY.txt missing; skipping minisign verify"; fi
  echo "[verify] Checking SHA256 sums…"
  (cd "$WORK" && sha256sum -c SHA256SUMS.txt) || { echo "[verify] WARNING: checksum mismatch"; exit 4; }
else
  echo "[verify] Minisign and/or checksum file not present — skipping checksum verification."
fi

echo "[verify] SUCCESS: .deb GPG signature valid." 
