#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p dist
find dist -type f -name '*.zip' -print0 | xargs -0 -I{} sha256sum "{}" > dist/SHA256SUMS.txt
echo "Wrote dist/SHA256SUMS.txt"
