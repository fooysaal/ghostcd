<div align="center">

# 👻 GhostCD

**See inside directories as you type — without ever leaving your prompt.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Shell: bash](https://img.shields.io/badge/shell-bash-blue.svg)]()
[![Shell: zsh](https://img.shields.io/badge/shell-zsh-green.svg)]()
[![Platform: Linux](https://img.shields.io/badge/platform-Linux-lightgrey.svg)]()
[![Python: 3.x](https://img.shields.io/badge/python-3.x-blue.svg)]()

<!-- Add your demo video here -->
<!-- Replace the line below with your actual webm/gif -->
> 📹 **Demo** — _add your screen recording here_
> `![GhostCD Demo](demo.webm)`

</div>

---

## What is GhostCD?

When you type `cd someDir/` in your terminal, GhostCD instantly shows you a **ghost preview** of what's inside that directory — right below your cursor, without you pressing Enter or running any extra command.

Keep typing deeper into subdirectories and the preview updates live. The moment you press **Enter**, the ghost disappears without a trace. Your terminal stays clean and fully in control.

```
se7@machine:~$ cd Downloads/
  👻 ghost view → ~/Downloads  (12 items)
  ├── 📁 projects/
  ├── 📁 ghostcd/
  ├── 💻 notes.md              4K
  ├── 📦 archive.zip          31K
  ├── 🖼  photo.jpg             9K
  └── ... and 7 more
  📂 2 dirs  📄 10 files

se7@machine:~$ cd Downloads/projects/
  👻 ghost view → ~/Downloads/projects  (3 items)
  ├── 📁 myapp/
  ├── 📁 scripts/
  └── 💻 README.md             2K
  📂 2 dirs  📄 1 files

se7@machine:~$ cd Downloads/projects/   ← press Enter
se7@machine:~/Downloads/projects$       ← ghost is gone, no trace
```

---

## Features

- 👻 **Live ghost preview** as you type a `cd` path
- 🔍 **Deepens with you** — preview updates as you go deeper
- 🧹 **Zero trace** — disappears cleanly on Enter, Ctrl-C, or Ctrl-U
- 📁 **File type icons** — dirs, code, images, zips, executables
- 📏 **File sizes** — at a glance
- ⚡ **Fast** — pure Python stdlib, no external dependencies
- 🐚 **Works on bash and zsh** — covers virtually all Linux users
- 🔒 **Non-intrusive** — doesn't change how `cd` works, ever

---

## Requirements

| Requirement | Notes |
|---|---|
| Linux or macOS | Tested on Ubuntu 22.04+ |
| Python 3 | Pre-installed on virtually all Linux distros |
| bash **or** zsh | Both supported out of the box |
| A modern terminal | ANSI escape code support (GNOME Terminal, Kitty, Alacritty, iTerm2, etc.) |

No pip packages. No compiled binaries. No root access needed.

---

## Installation

### Option A — One-liner (recommended)

```bash
git clone https://github.com/fooysaal/ghostcd.git ~/ghostcd
cd ~/ghostcd && bash install.sh
```

### Option B — Manual

```bash
# 1. Clone the repo
git clone https://github.com/fooysaal/ghostcd.git ~/ghostcd

# 2. Add to your shell config manually

# For bash — add this line to ~/.bashrc:
echo 'source "$HOME/ghostcd/ghostcd.bash"' >> ~/.bashrc

# For zsh — add this line to ~/.zshrc:
echo 'source "$HOME/ghostcd/ghostcd.zsh"' >> ~/.zshrc

# 3. Reload your shell (no restart needed)
source ~/.bashrc   # or source ~/.zshrc
```

You should see: `👻 GhostCD loaded (bash)` — you're ready.

---

## Usage

Just use `cd` the way you always have. Nothing else to learn.

| What you do | What happens |
|---|---|
| Type `cd someDir/` | Ghost preview appears below your prompt |
| Type deeper `cd someDir/inner/` | Preview updates to the inner directory |
| Press **Tab** | Autocompletes the path, then shows preview |
| Press **Enter** | Ghost vanishes, you land in the directory |
| Press **Backspace** | Preview updates as path gets shorter |
| Press **Ctrl-C** or **Ctrl-U** | Ghost erases, line clears |
| Type anything other than `cd ...` | No ghost — terminal behaves normally |
| Path doesn't exist | No ghost shown |
| Permission denied | Graceful message, no crash |

---

## Uninstall

```bash
cd ~/ghostcd
bash uninstall.sh
```

This removes GhostCD from your `~/.bashrc` and `~/.zshrc`, creates backups of both files, and prints instructions to delete the folder.

To verify it's fully gone:
```bash
exec $SHELL   # reload shell — you should NOT see "GhostCD loaded"
```

Then delete the folder:
```bash
rm -rf ~/ghostcd
```

---

## How it works

```
You type:  cd dirA/dirB/
                │
         Shell hook intercepts the keystroke
                │
         Extracts path: dirA/dirB/
                │
         Checks if it's a real directory (os.path.isdir)
                │
         Python renders ghost preview using ANSI escape codes
         (printed below the prompt line via cursor positioning)
                │
You press Enter
                │
         Ghost is erased (cursor up + clear line for each row)
                │
         Normal cd executes — terminal is completely clean
```

**Bash adapter** uses `bind -x` — readline's shell-function binding mechanism — to intercept `/`, Tab, and Backspace keystrokes without touching readline's internal completion engine.

**Zsh adapter** uses `zle` (Zsh Line Editor) widgets — zsh's native per-keystroke hook system — for smoother, more granular interception.

The **core renderer** (`ghost_preview.py`) is entirely shell-agnostic. It takes a path, reads the directory with `os.scandir()`, and prints a formatted tree using ANSI color codes. Both shell adapters call it the same way.

---

## File structure

```
ghostcd/
├── ghost_preview.py   # Core renderer (shell-agnostic Python)
├── ghostcd.bash       # Bash adapter (readline bind -x)
├── ghostcd.zsh        # Zsh adapter (zle widgets)
├── install.sh         # Auto-installer (detects your shell)
├── uninstall.sh       # Clean uninstaller
├── CONTRIBUTING.md    # How to contribute
├── LICENSE            # MIT
└── README.md          # You are here
```

---

## Known limitations

| Limitation | Details |
|---|---|
| Bash triggers on `/` and Tab only | Bash has no per-keystroke hook like zsh — by design |
| Max 12 items shown | Keeps the preview compact; footer shows remaining count |
| Spaces in paths | Supported, but Tab completion may not complete them fully yet |
| Very wide filenames | Truncated at terminal width |
| Fish / Nushell | Not yet supported — contributions welcome! |

---

## Contributing

GhostCD is open source and contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Some ideas for the community to explore:

- 🐟 **Fish shell adapter**
- 🖥️ **Window resize handling** (re-render ghost on `SIGWINCH`)
- 🎨 **Theming support** — custom colors via env vars
- 📄 **File preview** — peek at file content for small text files
- 🔍 **Fuzzy path matching** — ghost even for partial/typo paths

---

## Inspired by

The idea came from watching how tab completion in Linux terminals "just knows" what's in a directory — and wondering: *what if that knowledge was always visible, not just on Tab?*

Tools like `zoxide`, `fzf`, `lsd`, and `ranger` showed that the terminal UX space still has a lot of room for innovation.

---

## License

MIT — see [LICENSE](LICENSE).

---

<div align="center">
Made with 👻 for terminal lovers everywhere
</div>
