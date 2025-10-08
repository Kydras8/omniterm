#!/usr/bin/env bash
set -euo pipefail

echo "Removing Kydras OmniTerm components..."

rm -f "$HOME/.local/bin/kyboost" \
      "$HOME/.local/bin/kygo" \
      "$HOME/.local/bin/kyinit" \
      "$HOME/.local/bin/kyzip" \
      "$HOME/.local/bin/kypush" \
      "$HOME/.local/bin/ky_stealth_on" \
      "$HOME/.local/bin/ky_stealth_off"

sed -i '/Load Kydras OmniTerm config/d;/source \$HOME\/\.zshrc\.kydras/d' "$HOME/.zshrc" 2>/dev/null || true
rm -f "$HOME/.zshrc.kydras" "$HOME/.tmux.conf.kydras" "$HOME/.tmux.conf"
rm -rf "$HOME/.kydras" 2>/dev/null || true

rm -f "$HOME/.local/share/file-manager/actions/thunar-open-omni.action" 2>/dev/null || true
rm -f "$HOME/Desktop/kydras-omninterm.desktop" 2>/dev/null || true

echo "OmniTerm removed. You may still have an active tmux session: run 'tmux ls' to check."
