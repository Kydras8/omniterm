#!/usr/bin/env bash
set -euo pipefail
echo "== OmniTerm Doctor =="
echo "Shell: $SHELL"; command -v zsh || true
echo "tmux: $(tmux -V 2>/dev/null || echo 'missing')"
for T in xfce4-terminal gnome-terminal konsole; do
  printf "%s: %s\n" "$T" "$(command -v "$T" || echo 'missing')"
done
echo "gh: $(gh --version 2>/dev/null | head -n1 || echo 'missing')"
echo "git: $(git --version 2>/dev/null || echo 'missing')"
echo "kyboost: $(command -v kyboost || echo 'missing')"
printf ".zshrc.kydras: "; [ -f "$HOME/.zshrc.kydras" ] && echo OK || echo MISSING
printf ".tmux.conf.kydras: "; [ -f "$HOME/.tmux.conf.kydras" ] && echo OK || echo MISSING
echo "HISTFILE: ${HISTFILE:-unset}"
echo "PATH: $PATH"
