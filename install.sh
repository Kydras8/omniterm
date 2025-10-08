#!/usr/bin/env bash
set -euo pipefail

# Detect a terminal (prioritize xfce4-terminal, gnome-terminal, konsole)
detect_term() {
  for T in xfce4-terminal gnome-terminal konsole xterm; do
    command -v "$T" >/dev/null 2>&1 && { echo "$T"; return; }
  done
  echo "xfce4-terminal"
}
TERM_APP="$(detect_term)"

# Install kyboost to ~/.local/bin and run it via zsh
mkdir -p "$HOME/.local/bin"
install -m 0755 kyboost "$HOME/.local/bin/kyboost"
if ! command -v zsh >/dev/null 2>&1; then
  echo "zsh not found; installing (sudo may prompt)..."
  sudo apt-get update && sudo apt-get install -y zsh
fi
zsh "$HOME/.local/bin/kyboost"

# Desktop entries
desk_copy() {
  local src="$1" name="$2"
  local dest="$HOME/Desktop/$name"
  cp -f "$src" "$dest"
  chmod +x "$dest" || true
  echo "Installed desktop shortcut: $dest"
}

# Pick the right launcher by TERM_APP
case "$TERM_APP" in
  xfce4-terminal) desk_copy "kydras-omninterm.desktop" "kydras-omninterm.desktop" ;;
  gnome-terminal) desk_copy "kydras-omninterm-gnome.desktop" "kydras-omninterm.desktop" ;;
  konsole)        desk_copy "kydras-omninterm-konsole.desktop" "kydras-omninterm.desktop" ;;
  *)              desk_copy "kydras-omninterm.desktop" "kydras-omninterm.desktop" ;;
esac

# Thunar action (if present)
if command -v thunar >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/share/file-manager/actions"
  cp -f thunar-open-omni.action "$HOME/.local/share/file-manager/actions/"
  thunar -q || true
  echo "Installed Thunar custom action."
fi

echo "Install complete. Open the desktop icon or run: tmux attach -t omni || tmux new -s omni"
