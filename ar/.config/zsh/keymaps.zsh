#!/bin/zsh

### --- CUSTOM FUNCTIONS --- ###
# man
function man-command-line() { pre_cmd "man"; }

# sudo
function sudo-command-line() { pre_cmd "sudo"; }

# clears the shell and displays the dir tree with level 2
function clear-tree-2() {
    clear
    tree -L 2
    zle reset-prompt
}
zle -N clear-tree-2

# clears the shell and displays the dir tree with level 3
function clear-tree-3() { clear && tree -L 3 && zle reset-prompt; }
zle -N clear-tree-3

# prints the current date in ISO 8601
function print-current-date() { LBUFFER+=$(date -I); }
zle -N print-current-date

# prints the current Unix timestamp
function print-unix-timestamp() { LBUFFER+=$(date +%s); }
zle -N print-unix-timestamp

# git status
function git-status() { clear && git status && zle reset-prompt; }
zle -N git-status

# appends the clipboard contents to the buffer
function vi-append-clip-selection() { char=${RBUFFER:0:1} && RBUFFER=${RBUFFER:1} && RBUFFER=$char$(clippaste)$RBUFFER; }

# copy
function detect-clipboard() {
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

function copybuffer () {
    if builtin which clipcopy &>/dev/null; then
        printf "%s" "$BUFFER" | clipcopy
    fi
}

# Function to switch to the left tmux pane and maximize it
function tmux_left_pane() {
    export TMUX_PANE_DIRECTION="right"
    if [[ $TMUX_PANE_DIRECTION == "right" ]]; then
        tmux select-pane -L # Move to the left (opposite of right)
    elif [[ $TMUX_PANE_DIRECTION == "bottom" ]]; then
        tmux select-pane -U # Move to the top (opposite of bottom)
    fi
    tmux resize-pane -Z
}


### --- GLOBAL --- ###
# emacs style
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# function key bindings
bindkey '^X^E' clear-tree-2
bindkey '^X^W' clear-tree-3
bindkey '^X^S' git-status
bindkey '^X^X^T' print-current-date
bindkey '^X^X^U' print-unix-timestamp


### --- VI-MODE --- ###
if [[ -f "${ZPLUGINDIR:-${HOME}/.local/bin/zsh}/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ]]; then
    ### --- ZSH-VI-MODE--- ###
    # config
    ZVM_INIT_MODE=sourcing
    ZVM_VI_ESCAPE_BINDKEY=jk
    ZVM_VI_INSERT_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
    ZVM_VI_VISUAL_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
    ZVM_VI_OPPEND_ESCAPE_BINDKEY=$ZVM_VI_ESCAPE_BINDKEY
    ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
    ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
    ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE
    ZVM_LAZY_KEYBINDINGS=false
    # ZVM_VI_HIGHLIGHT_BACKGROUND=#458588


    function zvm_bind_script() {
        local keymap="$1"
        local key="$2"
        local script="$3"

        # Dynamically define a widget to run the script
        eval "function run_script_${keymap}_${key//\^/}() {
        zle -I
        $script
        zle reset-prompt
        }"

        # Register the widget with zsh-vi-mode
        zvm_define_widget "run_script_${keymap}_${key//\^/}"
        zvm_bindkey "$keymap" "$key" "run_script_${keymap}_${key//\^/}"
    }

    function zvm_after_init() {
        ### --- KEY BINDINGS --- ###
        # programs & scripts
        bindkey -s '^B' '^ubc -lq\n'
        bindkey -s '^D' '^ucdi\n'
        bindkey -s '^F' '^ufzffiles\n'
        bindkey -s '^G' '^ulf\n'
        # bindkey -s '^G' '^uyazi\n'
        bindkey -s '^N' '^ulastfiles\n'
        bindkey -s '^O' '^utmo\n'
        bindkey -s '^P' '^ufzfpass\n'
        bindkey -s '^Q' '^uhtop\n'
        bindkey -s '^T' '^usessionizer\n'
        bindkey -s '^Y' '^ulfcd\n'
        # bindkey -s '^Y' '^uyazicd\n'
        bindkey -s '^Z' '^upd\n'
        # bindkey -s '^_' '^u\n'

        # ctrl+x key bindings
        zvm_bind_script viins '^X^A' 'ali'
        zvm_bind_script viins '^X^B' 'gitopenbranch'
        zvm_bind_script viins '^X^D' 'fD'
        zvm_bind_script viins '^X^F' 'gitfiles'
        zvm_bind_script viins '^X^G' 'rgafiles '
        zvm_bind_script viins '^X^L' 'gloac'
        zvm_bind_script viins '^X^N' 'lastfiles -l'
        #  zvm_bind_script viins '^X^O' '^u\n'
        zvm_bind_script viins '^X^Q' 'fpkill'
        zvm_bind_script viins '^X^R' 'fgst'
        zvm_bind_script viins '^X^T' 'gitstagedfiles'
        zvm_bind_script viins '^X^U' 'gitupdate'
        #  zvm_bind_script viins '^X^]' '^u\n'
        zvm_bind_script viins '^X^_' 'fzffns'
        zvm_bind_script viins '^X^X^B' 'rbackup'
        zvm_bind_script viins '^X^X^P' 'pcyr'
        zvm_bind_script viins '^X^X^R' 'rbackup -r'
        zvm_bind_script viins '^X^X^S' 'sshadd'
        zvm_bind_script viins '^X^X^Y' 'yay -Syu && remaps'

        # widgets
        zvm_define_widget sudo-command-line
        zvm_bindkey vicmd '^S' sudo-command-line
        zvm_bindkey viins '^S' sudo-command-line
        zvm_define_widget insert_last_command_output
        zvm_bindkey viins '^]' insert_last_command_output
        zvm_define_widget tmux_left_pane
        zvm_bindkey vicmd '^[\' tmux_left_pane
        zvm_bindkey viins '^[\' tmux_left_pane
        zvm_define_widget man-command-line
        zvm_bindkey vicmd '^X^M' man-command-line
        zvm_bindkey viins '^X^M' man-command-line
        zvm_define_widget vi-append-clip-selection
        zvm_bindkey viins "^X^P" vi-append-clip-selection
        zvm_bindkey vicmd "^X^P" vi-append-clip-selection
        zvm_define_widget copybuffer
        zvm_bindkey viins "^X^Y" copybuffer
        zvm_bindkey vicmd "^X^Y" copybuffer
    }

    # key bindings (lazy)
    # function zvm_after_lazy_keybindings() {
    #
    # }

    # Append a command directly
    # Since the default initialization mode, this plugin will overwrite the previous key
    # bindings, this causes the key bindings of other plugins (i.e. fzf, zsh-autocomplete, etc.) to fail.
    # zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')
    # function zvm_after_init() {
    #     [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    # }
else
    ### --- Built-in --- ###
    # Cursor shape
    bindkey -v # activate vim mode.
    KEYTIMEOUT=5

    # Change cursor shape for different vi modes.
    function zle-keymap-select () {
        case "$KEYMAP $1" in
            vicmd*|*block) echo -ne '\e[1 q' ;;         # block
            viins*|main*|''|*beam) echo -ne '\e[5 q' ;; # beam
        esac
    }
    zle -N zle-keymap-select

    function zle-line-init() {
        zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
        echo -ne "\e[5 q"
    }
    zle -N zle-line-init
    echo -ne '\e[5 q' # Use beam shape cursor on startup.
    function preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.


    ### --- VI-MODE KEY BINDINGS --- ###
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'l' vi-forward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'j' vi-down-line-or-history
    bindkey -v '^?' backward-delete-char
    bindkey '^[[P' delete-char

    # edit line in vim with ctrl-v in viins and ctrl-e in vicmd
    autoload edit-command-line
    zle -N edit-command-line
    bindkey '^X^V' edit-command-line        # ctrl-v
    bindkey -M vicmd '^[[P' vi-delete-char  # delete
    bindkey -M vicmd '^e' edit-command-line # ctrl-e
    bindkey -M visual '^[[P' vi-delete      # delete
    bindkey -M viins 'jk' vi-cmd-mode       # normal mode

    # last command output
    zle -N insert_last_command_output
    bindkey -M viins '^]' insert_last_command_output

    # man
    zle -N man-command-line
    bindkey -M emacs '^X^M' man-command-line
    bindkey -M vicmd '^X^M' man-command-line
    bindkey -M viins '^X^M' man-command-line

    # sudo
    zle -N sudo-command-line
    bindkey -M emacs '^S' sudo-command-line
    bindkey -M vicmd '^S' sudo-command-line
    bindkey -M viins '^S' sudo-command-line

    # bind y/Y to yank until end of line/yank whole line
    # bindkey -M vicmd y zsh-system-clipboard-vicmd-vi-yank-eol
    # bindkey -M vicmd Y zsh-system-clipboard-vicmd-vi-yank-whole-line

    # appends the clipboard contents to the buffer
    zle -N vi-append-clip-selection
    bindkey -M emacs "^X^P" vi-append-clip-selection
    bindkey -M viins "^X^P" vi-append-clip-selection
    bindkey -M vicmd "^X^P" vi-append-clip-selection

    # copy buffer
    zle -N copybuffer
    bindkey -M emacs "^X^Y" copybuffer
    bindkey -M viins "^X^Y" copybuffer
    bindkey -M vicmd "^X^Y" copybuffer

    # Register the function as a ZLE widget
    zle -N tmux_left_pane
    bindkey -M vicmd '^[\' tmux_left_pane
    bindkey -M viins '^[\' tmux_left_pane

    ### --- DEFAULT KEY BINDINGS --- ###
    # programs & scripts
    bindkey -s '^B' '^ubc -lq\n'
    bindkey -s '^D' '^ucdi\n'
    bindkey -s '^F' '^ufzffiles\n'
    bindkey -s '^G' '^ulf\n'
    bindkey -s '^N' '^ulastfiles\n'
    bindkey -s '^O' '^utmo\n'
    bindkey -s '^P' '^ufzfpass\n'
    bindkey -s '^Q' '^uhtop\n'
    bindkey -s '^T' '^usessionizer\n'
    bindkey -s '^Y' '^ulfcd\n'
    bindkey -s '^Z' '^upd\n'
    bindkey -s '^_' '^ucht\n'
    bindkey -s '^X^A' '^uali\n'
    bindkey -s '^X^B' '^ugitopenbranch\n'
    bindkey -s '^X^D' '^ufD\n'
    bindkey -s '^X^F' '^ugitfiles\n'
    bindkey -s '^X^G' '^urgafiles '
    bindkey -s '^X^L' '^ugloac\n'
    bindkey -s '^X^N' '^ulastfiles -l\n'
    bindkey -s '^X^O' '^uylogy\n'
    bindkey -s '^X^Q' '^ufpkill\n'
    bindkey -s '^X^R' '^ufgst\n'
    bindkey -s '^X^T' '^ugitstagedfiles\n'
    bindkey -s '^X^U' '^ugitupdate\n'
    bindkey -s '^X^]' '^uylogt\n'
    bindkey -s '^X^_' '^ufzffns\n'
    bindkey -s '^X^X^B' '^urbackup\n'
    bindkey -s '^X^X^P' '^upcyr\n'
    bindkey -s '^X^X^R' '^urbackup -r\n'
    bindkey -s '^X^X^S' '^usshadd\n'
    bindkey -s '^X^X^Y' '^uyay -Syu && remaps\n'
fi
