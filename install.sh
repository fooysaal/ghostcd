#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  GhostCD Installer
#  Detects your shell, installs GhostCD, and sets it up.
#  Run: bash install.sh
# ─────────────────────────────────────────────────────────────

set -e

GHOSTCD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GHOSTCD_PY="$GHOSTCD_DIR/ghost_preview.py"

echo ""
echo "👻 GhostCD Installer"
echo "────────────────────────────────────"

# ── 1. Check Python ────────────────────────────
if ! command -v python3 &>/dev/null; then
    echo "❌ Python3 is required but not found."
    echo "   Install it with: sudo apt install python3"
    exit 1
fi
echo "✅ Python3 found: $(python3 --version)"

# ── 2. Make preview script executable ─────────
chmod +x "$GHOSTCD_PY"
echo "✅ ghost_preview.py is ready"

# ── 3. Detect shell ────────────────────────────
CURRENT_SHELL="$(basename "$SHELL")"
echo "🔍 Detected shell: $CURRENT_SHELL"

# ── 4. Install for detected shell ─────────────
SOURCE_LINE=""
RC_FILE=""

if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    SOURCE_LINE="source \"$GHOSTCD_DIR/ghostcd.zsh\""
    RC_FILE="$HOME/.zshrc"
elif [[ "$CURRENT_SHELL" == "bash" ]]; then
    SOURCE_LINE="source \"$GHOSTCD_DIR/ghostcd.bash\""
    RC_FILE="$HOME/.bashrc"
else
    echo "⚠️  Shell '$CURRENT_SHELL' not directly supported."
    echo "   Defaulting to bash adapter."
    SOURCE_LINE="source \"$GHOSTCD_DIR/ghostcd.bash\""
    RC_FILE="$HOME/.bashrc"
fi

# ── 5. Check if already installed ─────────────
if grep -qF "ghostcd" "$RC_FILE" 2>/dev/null; then
    echo "⚠️  GhostCD entry already found in $RC_FILE"
    echo "   Skipping to avoid duplicates."
else
    echo "" >> "$RC_FILE"
    echo "# GhostCD - Ghost directory preview" >> "$RC_FILE"
    echo "$SOURCE_LINE" >> "$RC_FILE"
    echo "✅ Added to $RC_FILE"
fi

# ── 6. Also support the other shell optionally ─
if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    OTHER_RC="$HOME/.bashrc"
    OTHER_LINE="source \"$GHOSTCD_DIR/ghostcd.bash\""
    echo ""
    read -rp "   Also install for bash (if you switch shells)? [y/N] " yn
    if [[ "$yn" =~ ^[Yy]$ ]]; then
        if grep -qF "ghostcd" "$OTHER_RC" 2>/dev/null; then
            echo "   Already in $OTHER_RC, skipping."
        else
            echo "" >> "$OTHER_RC"
            echo "# GhostCD - Ghost directory preview" >> "$OTHER_RC"
            echo "$OTHER_LINE" >> "$OTHER_RC"
            echo "✅ Also added to $OTHER_RC"
        fi
    fi
fi

# ── 7. Done ────────────────────────────────────
echo ""
echo "────────────────────────────────────"
echo "✅ GhostCD installed!"
echo ""
echo "   To activate now (no restart needed):"
echo "   $ source $RC_FILE"
echo ""
echo "   Then try it:"
echo "   $ cd /     ← type this and watch the ghost appear as you type"
echo ""
echo "👻 Happy exploring!"
