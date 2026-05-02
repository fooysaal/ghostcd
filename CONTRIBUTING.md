# Contributing to GhostCD

First off — thanks for taking the time to contribute! 👻

GhostCD is a small but sharp tool. Contributions that keep it fast, clean, and non-intrusive are most welcome.

---

## Ways to contribute

- 🐛 **Bug reports** — something broke? Open an issue with your OS, shell version, and terminal emulator
- 💡 **Feature ideas** — open an issue first before writing code, so we can discuss fit
- 🔧 **Bug fixes** — PRs welcome, keep them focused on one thing
- 📖 **Docs** — improving the README, adding examples, fixing typos
- 🐚 **Shell support** — fish, nushell, or other shells you want to add adapters for

---

## Getting started

```bash
git clone https://github.com/YOUR_USERNAME/ghostcd.git
cd ghostcd

# Test your changes by sourcing directly
source ghostcd.bash   # or ghostcd.zsh
```

No build step, no dependencies beyond Python 3. Just source and test.

---

## Project structure

```
ghostcd/
├── ghost_preview.py   # Core renderer — shell agnostic
├── ghostcd.bash       # Bash adapter (readline bind -x)
├── ghostcd.zsh        # Zsh adapter (zle widgets)
├── install.sh         # Installer
├── uninstall.sh       # Uninstaller
├── README.md
└── CONTRIBUTING.md
```

The **core renderer** (`ghost_preview.py`) is intentionally shell-agnostic. Shell adapters are thin wrappers that:
1. Intercept keystrokes
2. Extract the cd path from the buffer
3. Call render or erase

If you're adding a new shell adapter, follow that same pattern.

---

## Guidelines

- **Don't break the terminal.** This is non-negotiable. The tool must leave the terminal in a clean state under all conditions — Enter, Ctrl-C, Ctrl-U, rapid typing, tab completion, window resize.
- **No external dependencies.** Python 3 stdlib only. No pip packages. No compiled binaries.
- **Keep it fast.** The preview should feel instant. If your change adds latency, reconsider.
- **Test edge cases.** Empty dirs, permission-denied dirs, symlinks, dirs with 1000+ files, paths with spaces.

---

## Reporting bugs

Please include:
- OS and version (e.g. Ubuntu 24.04)
- Shell and version (`bash --version` or `zsh --version`)
- Terminal emulator (e.g. GNOME Terminal, Alacritty, Kitty)
- Steps to reproduce
- What you expected vs what happened
- Screenshot or screen recording if possible

---

## Code style

- Shell: follow existing style — 4-space indent, functions prefixed with `_gcd_` (bash) or `_ghostcd_` (zsh)
- Python: standard PEP8, no external imports

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
