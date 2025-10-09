# Kydras OmniTerm — v1.0.14

God-mode terminal for Kali/Debian: zsh-first, tmux session `omni`, stealth toggles, desktop/Thunar launchers, CI builds, and signed .deb releases.

## Install (Debian/Kali)
```bash
curl -fsSL https://raw.githubusercontent.com/Kydras8/omniterm/main/kyboost | zsh
```

## Verify (.deb, GPG)
```bash
curl -fsSL -O https://github.com/Kydras8/omniterm/releases/download/v1.0.9/omniterm_1.0.5_amd64.deb
curl -fsSL -o GPG-KEY-KYDRAS.txt https://raw.githubusercontent.com/Kydras8/omniterm/main/GPG-KEY-KYDRAS.txt
gpg --import GPG-KEY-KYDRAS.txt
dpkg-sig --verify omniterm_1.0.5_amd64.deb
```

## Demo
Generated locally with `./scripts/record_demo.sh` (requires asciinema + agg).
