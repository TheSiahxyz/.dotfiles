#!/bin/zsh

###########################################################################################
###########################################################################################
### --- Stow --- ###
function dstw() { "${XDG_DOTFILES_DIR:-${HOME}/.dotfiles}/$(whereami)/.local/bin/stw"; }

###########################################################################################
###########################################################################################
### --- Paste --- ###
# init
function pasteinit() {
    OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
    zle -N self-insert url-quote-magic
}


###########################################################################################
###########################################################################################
### --- Last Command Output --- ###
function insert-last-command-output() { LBUFFER+="$(eval $history[$((HISTCMD-1))])"; }


###########################################################################################
###########################################################################################
### --- Mount ecryptfs --- ###
function emt() {
    ! mount | grep -q " $1 " && echo "$(pass show encryption/ecryptfs)" | sudo mount -t ecryptfs "$1" "$2" \
        -o ecryptfs_cipher=aes,ecryptfs_key_bytes=32,ecryptfs_passthrough=no,ecryptfs_enable_filename_crypto=yes,ecryptfs_sig="$(sudo cat /root/.ecryptfs/sig-cache.txt)",ecryptfs_fnek_sig="$(sudo cat /root/.ecryptfs/sig-cache.txt)",passwd="$(pass show encryption/ecryptfs)" >/dev/null 2>&1 &&
        echo "'$2' folder is mounted!"
}


###########################################################################################
###########################################################################################
### --- Git --- ###
function gcggg() {
    choice=$(ssh "$THESIAH_GIT" "ls -a | grep -i \".*\\.git$\"" | fzf --cycle --prompt="  " --height=50% --layout=reverse --border --exit-0)
    [ -n "$choice" ] && [ -n "$1" ] && git clone "${THESIAH_GIT:-git@${THESIAH:-thesiah.xyz}}":"$choice" "$1" || [ -n "$choice" ] && git clone "${THESIAH_GIT:-git@${THESIAH:-thesiah.xyz}}":"$choice"
}

function gp() {
    branch="$(git rev-parse --abbrev-ref HEAD)"
    [[ -z "$1" ]] && {
        git push home "$branch" && echo "Pushed to home on branch $branch successfully.\n" ||
        { echo "Failed to push to home on branch $branch.\n"; return 1; }
    } || {
        git push "$1" "$branch" && echo "Pushed to $1 on branch $branch successfully.\n" ||
        { echo "Failed to push to $1 on branch $branch.\n"; return 1; }
    }
    git push && echo "Pushed to default remote successfully." ||
    { echo "Failed to push to default remote."; return 1; }
}


###########################################################################################
###########################################################################################
### --- Setxkbmap --- ###
function gkey() { grep --color -E "$1" /usr/share/X11/xkb/rules/base.lst; }


###########################################################################################
###########################################################################################
### --- Change Target Nvim --- ###
function ctn() {
    if [ $# -ne 2 ]; then
        echo "Usage: cnt <old_suffix> <new_suffix>"
        return 1
    fi

    local old_suffix="$1"
    local new_suffix="$2"
    local base_name="nvim"

    # Handle the case where the old suffix is '.'
    [ "$old_suffix" = "." ] && old_suffix=""
    [ "$new_suffix" = "." ] && new_suffix=""

    # Directories to be renamed
    local directories=(
        "$HOME/.config/$base_name"
        "$HOME/.local/share/$base_name"
        "$HOME/.local/state/$base_name"
        "$HOME/.cache/$base_name"
    )

    for dir in "${directories[@]}"; do
        if [ -d "$dir$old_suffix" ]; then
            mv "$dir$old_suffix" "$dir$new_suffix"
            echo "Renamed $dir$old_suffix to $dir$new_suffix"
        else
            echo "Directory $dir$old_suffix does not exist"
        fi
    done
}


###########################################################################################
###########################################################################################
### --- Color --- ###
function pcol() {
    awk 'BEGIN{
s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
function for (colnum = 0; colnum<77; colnum++) {
    r = 255-(colnum*255/76);
    g = (colnum*510/76);
    b = (colnum*255/76);
    if (g>255) g = 510-g;
    printf "\033[48;2;%d;%d;%dm", r,g,b;
    printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
    printf "%s\033[0m", substr(s,colnum+1,1);
}
printf "\n";
}'
}


###########################################################################################
###########################################################################################
### --- Config --- ###
function fcf() {
    [ $# -gt 0 ] && zoxide query -i "$1" | xargs "${EDITOR}" && return
    local file
    file="$(zoxide query -l | fzf --cycle -1 -0 --no-sort +m)" && nvim "${file}" || return 1
}


###########################################################################################
###########################################################################################
### --- Copy --- ###
# file
function cpf() {
    local clipboard_cmd=()
    local file
    clipboard_cmd=("xclip" "-selection" "clipboard")

    file=$(fzf --cycle --preview "cat {}")
    if [ -n "$file" ]; then
        # Use `sed` to delete only the last newline character
        cat "$file" | sed ':a;N;$!ba;s/\n$//' | "${clipboard_cmd[@]}"
    fi
}


###########################################################################################
###########################################################################################
### --- Docker --- ###
# Select a docker container to start and attach to
function doca() {
    local cid
    cid=$(docker ps -a | sed 1d | fzf --cycle -1 -q "$1" | awk '{print $1}')

    [ -n "$cid" ] && docker start "$cid" && docker attach "$cid"
}

# Select a running docker container to stop
function docs() {
    local cid
    cid=$(docker ps | sed 1d | fzf --cycle -q "$1" | awk '{print $1}')

    [ -n "$cid" ] && docker stop "$cid"
}

# Same as above, but allows multi selection:
function docrm() { docker ps -a | sed 1d | fzf --cycle -q "$1" --no-sort -m --tac | awk '{ print $1 }' | xargs -r docker rm; }

# Select a docker image or images to remove
function docrmi() { docker images | sed 1d | fzf --cycle -q "$1" --no-sort -m --tac | awk '{ print $3 }' | xargs -r docker rmi; }


###########################################################################################
###########################################################################################
### --- Goto --- ###
# files in root
function ff() { file=$(find "$HOME" -type f >/dev/null 2>&1 | fzf) && nvim "$file"; }

# files in sub
function fF() { file=$(find . -type f | fzf --cycle) && nvim "$file"; }

# directory
function fD() { cd $(find "$HOME" -type d >/dev/null 2>&1 | fzf); }

# search bin
function sscs() {
    choice="$(find ~/.local/bin -mindepth 1 \( -type f -o -type l \) -not -name '*.md' -not -path '*/zsh/*' -printf '%P\n' | fzf --cycle)"
    ([ -n "$choice" ] && [ -f "$HOME/.local/bin/$choice" ]) && $EDITOR "$HOME/.local/bin/$choice"
}

# check git directories
function fdot() {
    local search_dirs=()
    local initial_dirs=("$HOME/.dotfiles" "$HOME/.local/share/.password-store" "$HOME/.local/src/suckless")
    local git_dirs=("$HOME/Private/git" "$HOME/Public/git")

    process_and_append() {
        local dir="$1"
        git -C "$dir" fetch --quiet
        if [ -n "$(git -C "$dir" status --porcelain)" ]; then
            search_dirs+=("+ $dir")
        elif [ "$(git -C "$dir" rev-parse @)" != "$(git -C "$dir" rev-parse @{u})" ] && [ "$(git -C "$dir" rev-parse @)" = "$(git -C "$dir" merge-base @ @{u})" ]; then
            search_dirs+=("! $dir")
        else
            search_dirs+=("$dir")
        fi
    }

    # Process initial directories
    for dir in "${initial_dirs[@]}"; do
        [ -d "$dir" ] && process_and_append "$dir"
    done

    # Process git directories in parallel
    for git_dir in "${git_dirs[@]}"; do
        if [ -d "$git_dir" ]; then
            find "$git_dir" -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -I{} -P 8 zsh -c '
                git -C "$0" fetch --quiet
                if [ -n "$(git -C "$0" status --porcelain)" ]; then
                    echo "+ $0"
                elif [ "$(git -C "$0" rev-parse @)" != "$(git -C "$0" rev-parse @{u})" ] && [ "$(git -C "$0" rev-parse @)" = "$(git -C "$0" merge-base @ @{u})" ]; then
                    echo "! $0"
                else
                    echo "$0"
                fi
            ' {} | while IFS= read -r selected_git; do
                search_dirs+=("$selected_git")
            done >/dev/null 2>&1
        fi
    done

    selected_git=$(printf "%s\n" "${search_dirs[@]}" | fzf --cycle --prompt="  " --height=50% --layout=reverse --border --exit-0)
    selected_git=${selected_git#+ }
    selected_git=${selected_git#! }
    selected_git=${selected_git# }
    [ -d "$selected_git" ] && cd "$selected_git"
}


###########################################################################################
###########################################################################################
### --- help --- ###
alias bathelp='bat --plain --language=help'
function help() { "$@" --help 2>&1 | bathelp; }


###########################################################################################
###########################################################################################
### --- lf --- ###
function lfcd () {
    tmp="$(mktemp -uq)"
    trap 'rm -f $tmp >/dev/null 2>&1 && trap - HUP INT QUIT TERM PWR EXIT' HUP INT QUIT TERM PWR EXIT
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}


###########################################################################################
###########################################################################################
### --- mkcd --- ###
function mkcd() { mkdir -p "$@" && cd "$_"; }


###########################################################################################
###########################################################################################
### --- neovim --- ###
# folder
function cnf() {
	local base_dir="${XDG_DOTFILES_DIR:-$HOME/.dotfiles}/$(whereami)/.config"     # Base directory for Neovim configs
    local target_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"             # Target directory for active Neovim config
    local target_share="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"        # Neovim"s share directory
    local target_state="${XDG_STATE_HOME:-$HOME/.local/state}/nvim"       # Neovim"s state directory
    local target_cache="${XDG_CACHE_HOME:-$HOME/.cache}/nvim"             # Neovim"s cache directory

    # Explicitly list your configuration options
    local configs=("Default" "TheSiahxyz" "NvChad" "LazyVim")
    local selected_dir=$(printf "%s\n" "${configs[@]}" | fzf --cycle --prompt=" Neovim Config  " --height 50% --layout=reverse --border --exit-0)

    # Check if a configuration was selected
    [[ -z $selected_dir ]] && return 1

    # Default configuration
    if [[ $selected_dir == "Default" ]]; then
        echo "Clearing the Neovim configuration directory..."
        rm -rf "$target_dir" "$target_share" "$target_state" "$target_cache" &>/dev/null
        echo "Switched to the base Neovim configuration."
        return 0
    fi

    # Construct the full path of the selected configuration
    local config_path="$base_dir/$selected_dir"
    echo "$config_path"

    # Clear existing configurations if confirmed by the user
    echo -n "This will overwrite existing configurations. Continue? (y/n) "
    read reply
    if [[ $reply =~ ^[Yy]$ ]]; then
        echo "Clearing existing Neovim configurations..."
        rm -rf "$target_dir" "$target_share" "$target_state" "$target_cache" &>/dev/null
        mkdir -p "$target_dir" "$target_share" "$target_state" "$target_cache" &>/dev/null
    else
        echo "Operation cancelled."
        return 2
    fi

    # Copy the selected configuration to the target directories
    if [[ -d "$config_path" ]]; then
        cp -r "$config_path/." "$target_dir" > /dev/null 2>&1
        echo "Successfully applied $selected_dir configuration."
        shortcuts >/dev/null
    else
        echo "Configuration directory for $selected_dir does not exist."
        return 3
    fi

    if [ "$whereami" = "artix" ]; then
        chown -R "$USER:wheel" "/home/$USER/.config/nvim"
    fi
}

# switch
function nvs() {
    items=("Default" "TheSiahxyz" "LazyVim" "NvChad")
    config=$(printf "%s\n" "${items[@]}" | fzf --cycle --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
    [[ -z $config ]] && return 0
    NVIM_APPNAME=$config nvim $@
}


###########################################################################################
###########################################################################################
### --- Password --- ###
function pqr() { pass otp uri -q $1; }

function pqri() { pass otp insert $1; }

function pss() { pass show $(find $PASSWORD_STORE_DIR -type f -name '*.gpg' | sed 's|^''$PASSWORD_STORE_DIR/||; s/\.gpg$//' | fzf --cycle); }

function psc() { pass show -c $(find $PASSWORD_STORE_DIR -type f -name '*.gpg' | sed 's|^''$PASSWORD_STORE_DIR/||; s/\.gpg$//' | fzf --cycle); }

function gpgqr() { qrencode -o "$1".png -t png -Sv 40 < "$1".pgp; }


###########################################################################################
###########################################################################################
### --- Sudo --- ###
function __command_replace_buffer() {
    local old=$1 new=$2 space=${2:+ }
    if [[ $CURSOR -le ${#old} ]]; then
        BUFFER="${new}${space}${BUFFER#$old }"
        CURSOR=${#new}
    else
        LBUFFER="${new}${space}${LBUFFER#$old }"
    fi
}
# Main function to manipulate the command line to prepend a given command, handling special cases including editor preferences
function command_line() {
    local prepend_command=$1
    local EDITOR=${SUDO_EDITOR:-${VISUAL:-$EDITOR}}
    [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
    local WHITESPACE=""
    if [[ ${LBUFFER:0:1} = " " ]]; then
        WHITESPACE=" "
        LBUFFER="${LBUFFER:1}"
    fi
    {
        local cmd="${${(Az)BUFFER}[1]}"
        local realcmd="${${(Az)aliases[$cmd]}[1]:-$cmd}"
        local editorcmd="${${(Az)EDITOR}[1]}"
        if [[ -z "$EDITOR" ]]; then
            LBUFFER="$prepend_command $LBUFFER"
            return
        fi
        if [[ "$realcmd" = (\$EDITOR|$editorcmd|${editorcmd:c}) \
                      || "${realcmd:c}" = ($editorcmd|${editorcmd:c}) ]] \
                      || builtin which -a "$realcmd" | command grep -Fx -q "$editorcmd"; then
            __command_replace_buffer "$cmd" "$prepend_command -e"
            return
        fi
        case "$BUFFER" in
        $editorcmd\ *) __command_replace_buffer "$editorcmd" "$prepend_command -e" ;;
        \$EDITOR\ *) __command_replace_buffer '$EDITOR' "$prepend_command -e" ;;
        ${prepend_command}\ -e\ *) __command_replace_buffer "${prepend_command} -e" "$EDITOR" ;;
        ${prepend_command}\ *) __command_replace_buffer "${prepend_command}" "" ;;
        *) LBUFFER="$prepend_command $LBUFFER" ;;
        esac
    } always {
        LBUFFER="${WHITESPACE}${LBUFFER}"
        zle && zle redisplay # only run redisplay if zle is enabled
    }
}

###########################################################################################
###########################################################################################
### --- Tmux --- ###
# init
function tit() {
    ! tmux has-session -t "$TERMINAL" 2>/dev/null && tmux new-session -d -s "$TERMINAL" -c "$HOME"
    [[ -n "$TMUX" ]] && tmux switch-client -t "$TERMINAL" || tmux attach-session -t "$TERMINAL"
}

# cd session
function cds() { cd "$(tmux display-message -p '#{session_path}')"; }

# kill
function tmk() {
    local sessions
    sessions="$(tmux ls|fzf --cycle --exit-0 --multi)"  || return $?
    local i
    for i in "${(f@)sessions}"
    do
        [[ $i =~ '([^:]*):.*' ]] && {
            echo "Killing $match[1]"
            tmux kill-session -t "$match[1]"
        }
    done
}

# new or switch
function tmn() {
    [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
    if [ $1 ]; then
        tmux $change -t "$1" >/dev/null 2>&1 || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
    fi
    session=$(tmux list-sessions -F "#{session_name}" >/dev/null 2>&1 | fzf --cycle --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}

# select
function tms() {
    local session
    session=$(tmux list-sessions -F "#{session_name}" \
        | fzf --cycle --query="$1" --select-1 --exit-0) &&
    tmux switch-client -t "$session"
}


###########################################################################################
###########################################################################################
### --- Virtual Env --- ###
# Create
function createv() { python -m venv $XDG_DATA_HOME/venvs/"$1" }
# Activate
function activev() { source $XDG_DATA_HOME/venvs/"$1"/bin/activate }
# List
function listv() {
    local venvs_dir="$XDG_DATA_HOME/venvs"
    local venvs=("$venvs_dir"/*)

    if [ ${#venvs[@]} -eq 0 ]; then
        echo "No venvs"
        return 0
    fi

    echo "venvs list:"
    for venv in "${venvs[@]}"; do
        if [ -d "$venv" ]; then
            echo " 󰢔 $(basename "$venv")"
        fi
    done
}
# Delete
function deletev() {
    local env_dir="$XDG_DATA_HOME/venvs"
    local options=($(find "$env_dir" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;))
    options+=("Delete All")

    # Prompt user to select a virtual environment or choose an option to delete all
    local selected_env=$(printf "%s\n" "${options[@]}" | fzf --cycle --prompt="venvs  " --height=~50% --layout=reverse --border --exit-0)

    if [[ -z $selected_env ]]; then
        echo "No venvs selected"
        return 0
    elif [[ $selected_env == "Delete All" ]]; then
        rm -rf "$env_dir"/*
        echo "All venvs deleted"
    else
        rm -rf "$env_dir/$selected_env"
        echo "$selected_env deleted"
    fi
}
