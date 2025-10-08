#!/usr/bin/env bash
set -euo pipefail

# OmniTerm demo recorder
# - Records a short cast with asciinema
# - Renders to assets/demo.gif with agg (if present)

CAST="assets/demo.cast"
GIF="assets/demo.gif"
mkdir -p assets

have() { command -v "$1" >/dev/null 2>&1; }

if ! have asciinema; then
  echo "asciinema not found."
  echo "Install: sudo apt-get update && sudo apt-get install -y asciinema"
  exit 1
fi

if ! have agg; then
  echo "agg (renderer) not found."
  echo "Install from https://github.com/asciinema/agg"
  echo "Quick way (Go toolchain):"
  echo "  sudo apt-get install -y golang-go && go install github.com/asciinema/agg@latest"
  echo "  sudo ln -sf \"$HOME/go/bin/agg\" /usr/local/bin/agg"
  exit 1
fi

echo "[1/2] Recording 8s demo (auto-stops)..."
asciinema rec --quiet --idle-time-limit 1 --max-wait 1 -c "bash -lc 'echo Kydras OmniTerm demo; tmux -V; tmux new -s demo -d; tmux ls; sleep 8; tmux kill-session -t demo || true' "$CAST"

echo "[2/2] Rendering GIF..."
agg --font-size 16 --theme dracula --speed 1 "$CAST" "$GIF"
echo "Wrote $GIF"
