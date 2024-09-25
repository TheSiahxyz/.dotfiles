#!/bin/zsh

### --- Vi Mode --- ###
# Change cursor shape for different vi modes.
zle-keymap-select() {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q' ;;      # block
        viins|main) echo -ne '\e[5 q' ;; # beam
    esac
}
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

### --- Key Bindings --- ###
# emacs style
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# vi mode
bindkey -v
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char
bindkey '^[[P' delete-char

# edit line in vim with ctrl-v in viins and ctrl-e in vicmd
bindkey '^v' edit-command-line          # ctrl-v
bindkey -M vicmd '^[[P' vi-delete-char  # delete
bindkey -M vicmd '^e' edit-command-line # ctrl-e
bindkey -M visual '^[[P' vi-delete      # delete
bindkey -M viins 'jk' vi-cmd-mode       # normal mode

# programs
bindkey -s '^B' '^ubc -lq\n'
bindkey -s '^D' '^ucdi\n'
bindkey -s '^F' '^uff\n'
bindkey -s '^G' '^ufdot\n'
bindkey -s '^K' '^uhtop\n'
bindkey -s '^N' '^unv .\n'
bindkey -s '^O' '^ulf\n'
bindkey -s '^P' '^upd\n'
bindkey -s '^T' '^utms\n'
bindkey -s '^Y' '^ulfcd\n'
bindkey -s '^Z' '^ucdo\n'
bindkey -s '^_' '^usscs\n'
bindkey -s '^X^B' '^urbackup\n'
bindkey -s '^X^D' '^ufD\n'
bindkey -s '^X^F' '^ufF\n'
bindkey -s '^X^S' '^usshadd\n'

# man
man-command-line() {
    command_line "man"
}
zle -N man-command-line
bindkey -M emacs '^X^M' man-command-line
bindkey -M vicmd '^X^M' man-command-line
bindkey -M viins '^X^M' man-command-line

# sudo
sudo-command-line() {
    command_line "sudo"
}
zle -N sudo-command-line
bindkey -M emacs '^S' sudo-command-line
bindkey -M vicmd '^S' sudo-command-line
bindkey -M viins '^S' sudo-command-line

# last command output
zle -N insert-last-command-output
bindkey -M viins '^]' insert-last-command-output

# bind y/Y to yank until end of line/yank whole line
# bindkey -M vicmd y zsh-system-clipboard-vicmd-vi-yank-eol
# bindkey -M vicmd Y zsh-system-clipboard-vicmd-vi-yank-whole-line

# clears the shell and displays the current dir
clear-ls-all() {
    clear
    exa -al
    zle reset-prompt
}
zle -N clear-ls-all

bindkey '^X^K' clear-ls-all

# clears the shell and displays the dir tree with level 2
clear-tree-2() {
    clear
    tree -L 2
    zle reset-prompt
}
zle -N clear-tree-2

bindkey '^X^J' clear-tree-2

# clears the shell and displays the dir tree with level 3
clear-tree-3() {
    clear
    tree -L 3
    zle reset-prompt
}
zle -N clear-tree-3

bindkey '^X^H' clear-tree-3

# prints the current date in ISO 8601
print-current-date() {
    LBUFFER+=$(date -I)
}
zle -N print-current-date

bindkey '^X^T' print-current-date

# prints the current Unix timestamp
print-unix-timestamp() {
    LBUFFER+=$(date +%s)
}
zle -N print-unix-timestamp

bindkey '^X^U' print-unix-timestamp

# git status
git-status() {
    clear
    git status
    zle reset-prompt
}
zle -N git-status

bindkey '^X^G' git-status

# appends the clipboard contents to the buffer
vi-append-clip-selection() {
    char=${RBUFFER:0:1}
    RBUFFER=${RBUFFER:1}
    RBUFFER=$char$(clippaste)$RBUFFER;
}
zle -N vi-append-clip-selection

bindkey -M emacs "^X^P" vi-append-clip-selection
bindkey -M viins "^X^P" vi-append-clip-selection
bindkey -M vicmd "^X^P" vi-append-clip-selection

# copy
detect-clipboard() {
    emulate -L zsh

    if [[ "${OSTYPE}" == darwin* ]] && (( ${+commands[pbcopy]} )) && (( ${+commands[pbpaste]} )); then
        function clipcopy() { cat "${1:-/dev/stdin}" | pbcopy; }
        function clippaste() { pbpaste; }
    elif [[ "${OSTYPE}" == (cygwin|msys)* ]]; then
        function clipcopy() { cat "${1:-/dev/stdin}" > /dev/clipboard; }
        function clippaste() { cat /dev/clipboard; }
    elif (( $+commands[clip.exe] )) && (( $+commands[powershell.exe] )); then
        function clipcopy() { cat "${1:-/dev/stdin}" | clip.exe; }
        function clippaste() { powershell.exe -noprofile -command Get-Clipboard; }
    elif [ -n "${WAYLAND_DISPLAY:-}" ] && (( ${+commands[wl-copy]} )) && (( ${+commands[wl-paste]} )); then
        function clipcopy() { cat "${1:-/dev/stdin}" | wl-copy &>/dev/null &|; }
        function clippaste() { wl-paste --no-newline; }
    elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xsel]} )); then
        function clipcopy() { cat "${1:-/dev/stdin}" | xsel --clipboard --input; }
        function clippaste() { xsel --clipboard --output; }
    elif [ -n "${DISPLAY:-}" ] && (( ${+commands[xclip]} )); then
        function clipcopy() { cat "${1:-/dev/stdin}" | xclip -selection clipboard -in &>/dev/null &|; }
        function clippaste() { xclip -out -selection clipboard; }
    elif (( ${+commands[lemonade]} )); then
        function clipcopy() { cat "${1:-/dev/stdin}" | lemonade copy; }
        function clippaste() { lemonade paste; }
    elif (( ${+commands[doitclient]} )); then
        function clipcopy() { cat "${1:-/dev/stdin}" | doitclient wclip; }
        function clippaste() { doitclient wclip -r; }
    elif (( ${+commands[win32yank]} )); then
        function clipcopy() { cat "${1:-/dev/stdin}" | win32yank -i; }
        function clippaste() { win32yank -o; }
    elif [[ $OSTYPE == linux-android* ]] && (( $+commands[termux-clipboard-set] )); then
        function clipcopy() { cat "${1:-/dev/stdin}" | termux-clipboard-set; }
        function clippaste() { termux-clipboard-get; }
    elif [ -n "${TMUX:-}" ] && (( ${+commands[tmux]} )); then
        function clipcopy() { tmux load-buffer "${1:--}"; }
        function clippaste() { tmux save-buffer -; }
    else
        function _retry_clipboard_detection_or_fail() {
            local clipcmd="${1}"; shift
            if detect-clipboard; then
                "${clipcmd}" "$@"
            else
                print "${clipcmd}: Platform $OSTYPE not supported or xclip/xsel not installed" >&2
                return 1
            fi
        }
        function clipcopy() { _retry_clipboard_detection_or_fail clipcopy "$@"; }
        function clippaste() { _retry_clipboard_detection_or_fail clippaste "$@"; }
        return 1
    fi
}

function clipcopy clippaste {
    unfunction clipcopy clippaste
    detect-clipboard || true # let one retry
    "$0" "$@"
}

copybuffer () {
    if builtin which clipcopy &>/dev/null; then
        printf "%s" "$BUFFER" | clipcopy
    fi
}
zle -N copybuffer

bindkey -M emacs "^X^O" copybuffer
bindkey -M viins "^X^O" copybuffer
bindkey -M vicmd "^X^O" copybuffer
