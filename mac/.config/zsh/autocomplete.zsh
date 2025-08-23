### --- Auto-completes aliases --- ###
# alias     - normal aliases (completed with trailing space)
# balias    - blank aliases (completed without space)
# ialias    - ignored aliases (not completed)


# ignored aliases
typeset -a ialiases
ialiases=()

ialias() {
    alias $@
    args="$@"
    args=${args%%\=*}
    ialiases+=(${args##* })
}


# blank aliases
typeset -a baliases
baliases=()

balias() {
    alias $@
    args="$@"
    args=${args%%\=*}
    baliases+=(${args##* })
}


# functionality
expand-alias-space() {
    [[ $LBUFFER =~ "\<(${(j:|:)baliases})\$" ]] && insertBlank=$?
    if [[ ! $LBUFFER =~ "\<(${(j:|:)ialiases})\$" ]]; then
        zle _expand_alias
        zle expand-word
    fi
    zle self-insert
    if [[ "$insertBlank" -eq 0 ]]; then
        zle backward-delete-char
    fi
}
zle -N expand-alias-space


# starts multiple args as programs in background
background() {
    for ((i=2;i<=$#;i++)); do
        ${@[1]} ${@[$i]} &> /dev/null &
    done
}


# A function for expanding any aliases before accepting the line as is and executing the entered command
expand-alias-and-accept-line() {
    expand-alias-space
    # zle .backward-delete-char
    zle .accept-line
}
# zle -N accept-line expand-alias-and-accept-line


bindkey '^ ' expand-alias-space    # ctrl-space to bypass completion
bindkey ' '  magic-space
bindkey -M isearch ' ' magic-space


# file completion patterns
zstyle ':completion:*:*:nvim:*' file-patterns '^*.(pdf|odt|ods|doc|docx|xls|xlsx|odp|ppt|pptx|mp4|mkv|aux):source-files' '*:all-files'
zstyle ':completion:*:*:(build-workshop|build-document):*' file-patterns '*.mom'
