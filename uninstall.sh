#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  GhostCD Uninstaller
#  Removes GhostCD from your shell config files cleanly.
#  Run: bash uninstall.sh
# ─────────────────────────────────────────────────────────────

set -e

echo ""
echo "👻 GhostCD Uninstaller"
echo "────────────────────────────────────"

REMOVED=0

_remove_from_rc() {
    local rc="$1"
    if [[ ! -f "$rc" ]]; then
        return
    fi

    if grep -q "ghostcd\|GhostCD" "$rc" 2>/dev/null; then
        # Create a backup before modifying
        cp "$rc" "${rc}.ghostcd.bak"

        # Remove the GhostCD block (comment line + source line)
        sed -i '/# GhostCD - Ghost directory preview/d' "$rc"
        sed -i '/ghostcd/d' "$rc"

        echo "✅ Removed from $rc"
        echo "   Backup saved at ${rc}.ghostcd.bak"
        REMOVED=1
    else
        echo "   GhostCD not found in $rc — skipping"
    fi
}

_remove_from_rc "$HOME/.bashrc"
_remove_from_rc "$HOME/.zshrc"
_remove_from_rc "$HOME/.bash_profile"
_remove_from_rc "$HOME/.profile"

echo ""
if [[ $REMOVED -eq 1 ]]; then
    echo "────────────────────────────────────"
    echo "✅ GhostCD has been uninstalled."
    echo ""
    echo "   To apply changes without restarting:"
    echo "   $ exec \$SHELL"
    echo ""
    echo "   You can safely delete this folder now:"
    echo "   $ rm -rf $(pwd)"
else
    echo "   GhostCD was not found in any shell config."
fi
echo ""
