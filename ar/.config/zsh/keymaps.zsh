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
bindkey -s '^T' '^utm\n'
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
bindkey -M viins '^\' insert-last-command-output

# bind y/Y to yank until end of line/yank whole line
# bindkey -M vicmd y zsh-system-clipboard-vicmd-vi-yank-eol
# bindkey -M vicmd Y zsh-system-clipboard-vicmd-vi-yank-whole-line
