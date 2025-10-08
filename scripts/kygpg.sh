#!/usr/bin/env bash
set -euo pipefail

# kygpg.sh — Idempotent GPG setup for OmniTerm releases
# Usage:
#   ./scripts/kygpg.sh                       # create if missing, export keys, upload secret to GH
#   ./scripts/kygpg.sh --recreate            # delete any existing key and recreate
#   ./scripts/kygpg.sh --no-secret-upload    # skip GitHub secret
#   ./scripts/kygpg.sh --name "Name" --email "me@example.com"

NAME="Kydras OmniTerm Release"
EMAIL="security@kydras-systems-inc.com"
RECREATE=0
UPLOAD=1

while [ $# -gt 0 ]; do
  case "$1" in
    --recreate) RECREATE=1 ;;
    --no-secret-upload) UPLOAD=0 ;;
    --name) NAME="$2"; shift ;;
    --email) EMAIL="$2"; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
  shift
done

set +e; command -v haveged >/dev/null 2>&1; HG=$?; set -e
if [ $HG -ne 0 ]; then
  echo "[kygpg] Installing haveged for entropy (sudo may prompt)..."
  sudo apt-get update -y && sudo apt-get install -y haveged
  sudo systemctl enable haveged || true
  sudo systemctl start haveged || true
fi

KEYID=$(gpg --list-keys --keyid-format=long "$NAME" 2>/dev/null | awk "/^pub/{print \$2}" | sed "s|.*/||" | head -n1)
if [ "$RECREATE" -eq 1 ] && [ -n "${KEYID:-}" ]; then
  echo "[kygpg] Deleting existing key: $KEYID"
  gpg --batch --yes --delete-secret-and-public-key "$KEYID" || true
  KEYID=""
fi

if [ -z "${KEYID:-}" ]; then
  echo "[kygpg] Generating ed25519 signing key (no passphrase, 2y)..."
  gpg --batch --passphrase "" --quick-gen-key "$NAME <$EMAIL>" ed25519 sign 2y
  KEYID=$(gpg --list-keys --keyid-format=long "$NAME" | awk "/^pub/{print \$2}" | sed "s|.*/||" | head -n1)
fi

echo "[kygpg] Active key:"
gpg --list-keys --keyid-format=long "$NAME" || true

echo "[kygpg] Exporting public key -> GPG-KEY-KYDRAS.txt"
gpg --export --armor "$NAME" > GPG-KEY-KYDRAS.txt
echo "[kygpg] Exporting private key -> private-gpg.asc"
gpg --export-secret-keys --armor "$NAME" > private-gpg.asc

if [ "$UPLOAD" -eq 1 ]; then
  if command -v gh >/dev/null 2>&1; then
    echo "[kygpg] Uploading private key to GitHub secret GPG_PRIVATE_KEY..."
    gh auth status || gh auth login -s repo -w
    gh secret set GPG_PRIVATE_KEY < private-gpg.asc
  else
    echo "[kygpg] gh not installed; skipping secret upload."
  fi
fi

# quick self-test: sign & verify a blob
echo "kydras test $(date -u +%FT%TZ)" > .gpg-test.txt
gpg --yes --batch --local-user "$NAME" --clearsign .gpg-test.txt >/dev/null
gpg --verify .gpg-test.txt.asc >/dev/null && echo "[kygpg] Sign/verify OK"
rm -f .gpg-test.txt .gpg-test.txt.asc

echo "[kygpg] Done. Commit public key and (optionally) delete local private key if only CI should sign."
