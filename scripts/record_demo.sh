#!/usr/bin/env bash
set -euo pipefail

# OmniTerm demo recorder
CAST="assets/demo.cast"
GIF="assets/demo.gif"
mkdir -p assets
have(){ command -v "$1" >/dev/null 2>&1; }
if ! have asciinema; then sudo apt-get update && sudo apt-get install -y asciinema; fi
if ! have agg; then echo "agg missing (install with: go install github.com/asciinema/agg/cmd/agg@latest)"; exit 1; fi
echo "[1/2] Recording 8s demo..."
asciinema rec --quiet --idle-time-limit 1 --max-wait 1 -c "bash -lc 'echo Kydras OmniTerm demo; tmux -V; tmux new -s demo -d; tmux ls; sleep 8; tmux kill-session -t demo || true'" "$CAST"
echo "[2/2] Rendering GIF..."
agg --font-size 16 --theme dracula --speed 1 "$CAST" "$GIF"
echo "Wrote $GIF"
