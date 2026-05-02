#!/usr/bin/env python3
"""
GhostCD - Core Preview Renderer
Shell-agnostic. Called by bash/zsh adapters.
Usage: ghost_preview.py <path>
"""

import os
import sys
import stat

# ANSI color codes
RESET      = "\033[0m"
DIM        = "\033[2m"
ITALIC     = "\033[3m"
BOLD       = "\033[1m"
CYAN       = "\033[36m"
BLUE       = "\033[34m"
YELLOW     = "\033[33m"
GREEN      = "\033[32m"
RED        = "\033[31m"
MAGENTA    = "\033[35m"
WHITE      = "\033[37m"

# Icons (works on most modern terminals, falls back gracefully)
ICON_DIR   = "📁"
ICON_FILE  = "📄"
ICON_LINK  = "🔗"
ICON_EXEC  = "⚡"
ICON_IMAGE = "🖼 "
ICON_CODE  = "💻"
ICON_ZIP   = "📦"

CODE_EXTS  = {'.py', '.js', '.ts', '.sh', '.c', '.cpp', '.rs', '.go', '.java', '.rb', '.php', '.html', '.css', '.json', '.yaml', '.yml', '.toml', '.md'}
IMAGE_EXTS = {'.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp', '.bmp'}
ZIP_EXTS   = {'.zip', '.tar', '.gz', '.bz2', '.xz', '.rar', '.7z', '.deb', '.rpm'}

def get_icon(entry_path, is_dir, is_link, is_exec):
    if is_link:
        return ICON_LINK
    if is_dir:
        return ICON_DIR
    ext = os.path.splitext(entry_path)[1].lower()
    if ext in CODE_EXTS:
        return ICON_CODE
    if ext in IMAGE_EXTS:
        return ICON_IMAGE
    if ext in ZIP_EXTS:
        return ICON_ZIP
    if is_exec:
        return ICON_EXEC
    return ICON_FILE

def get_color(is_dir, is_link, is_exec):
    if is_link:   return MAGENTA
    if is_dir:    return CYAN
    if is_exec:   return GREEN
    return WHITE

def format_size(size):
    for unit in ['B', 'K', 'M', 'G']:
        if size < 1024:
            return f"{size:.0f}{unit}"
        size /= 1024
    return f"{size:.0f}T"

def render_preview(path):
    path = os.path.expanduser(path)
    path = os.path.realpath(path)

    if not os.path.isdir(path):
        return

    try:
        entries = os.scandir(path)
        entries = sorted(entries, key=lambda e: (not e.is_dir(), e.name.lower()))
    except PermissionError:
        print(f"{DIM}{RED}  👻 Permission denied: {path}{RESET}")
        return

    entries = list(entries)
    total   = len(entries)
    show    = entries[:12]  # reduced from 16 to keep preview compact

    # ── header ──────────────────────────────────────────────
    short_path = path.replace(os.path.expanduser("~"), "~")
    print(f"{DIM}{ITALIC}  👻 ghost view → {BOLD}{short_path}{RESET}{DIM}{ITALIC}  ({total} items){RESET}")

    # ── entries ─────────────────────────────────────────────
    dirs_count  = 0
    files_count = 0

    for i, entry in enumerate(show):
        is_last  = (i == len(show) - 1) and (total <= 12)
        branch   = "└──" if is_last else "├──"

        try:
            st      = entry.stat(follow_symlinks=False)
            is_dir  = entry.is_dir(follow_symlinks=False)
            is_link = entry.is_symlink()
            is_exec = bool(st.st_mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)) and not is_dir
            size    = format_size(st.st_size) if not is_dir else ""
        except OSError:
            is_dir = is_link = is_exec = False
            size   = ""

        if is_dir:
            dirs_count += 1
        else:
            files_count += 1

        icon  = get_icon(entry.name, is_dir, is_link, is_exec)
        color = get_color(is_dir, is_link, is_exec)
        name  = entry.name + ("/" if is_dir else "")

        size_str = f"{DIM}{WHITE}{size:>4}{RESET}" if size else "    "

        print(f"{DIM}  {branch} {icon} {color}{DIM}{ITALIC}{name}{RESET}  {size_str}")

    # ── overflow notice ──────────────────────────────────────
    if total > 12:
        remaining = total - 12
        print(f"{DIM}  └── ... and {remaining} more{RESET}")

    # ── footer ───────────────────────────────────────────────
    print(f"{DIM}{ITALIC}  📂 {dirs_count} dirs  📄 {files_count} files{RESET}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(0)
    render_preview(sys.argv[1])
