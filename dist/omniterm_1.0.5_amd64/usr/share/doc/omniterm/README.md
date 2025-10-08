# Kydras OmniTerm (God-mode)

Zsh-first terminal upgrade for Kali/Debian with tmux session, stealth toggles, and Kydras branding.

## Quick install
    curl -fsSL https://raw.githubusercontent.com/Kydras8/omniterm/main/kyboost | zsh

### Features
- zsh prompt with git branch (vcs_info)
- tmux status + session `omni`
- Helpers: `kygo kyinit kyzip kypush ky_stealth_on ky_stealth_off`
- Thunar action & desktop launcher
- Lawful use only: stealth alters history/PATH

### Thunar action
    mkdir -p ~/.local/share/file-manager/actions
    cp thunar-open-omni.action ~/.local/share/file-manager/actions/
    thunar -q

### Desktop shortcut
    cp kydras-omninterm.desktop ~/Desktop/
    chmod +x ~/Desktop/kydras-omninterm.desktop

## Demo (placeholder)
<p align="center">
  <img src="assets/demo.gif" alt="OmniTerm demo (placeholder)" width="720"/>
</p>

> To regenerate the demo GIF locally, run: `./scripts/record_demo.sh` (requires asciinema + agg).

**Install (Debian/Kali)**

```bash
curl -fsSL https://raw.githubusercontent.com/Kydras8/omniterm/main/kyboost | zsh
```
