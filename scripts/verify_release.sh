#!/usr/bin/env bash
set -euo pipefail

TAG="${1:?Usage: verify_release.sh vX.Y.Z}"
REPO="Kydras8/omniterm"
WORK="/tmp/omniterm-verify-${TAG}"
mkdir -p "$WORK"

echo "[verify] Tag: $TAG  Workdir: $WORK"

have(){ command -v "$1" >/dev/null 2>&1; }
need(){ have "$1" || { echo "[verify] Missing $1 — please install it"; exit 2; }; }

need gh; need curl; need gpg
if ! have jq; then
  echo "[verify] Installing jq (sudo may prompt)..."
  sudo apt-get update -y && sudo apt-get install -y jq
fi

echo "[verify] Fetching asset list from GitHub…"
ASSETS_JSON="$(gh release view "$TAG" --repo "$REPO" --json assets)"
DEB_URL="$(echo "$ASSETS_JSON" | jq -r '.assets[] | select(.name|endswith(".deb")) | .url' | head -n1)"
SUM_URL="$(echo "$ASSETS_JSON" | jq -r '.assets[] | select(.name=="SHA256SUMS.txt") | .url' | head -n1)"
SIG_URL="$(echo "$ASSETS_JSON" | jq -r '.assets[] | select(.name=="SHA256SUMS.txt.minisig") | .url' | head -n1)"

echo "[verify] Downloading assets…"
[ -n "${DEB_URL:-}" ] && curl -fsSL -o "$WORK/pkg.deb" "$DEB_URL"
[ -n "${SUM_URL:-}" ] && curl -fsSL -o "$WORK/SHA256SUMS.txt" "$SUM_URL" || true
[ -n "${SIG_URL:-}" ] && curl -fsSL -o "$WORK/SHA256SUMS.txt.minisig" "$SIG_URL" || true
ls -lh "$WORK"

# Import GPG pubkey from repo (or fetch)
if [ -f GPG-KEY-KYDRAS.txt ]; then
  gpg --import GPG-KEY-KYDRAS.txt >/dev/null 2>&1 || true
else
  curl -fsSL -o "$WORK/GPG-KEY-KYDRAS.txt" https://raw.githubusercontent.com/Kydras8/omniterm/main/GPG-KEY-KYDRAS.txt
  gpg --import "$WORK/GPG-KEY-KYDRAS.txt" >/dev/null 2>&1 || true
fi

# Validate .deb structure
echo "[verify] Checking .deb structure…"
if ! have ar; then echo "[verify] Missing 'ar' (binutils) — install binutils"; exit 2; fi
if ! ar t "$WORK/pkg.deb" | grep -Eq '^(control\.tar(\.(gz|xz|zst))?|data\.tar(\.(gz|xz|zst))?)$'; then
  echo "[verify] ERROR: .deb missing control/data tar members"; exit 3
fi

# Try signed verification paths
if have dpkg-sig; then
  echo "[verify] dpkg-sig found — verifying signature…"
  if dpkg-sig --verify "$WORK/pkg.deb"; then
    echo "[verify] GPG OK (dpkg-sig)"
  else
    echo "[verify] WARN: dpkg-sig verification failed (likely unsigned)."
  fi
else
  echo "[verify] dpkg-sig not installed — checking for embedded _gpgorigin…"
  if ar t "$WORK/pkg.deb" | grep -q '_gpgorigin'; then
    ar x "$WORK/pkg.deb" _gpgorigin -C "$WORK"
    if gpg --status-fd=1 --verify "$WORK/_gpgorigin" >/dev/null 2>&1; then
      echo "[verify] GPG OK (_gpgorigin)"
    else
      echo "[verify] WARN: _gpgorigin present but GPG verify failed."
    fi
  else
    echo "[verify] WARN: Unsigned .deb (no _gpgorigin)."
  fi
fi

# Optional: minisign verify of checksums
if have minisign && [ -f "$WORK/SHA256SUMS.txt" ] && [ -f "$WORK/SHA256SUMS.txt.minisig" ]; then
  if [ -f MINISIGN_PUBLIC_KEY.txt ]; then PUB="$(tail -n1 MINISIGN_PUBLIC_KEY.txt || true)"; else PUB=""; fi
  if [ -n "$PUB" ]; then
    echo "[verify] Verifying SHA256SUMS.txt with minisign…"
    minisign -Vm "$WORK/SHA256SUMS.txt" -P "$PUB"
    echo "[verify] Checking file hashes…"
    (cd "$WORK" && sha256sum -c SHA256SUMS.txt)
  else
    echo "[verify] MINISIGN_PUBLIC_KEY.txt not present — skipping minisign."
  fi
else
  echo "[verify] minisign or checksum files missing — skipping checksum verification."
fi

echo "[verify] DONE."
