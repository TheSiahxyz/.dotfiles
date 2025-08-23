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
zstyle ':vcs_info:git:*' formats       "%{$fg[blue]%}(%{$fg[white]%}%b%{$fg[blue]%}:%r%{$fg[yellow]%}%u%m%{$fg[magenta]%}%c%{$fg[blue]%})"
zstyle ':vcs_info:git:*' actionformats "%{$fg[blue]%}(%{$fg[white]%}%b%{$fg[blue]%}:%r%{$reset_color%}|%{$fg[red]%}%a%u%c%{$fg[blue]%})"
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-behind-upstream git-ahead-upstream git-diverged-upstream
+vi-git-untracked() {
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == "true" ]] && \
        git status --porcelain | grep -m 1 "^??" &>/dev/null
    then
        hook_com[misc]+="%{$fg[yellow]%}%%"
    fi
}
+vi-git-behind-upstream() {
    if [[ $(git rev-list HEAD..$(git rev-parse --abbrev-ref @{upstream}) --count) -gt 0 ]]; then
        hook_com[misc]+="%{$fg[red]%}<"
    fi
}
+vi-git-ahead-upstream() {
    if [[ $(git rev-list $(git rev-parse --abbrev-ref @{upstream})..HEAD --count) -gt 0 ]]; then
        hook_com[misc]+="%{$fg[green]%}>"
    fi
}
+vi-git-diverged-upstream() {
    local ahead_count=$(git rev-list --count $(git rev-parse --abbrev-ref @{upstream})..HEAD 2>/dev/null)
    local behind_count=$(git rev-list --count HEAD..$(git rev-parse --abbrev-ref @{upstream}) 2>/dev/null)
    if [[ "$ahead_count" -gt 0 && "$behind_count" -gt 0 ]]; then
        hook_com[misc]+="%{$fg[white]%}<>"
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
stty -ixon  # Disable Ctrl+S and Ctrl+Q flow control
setopt autocd
setopt extendedglob
setopt nomatch
setopt menucomplete
setopt interactive_comments
unsetopt bad_pattern

# History in cache directory
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE="${XDG_DATA_HOME:-${HOME}/.local/share}/history/sh_history"
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


### --- Load ZSH Configs, Aliases, Functions, and Shortcuts --- ###
# NOTE: the sequence of sourcing files is strict. Be careful to change the sequence.
[ -f "${ZDOTDIR:-${HOME}/.config/zsh}/git.zsh" ] && source "${ZDOTDIR:-${HOME}/.config/zsh}/git.zsh"
[ -f "${ZDOTDIR:-${HOME}/.config/zsh}/p10k.zsh" ] && source "${ZDOTDIR:-${HOME}/.config/zsh}/p10k.zsh"
[ -f "${ZDOTDIR:-${HOME}/.config/zsh}/autocomplete.zsh" ] && source "${ZDOTDIR:-${HOME}/.config/zsh}/autocomplete.zsh"
[ -f "${ZDOTDIR:-${HOME}/.config/zsh}/scripts.zsh" ] && source "${ZDOTDIR:-${HOME}/.config/zsh}/scripts.zsh"
[ -f "${ZDOTDIR:-${HOME}/.config/zsh}/keymaps.zsh" ] && source "${ZDOTDIR:-${HOME}/.config/zsh}/keymaps.zsh"
[ -f "${ZDOTDIR:-${HOME}/.config/zsh}/plugins.zsh" ] && source "${ZDOTDIR:-${HOME}/.config/zsh}/plugins.zsh"
[ -f "${ZDOTDIR:-${HOME}/.config/zsh}/packages.zsh" ] && source "${ZDOTDIR:-${HOME}/.config/zsh}/packages.zsh"
[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/aliasrc"
[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/git-aliasrc" ] && source "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/git-aliasrc"
[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/shortcutenvrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutenvrc"
[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/zshnameddirrc"

if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ]; then
    terminal_count=$(pgrep -u "$USER" -ax "${TERMINAL:-st}" | grep -Ev 'ncmpcpp|newsboat|pulsemixer|spterm|splf|spcalc|stig|vimwikitodo' | wc -l)
    if [ "$terminal_count" -le 1 ]; then
        if ! tmux has-session 2>/dev/null; then
            exec tmux new-session -s code
        else
            exec tmux attach-session
        fi
    fi
fi
