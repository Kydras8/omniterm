#!/usr/bin/env bash
set -euo pipefail
TAG="${1:-local}"
mkdir -p dist
ZIP="dist/omniterm-${TAG}.zip"
zip -r "$ZIP" \
  kyboost bin .zshrc.kydras .tmux.conf.kydras assets \
  thunar-open-omni.action kydras-omninterm.desktop \
  README.md LICENSE 2>/dev/null || true
echo "Built $ZIP"
