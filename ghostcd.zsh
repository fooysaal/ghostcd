# ─────────────────────────────────────────────
#  GhostCD — ZSH adapter
#  Source this in your ~/.zshrc:
#    source /path/to/ghostcd/ghostcd.zsh
# ─────────────────────────────────────────────

GHOSTCD_SCRIPT_DIR="${0:A:h}"
GHOSTCD_PY="$GHOSTCD_SCRIPT_DIR/ghost_preview.py"
GHOSTCD_LAST_PREVIEW=""
GHOSTCD_PREVIEW_LINES=0

# ── erase the ghost from the terminal ──────────
_ghostcd_erase() {
    if [[ $GHOSTCD_PREVIEW_LINES -gt 0 ]]; then
        # Move cursor up and clear each line
        local i
        for (( i=0; i<GHOSTCD_PREVIEW_LINES; i++ )); do
            printf "\033[1A\033[2K"
        done
        GHOSTCD_PREVIEW_LINES=0
        GHOSTCD_LAST_PREVIEW=""
    fi
}

# ── extract path from what the user is typing ──
_ghostcd_extract_path() {
    local buffer="$1"
    # Match: cd <path>  (with optional trailing slash)
    if [[ "$buffer" =~ ^[[:space:]]*cd[[:space:]]+(.+)$ ]]; then
        echo "${match[1]}"
    fi
}

# ── render the ghost preview ───────────────────
_ghostcd_render() {
    local raw_path="$1"
    local expanded="${raw_path/#\~/$HOME}"
    local check_path="${expanded%/}"

    if [[ ! -d "$check_path" ]]; then
        _ghostcd_erase
        return
    fi

    if [[ "$check_path" == "$GHOSTCD_LAST_PREVIEW" ]]; then
        return
    fi

    _ghostcd_erase

    local preview_output
    preview_output=$(python3 "$GHOSTCD_PY" "$check_path" 2>/dev/null)

    if [[ -n "$preview_output" ]]; then
        local line_count=$(echo "$preview_output" | wc -l)
        local total=$(( line_count + 2 ))

        # FIX 1: save cursor, jump down, print BELOW prompt, restore cursor
        printf "\0337"                     # save cursor position
        printf "\033[%dB" "$total"         # move down to make room
        printf "\033[1A"                   # one step back
        printf "\n%s\n" "$preview_output"  # print the ghost
        printf "\0338"                     # restore cursor to prompt line

        GHOSTCD_PREVIEW_LINES=$total
        GHOSTCD_LAST_PREVIEW="$check_path"
    fi
}

# ── zle widget: fires on every keystroke ───────
_ghostcd_widget() {
    local path
    path=$(_ghostcd_extract_path "$BUFFER")

    if [[ -n "$path" ]]; then
        _ghostcd_render "$path"
    else
        # FIX 3: buffer is empty or not a cd → erase immediately
        _ghostcd_erase
    fi

    zle .self-insert 2>/dev/null || true
}

# ── zle widget: fires on Enter ─────────────────
_ghostcd_accept_line() {
    _ghostcd_erase
    zle .accept-line
}

# ── zle widget: fires on Backspace ─────────────
_ghostcd_backward_delete() {
    zle .backward-delete-char
    local path
    path=$(_ghostcd_extract_path "$BUFFER")
    if [[ -n "$path" ]]; then
        _ghostcd_render "$path"
    else
        # FIX 3: backspaced to empty / non-cd → erase
        _ghostcd_erase
    fi
}

# ── FIX 2: Tab completion hook ─────────────────
# zsh's expand-or-complete fills in the path,
# then we check the completed buffer and render.
_ghostcd_complete() {
    zle expand-or-complete   # run normal tab completion
    local path
    path=$(_ghostcd_extract_path "$BUFFER")
    if [[ -n "$path" ]]; then
        _ghostcd_render "$path"
    else
        _ghostcd_erase
    fi
}
zle -N _ghostcd_complete

# ── Register widgets ───────────────────────────
zle -N _ghostcd_accept_line
zle -N _ghostcd_backward_delete

# Bind Enter
bindkey "^M" _ghostcd_accept_line
bindkey "^J" _ghostcd_accept_line

# Bind Backspace
bindkey "^?" _ghostcd_backward_delete
bindkey "^H" _ghostcd_backward_delete

# FIX 2: Bind Tab to our completion+preview widget
bindkey "^I" _ghostcd_complete

# Hook every printable character keystroke
# We use zshaddhistory hook + precmd for cleaner integration
autoload -Uz add-zsh-hook

# Use zle-line-pre-redraw for live updates (available in zsh 5.3+)
_ghostcd_line_pre_redraw() {
    local path
    path=$(_ghostcd_extract_path "$BUFFER")
    if [[ -n "$path" ]]; then
        _ghostcd_render "$path"
    else
        _ghostcd_erase
    fi
}
zle -N zle-line-pre-redraw _ghostcd_line_pre_redraw

# Clean up any ghost on prompt load
_ghostcd_precmd() {
    _ghostcd_erase
}
add-zsh-hook precmd _ghostcd_precmd

# ── Done ───────────────────────────────────────
echo "👻 GhostCD loaded (zsh)"
