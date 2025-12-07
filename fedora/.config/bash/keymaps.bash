#!/bin/bash

# --------- Bash port (u-prefix removed) ---------
# Put this into ~/.bashrc and run: source ~/.bashrc

# enable vi editing mode
set -o vi

# Try to set beam cursor at prompt (best-effort)
PROMPT_COMMAND='echo -ne "\e[5 q"'

# ---------- helper: pre_cmd ----------
pre_cmd() {
    local txt="$1"
    if [[ -z "${READLINE_LINE+set}" ]]; then
        printf '%s ' "$txt"
        return
    fi
    local left=${READLINE_LINE:0:READLINE_POINT}
    local right=${READLINE_LINE:READLINE_POINT}
    READLINE_LINE="${left}${txt} ${right}"
    READLINE_POINT=$(( READLINE_POINT + ${#txt} + 1 ))
}

# ---------- Clipboard detection ----------
_detect_clipboard_setup() {
    if command -v pbcopy >/dev/null 2>&1 && command -v pbpaste >/dev/null 2>&1; then
        clipcopy() { cat "${1:-/dev/stdin}" | pbcopy; }
        clippaste() { pbaste; }
        return 0
    fi
    if command -v wl-copy >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
        clipcopy() { cat "${1:-/dev/stdin}" | wl-copy; }
        clippaste() { wl-paste --no-newline; }
        return 0
    fi
    if command -v xclip >/dev/null 2>&1; then
        clipcopy() { cat "${1:-/dev/stdin}" | xclip -selection clipboard; }
        clippaste() { xclip -selection clipboard -out; }
        return 0
    fi
    if command -v xsel >/dev/null 2>&1; then
        clipcopy() { cat "${1:-/dev/stdin}" | xsel --clipboard --input; }
        clippaste() { xsel --clipboard --output; }
        return 0
    fi
    if command -v clip.exe >/dev/null 2>&1; then
        clipcopy() { cat "${1:-/dev/stdin}" | clip.exe; }
        clippaste() { powershell.exe -noprofile -command Get-Clipboard 2>/dev/null; }
        return 0
    fi
    if command -v tmux >/dev/null 2>&1 && [ -n "${TMUX:-}" ]; then
        clipcopy() { tmux load-buffer -; }
        clippaste() { tmux save-buffer -; }
        return 0
    fi
    return 1
}
_detect_clipboard_setup || true

paste_clipboard_to_readline() {
    if ! command -v clippaste >/dev/null 2>&1; then
        _detect_clipboard_setup || { printf 'No clipboard helper found\n' >&2; return 1; }
    fi
    local clip
    clip=$(clippaste 2>/dev/null) || return 1
    clip="${clip%$'\n'}"
    if [[ -z "${READLINE_LINE+set}" ]]; then
        printf '%s' "$clip"
        return
    fi
    local left=${READLINE_LINE:0:READLINE_POINT}
    local right=${READLINE_LINE:READLINE_POINT}
    READLINE_LINE="${left}${clip}${right}"
    READLINE_POINT=$(( READLINE_POINT + ${#clip} ))
}

copy_readline_to_clipboard() {
    if [[ -z "${READLINE_LINE+set}" ]]; then
        printf 'No current line to copy\n' >&2
        return 1
    fi
    if ! command -v clipcopy >/dev/null 2>&1; then
        _detect_clipboard_setup || { printf 'No clipboard helper found\n' >&2; return 1; }
    fi
    printf '%s' "${READLINE_LINE}" | clipcopy
}

# ---------- basic utilities ----------
clear_tree_2() { clear; tree -L 2 2>/dev/null || true; }
clear_tree_3() { clear; tree -L 3 2>/dev/null || true; }
insert_current_date() {
    local txt="$(date -I)"
    if [[ -z "${READLINE_LINE+set}" ]]; then printf '%s' "$txt"; return; fi
    local left=${READLINE_LINE:0:READLINE_POINT}; local right=${READLINE_LINE:READLINE_POINT}
    READLINE_LINE="${left}${txt}${right}"; READLINE_POINT=$(( READLINE_POINT + ${#txt} ))
}
insert_unix_timestamp() {
    local txt="$(date +%s)"
    if [[ -z "${READLINE_LINE+set}" ]]; then printf '%s' "$txt"; return; fi
    local left=${READLINE_LINE:0:READLINE_POINT}; local right=${READLINE_LINE:READLINE_POINT}
    READLINE_LINE="${left}${txt}${right}"; READLINE_POINT=$(( READLINE_POINT + ${#txt} ))
}
git_status_clear() { clear; git status 2>/dev/null || git status --short 2>/dev/null || true; }
tmux_left_pane() { tmux select-pane -L 2>/dev/null || true; tmux resize-pane -Z 2>/dev/null || true; }
vi_append_clip_selection() { paste_clipboard_to_readline; }
copybuffer() { copy_readline_to_clipboard; }
background_start() { local cmd="$1"; shift || return 0; for arg in "$@"; do "$cmd" "$arg" &>/dev/null & done; }

# ---------- pre_cmd widgets ----------
man_command_line() { pre_cmd "man"; }
sudo_command_line() { pre_cmd "sudo"; }

# ---------- wrappers (u-prefix REMOVED) ----------
bc() { command -v bc >/dev/null 2>&1 && /usr/bin/env bc "$@" || printf 'bc: not found\n' >&2; }
cdi() { command -v cdi >/dev/null 2>&1 && cdi "$@" || printf 'cdi: not found\n' >&2; }
lastvim() { command -v lastnvim >/dev/null 2>&1 && lastvim "$@" || printf 'lastvim: not found\n' >&2; }
htop() { command -v htop >/dev/null 2>&1 && htop "$@" || printf 'htop: not found\n' >&2; }
sessionizer() { command -v sessionizer >/dev/null 2>&1 && sessionizer "$@" || printf 'sessionizer: not found\n' >&2; }
upd() { command -v upd >/dev/null 2>&1 && upd "$@" || printf 'upd: not found\n' >&2; }
cht() { command -v cht >/dev/null 2>&1 && cht "$@" || printf 'cht: not found\n' >&2; }   # from '^ucht' -> 'cht'
ali() { command -v ali >/dev/null 2>&1 && ali "$@" || printf 'ali: not found\n' >&2; }
fD() { command -v fD >/dev/null 2>&1 && fD "$@" || printf 'fD: not found\n' >&2; }
rgafiles() { command -v rgafiles >/dev/null 2>&1 && rgafiles "$@" || printf 'rgafiles: not found\n' >&2; }
lastvim_l() { command -v lastnvim >/dev/null 2>&1 && lastvim -l || printf 'lastvim: not found\n' >&2; }

# ---------- Readline key bindings (bind -x) ----------
# basic movement
bind '"\C-a": beginning-of-line'
bind '"\C-e": end-of-line'

# function key bindings (map to bash functions above)
bind -x '"\C-x\C-e":clear_tree_2'
bind -x '"\C-x\C-w":clear_tree_3'
bind -x '"\C-x\C-s":git_status_clear'
bind -x '"\C-x\C-x\C-t":insert_current_date'   # ^X^X^T (alternate: C-x C-t)
bind -x '"\C-x\C-t":insert_current_date'
bind -x '"\C-x\C-x\C-u":insert_unix_timestamp' # ^X^X^U
bind -x '"\C-x\C-u":insert_unix_timestamp'

# clipboard binds
bind -x '"\C-x\C-p":paste_clipboard_to_readline'   # ^X^P
bind -x '"\C-x\C-y":copy_readline_to_clipboard'    # ^X^Y

# edit in editor
edit_command_line() {
    local tmp content
    tmp=$(mktemp /tmp/bash-edit.XXXXXX) || return
    printf '%s' "${READLINE_LINE:-}" > "$tmp"
    "${EDITOR:-vim}" "$tmp"
    content=$(<"$tmp")
    READLINE_LINE="$content"
    READLINE_POINT=${#content}
    rm -f "$tmp"
}
bind -x '"\C-x\C-v":edit_command_line'  # ^X^V

# man & sudo insertion
bind -x '"\C-x\C-m":man_command_line'  # ^X^M
stty -ixon 2>/dev/null || true
bind -x '"\C-s":sudo_command_line'    # ^S  (stty -ixon to avoid flow control)

# tmux left pane (bind ESC + backslash)
bind -x $'\e\\':tmux_left_pane

# ---------- mappings of the original bindkey -s lines (u removed) ----------
bind -x '"\C-b":__bc'    # will call function __bc below
__bc() { bc -lq "$@"; }

bind -x '"\C-d":cdi'
bind -x '"\C-f":fzffiles'
bind -x '"\C-g":lf'
bind -x '"\C-n":lastnvim'
bind -x '"\C-o":tmo'
bind -x '"\C-p":fzfpass'
bind -x '"\C-q":htop'
bind -x '"\C-t":sessionizer'
bind -x '"\C-y":lfcd'
bind -x '"\C-z":upd'
# ^_ (Ctrl-_) mapped to cht (from '^ucht' -> 'cht')
bind -x $'"\C-_":cht'

# ^X^... sequences (Ctrl-X then key)
bind -x '"\C-x\C-a":ali'
bind -x '"\C-x\C-b":gitopenbranch'
bind -x '"\C-x\C-d":fD'
bind -x '"\C-x\C-f":gitfiles'
bind -x '"\C-x\C-g":rgafiles'
bind -x '"\C-x\C-l":gloac'
bind -x '"\C-x\C-n":lastnvim_l'
bind -x '"\C-x\C-q":fpkill'
bind -x '"\C-x\C-r":fgst'
bind -x '"\C-x\C-t":gitstagedfiles'
bind -x '"\C-x\C-u":gitupdate'
bind -x '"\C-x\C-_":fzffns'   # ^X^_
bind -x '"\C-x\C-x\C-b":rbackup'
bind -x '"\C-x\C-x\C-p":pcyr'
bind -x '"\C-x\C-x\C-r":rbackup'  # rbackup -r not directly supported via bind -x args; call rbackup then ask user for flags if needed
bind -x '"\C-x\C-x\C-s":sshadd'
bind -x '"\C-x\C-x\C-y":yay_remaps'
