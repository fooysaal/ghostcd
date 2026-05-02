# ─────────────────────────────────────────────
#  GhostCD — BASH adapter v4
#  Source in ~/.bashrc:
#    source /path/to/ghostcd/ghostcd.bash
#
#  Strategy: ghost is always printed BELOW the
#  current terminal row. We track the row we
#  printed on and erase by row — no PS1 reprint,
#  no cursor save/restore fighting readline.
# ─────────────────────────────────────────────

GHOSTCD_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GHOSTCD_PY="$GHOSTCD_SCRIPT_DIR/ghost_preview.py"
_GCD_LINES=0      # lines currently occupied by ghost
_GCD_LAST=""      # last path rendered (to skip duplicate renders)

# ══════════════════════════════════════════════
#  ERASE — wipe every ghost line from the screen
# ══════════════════════════════════════════════
_gcd_erase() {
    [[ $_GCD_LINES -eq 0 ]] && return
    local i
    printf "\033[s"
    for (( i=1; i<=_GCD_LINES; i++ )); do
        printf "\033[%dB\r\033[2K" "$i"
        printf "\033[%dA" "$i"
    done
    printf "\033[u"
    _GCD_LINES=0
    _GCD_LAST=""
}

# ══════════════════════════════════════════════
#  RENDER — print ghost below the prompt line
# ══════════════════════════════════════════════
_gcd_render() {
    local raw="$1"
    local expanded="${raw/#\~/$HOME}"
    local dir="${expanded%/}"

    if [[ ! -d "$dir" ]]; then
        _gcd_erase
        return
    fi

    if [[ "$dir" == "$_GCD_LAST" ]]; then
        return
    fi

    # Always erase old ghost FIRST before drawing new one
    _gcd_erase

    local out
    out=$(python3 "$GHOSTCD_PY" "$dir" 2>/dev/null) || return
    [[ -z "$out" ]] && return

    local lc
    lc=$(printf '%s\n' "$out" | wc -l)
    _GCD_LINES=$lc
    _GCD_LAST="$dir"

    printf "\033[s"
    local linenum=0
    while IFS= read -r line; do
        (( linenum++ ))
        printf "\033[%dB\r%s\033[%dA" "$linenum" "$line" "$linenum"
    done <<< "$out"
    printf "\033[u"
}

# ══════════════════════════════════════════════
#  CHECK — inspect READLINE_LINE and act
# ══════════════════════════════════════════════
_gcd_check() {
    local buf="$READLINE_LINE"
    local path=""
    if [[ "$buf" =~ ^[[:space:]]*cd[[:space:]]+(.+)$ ]]; then
        path="${BASH_REMATCH[1]}"
    fi
    if [[ -n "$path" ]]; then
        _gcd_render "$path"
    else
        _gcd_erase
    fi
}

# ══════════════════════════════════════════════
#  TAB — manual completion, no macro recursion
# ══════════════════════════════════════════════
_gcd_tab() {
    local cur="${READLINE_LINE:0:$READLINE_POINT}"
    local last="${cur##* }"

    # Erase ghost BEFORE printing any completion list
    _gcd_erase

    local -a matches
    mapfile -t matches < <(compgen -f -- "$last" 2>/dev/null | sort)

    if (( ${#matches[@]} == 0 )); then
        printf "\a"
        return
    elif (( ${#matches[@]} == 1 )); then
        local completed="${matches[0]}"
        [[ -d "$completed" ]] && completed+="/"
        local before="${cur%$last}"
        READLINE_LINE="${before}${completed}${READLINE_LINE:$READLINE_POINT}"
        READLINE_POINT=$(( ${#before} + ${#completed} ))
    else
        printf "\n"
        printf '%s\n' "${matches[@]}" | column 2>/dev/null || printf '%s  ' "${matches[@]}"
        printf "\n"
        # Insert longest common prefix
        local prefix="${matches[0]}"
        local m
        for m in "${matches[@]}"; do
            while [[ "$m" != "$prefix"* ]]; do
                prefix="${prefix%?}"
                [[ -z "$prefix" ]] && break 2
            done
        done
        if [[ -n "$prefix" && "$prefix" != "$last" ]]; then
            local before="${cur%$last}"
            READLINE_LINE="${before}${prefix}${READLINE_LINE:$READLINE_POINT}"
            READLINE_POINT=$(( ${#before} + ${#prefix} ))
        fi
    fi

    _gcd_check
}
bind -x '"\t": _gcd_tab'

# ══════════════════════════════════════════════
#  / KEY
# ══════════════════════════════════════════════
_gcd_slash() {
    READLINE_LINE+="/"
    (( READLINE_POINT++ ))
    _gcd_check
}
bind -x '"/": _gcd_slash'

# ══════════════════════════════════════════════
#  BACKSPACE
# ══════════════════════════════════════════════
_gcd_bs() {
    if (( READLINE_POINT > 0 )); then
        READLINE_LINE="${READLINE_LINE:0:$(( READLINE_POINT-1 ))}${READLINE_LINE:$READLINE_POINT}"
        (( READLINE_POINT-- ))
    fi
    _gcd_check
}
bind -x '"\177": _gcd_bs'
bind -x '"\010": _gcd_bs'

# ══════════════════════════════════════════════
#  CTRL-U / CTRL-C
# ══════════════════════════════════════════════
_gcd_wipe() { READLINE_LINE=""; READLINE_POINT=0; _gcd_erase; }
bind -x '"\025": _gcd_wipe'

_gcd_ctrlc() { _gcd_erase; READLINE_LINE=""; READLINE_POINT=0; }
bind -x '"\003": _gcd_ctrlc'

# ══════════════════════════════════════════════
#  PROMPT_COMMAND — hard reset on every new prompt
# ══════════════════════════════════════════════
_gcd_precmd() {
    _GCD_LINES=0
    _GCD_LAST=""
}

if [[ -z "$PROMPT_COMMAND" ]]; then
    PROMPT_COMMAND="_gcd_precmd"
else
    PROMPT_COMMAND="_gcd_precmd${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi

echo "👻 GhostCD loaded (bash)"
