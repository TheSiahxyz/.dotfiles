#!/bin/zsh

### --- Prompt --- ###
autoload -U colors && colors
autoload -Uz add-zsh-hook vcs_info
setopt prompt_subst
add-zsh-hook precmd vcs_info
PROMPT='%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%F{green}${vcs_info_msg_0_}%{$reset_color%}$%b '
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats       "%{$fg[blue]%}(%{$fg[black]%}%b%{$fg[blue]%}:%r%{$fg[yellow]%}%u%{$reset_color%}%m%{$fg[magenta]%}%c%{$fg[blue]%})"
zstyle ':vcs_info:git:*' actionformats "%{$fg[blue]%}(%{$fg[black]%}%b%{$fg[blue]%}:%r%{$reset_color%}|%{$fg[red]%}%a%u%c%{$fg[blue]%})"
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-incoming-commits git-unpushed-commits
+vi-git-untracked() {
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == "true" ]] && \
        git status --porcelain | grep -m 1 "^??" &>/dev/null
    then
        hook_com[misc]+="%{$fg[magenta]%}?"
    fi
}
+vi-git-incoming-commits() {
    # git fetch > /dev/null 2>&1
    if [[ $(git rev-list HEAD..origin/$(git rev-parse --abbrev-ref HEAD) --count) -gt 0 ]]; then
        hook_com[misc]+="%{$fg[red]%}!"
    fi
}
+vi-git-unpushed-commits() {
    if [[ $(git rev-list origin/$(git rev-parse --abbrev-ref HEAD)..HEAD --count) -gt 0 ]]; then
        hook_com[misc]+="%{$fg[green]%}="
    fi
}

### --- ZSH --- ###
# GnuPG
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    gpgconf --launch gpg-agent
fi
export GPG_TTY="$(tty)"
gpg-connect-agent updatestartuptty /bye >/dev/null

# Options
stty stop undef             # Disable ctrl-s to freeze terminal.
setopt autocd
setopt extendedglob
setopt nomatch
setopt menucomplete
setopt interactive_comments
unsetopt bad_pattern

# History in cache directory
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh/history"
setopt inc_append_history
setopt appendhistory
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space    # ignores all commands starting with a blank space! Usefull for passwords

# Style
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(vi-forward-char forward-char)
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS:#(vi-forward-char|forward-char)})
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish


### --- Autoload compinit and run it --- ###
autoload -Uz compinit       # Autoload compinit
_comp_options+=(globdots)   # Include hidden files in completion
compinit                    # Initialize completion system
zmodload zsh/complist       # Load completion list module
zmodload -i zsh/parameter   # Load last command output

# _dotbare_completion_cmd
zstyle ':completion:*' menu select  # selectable menu
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' 'r:|=*' 'l:|=* r:|=*'     # case insensitive completion
zstyle ':completion:*' special-dirs true    # Complete . and .. special directories
zstyle ':completion:*' list-colors ''   # colorize completion lists
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'    # colorize kill list

# fzf-tab
zstyle ':completion:*:git-checkout:*' sort false    # disable sort when completing `git checkout`
zstyle ':completion:*:descriptions' format '[%d]'   # set descriptions format to enable group support
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}   # set list-colors to enable filename colorizing
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'   # preview directory's content with exa when completing cd
zstyle ':fzf-tab:*' switch-group ',' '.'    # switch group using `,` and `.`


### --- Vi Mode --- ###
autoload edit-command-line; zle -N edit-command-line
zle -N zle-keymap-select
echo -ne '\e[5 q'   # Use beam shape cursor on startup.


### --- Load ZSH Configs, Aliases, Functions, and Shortcuts --- ###
for zsh_config (${ZDOTDIR:-${HOME}/.config/zsh}/*.zsh) source $zsh_config
[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/aliasrc"
# [ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/scriptrc" ] && source "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/scriptrc"
[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/zshnameddirrc"
[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/git-aliasrc" ] && source "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/git-aliasrc"
