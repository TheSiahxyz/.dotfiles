#!/bin/zsh

### --- Vi Mode --- ###
# Change cursor shape for different vi modes.
zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q' ;;      # block
        viins|main) echo -ne '\e[5 q' ;; # beam
    esac
}
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
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

# edit line in vim with ctrl-e:
bindkey '^v' edit-command-line          # ctrl-e
bindkey -M vicmd '^[[P' vi-delete-char  # delete
bindkey -M vicmd '^e' edit-command-line # ctrl-e
bindkey -M visual '^[[P' vi-delete      # delete
bindkey -M viins 'jk' vi-cmd-mode       # normal mode

# programs
bindkey -s '^a' '^ulf\n'
bindkey -s '^b' '^ubc -lq\n'
bindkey -s '^d' '^ufD\n'
bindkey -s '^e' '^use\n'
bindkey -s '^f' '^ucdi\n'
bindkey -s '^g' '^ulfcd\n'
bindkey -s '^s' '^usshadd\n'
bindkey -s '^x^b' '^urbackup\n'
bindkey -s '^x^f' '^usudo lf\n'
bindkey '^[[P' delete-char

# man
man-command-line() {
    command_line "man"
}
zle -N man-command-line
bindkey -M emacs '^x^m' man-command-line
bindkey -M vicmd '^x^m' man-command-line
bindkey -M viins '^x^m' man-command-line

# sudo
sudo-command-line() {
    command_line "sudo"
}
zle -N command-line
bindkey -M emacs '^x^s' sudo-command-line
bindkey -M vicmd '^x^s' sudo-command-line
bindkey -M viins '^x^s' sudo-command-line

# last command output
zle -N insert-last-command-output
bindkey "^o" insert-last-command-output

# bind Y to yank until end of line
bindkey -M vicmd Y zsh-system-clipboard-vicmd-vi-yank-eol
