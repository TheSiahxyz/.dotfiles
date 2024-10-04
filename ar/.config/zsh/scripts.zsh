#!/bin/zsh

###########################################################################################
###########################################################################################
### --- Stow --- ###
# run stow script from dotfiles repo
function dstw() { "${XDG_DOTFILES_DIR:-${HOME}/.dotfiles}/$(whereami)/.local/bin/stw"; }

###########################################################################################
###########################################################################################
### --- Paste --- ###
# paste init
function pasteinit() {
    OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
    zle -N self-insert url-quote-magic
}


###########################################################################################
###########################################################################################
### --- Last Command Output --- ###
# print last command output
function ilco() { LBUFFER+="$(eval $history[$((HISTCMD-1))])"; }


###########################################################################################
###########################################################################################
### --- Ecryptfs --- ###
# mount ecryptfs
function emt() {
    ! mount | grep -q " $1 " && echo "$(pass show encryption/ecryptfs)" | sudo mount -t ecryptfs "$1" "$2" \
        -o ecryptfs_cipher=aes,ecryptfs_key_bytes=32,ecryptfs_passthrough=no,ecryptfs_enable_filename_crypto=yes,ecryptfs_sig="$(sudo cat /root/.ecryptfs/sig-cache.txt)",ecryptfs_fnek_sig="$(sudo cat /root/.ecryptfs/sig-cache.txt)",passwd="$(pass show encryption/ecryptfs)" >/dev/null 2>&1 &&
    echo "'$2' folder is mounted!"
}


###########################################################################################
###########################################################################################
### --- Git --- ###
# TheSiahxyz's git repos
function gcggg() {
    choice=$(ssh "$THESIAH_GIT" "ls -a | grep -i \".*\\.git$\"" | fzf --cycle --prompt="  " --height=50% --layout=reverse --border --exit-0)
    [ -n "$choice" ] && [ -n "$1" ] && git clone "${THESIAH_GIT:-git@${THESIAH:-thesiah.xyz}}":"$choice" "$1" || [ -n "$choice" ] && git clone "${THESIAH_GIT:-git@${THESIAH:-thesiah.xyz}}":"$choice"
}

# git push origin/home master
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
# list setxkbmap options
function gkey() { grep --color -E "$1" /usr/share/X11/xkb/rules/base.lst; }


###########################################################################################
###########################################################################################
### --- Change Target Nvim --- ###
# rename nvim directory
function ctn() {
    if [ $# -ne 2 ]; then
        echo "Usage: ctn <old_suffix> <new_suffix>"
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
# print color
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
# fzf config
function fcf() {
    [ $# -gt 0 ] && zoxide query -i "$1" | xargs "${EDITOR}" && return
    local file
    file="$(zoxide query -l | fzf --cycle -1 -0 --no-sort +m)" && nvim "${file}" || return 1
}


###########################################################################################
###########################################################################################
### --- Copy --- ###
# copy file contents
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
# select a docker container to start and attach to
function doca() {
    local cid
    cid=$(docker ps -a | sed 1d | fzf --cycle -1 -q "$1" | awk '{print $1}')

    [ -n "$cid" ] && docker start "$cid" && docker attach "$cid"
}

# select a running docker container to stop
function docs() {
    local cid
    cid=$(docker ps | sed 1d | fzf --cycle -q "$1" | awk '{print $1}')

    [ -n "$cid" ] && docker stop "$cid"
}

# multi docker selection:
function docrm() { docker ps -a | sed 1d | fzf --cycle -q "$1" --no-sort -m --tac | awk '{ print $1 }' | xargs -r docker rm; }

# select a docker image or images to remove
function docrmi() { docker images | sed 1d | fzf --cycle -q "$1" --no-sort -m --tac | awk '{ print $3 }' | xargs -r docker rmi; }


###########################################################################################
###########################################################################################
### --- Goto --- ###
# fzf files in root
function ff() { file=$(find "$HOME" -type f >/dev/null 2>&1 | fzf) && nvim "$file"; }

# fzf directory
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
    local git_dirs=("$HOME/Private/repos" "$HOME/Public/repos")

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

    # process initial directories
    for dir in "${initial_dirs[@]}"; do
        [ -d "$dir" ] && process_and_append "$dir"
    done

    # process git directories in parallel
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
# help colored by bat
function help() { "$@" --help 2>&1 | bathelp; }


###########################################################################################
###########################################################################################
### --- lf --- ###
# lfcd
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
# mkdir && cd
function mkcd() { mkdir -p "$@" && cd "$_"; }


###########################################################################################
###########################################################################################
### --- neovim --- ###
# change nvim config
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

# run nvim with target config
function nvs() {
    items=("Default" "TheSiahxyz" "LazyVim" "NvChad")
    config=$(printf "%s\n" "${items[@]}" | fzf --cycle --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
    [[ -z $config ]] && return 0
    NVIM_APPNAME=$config nvim $@
}


###########################################################################################
###########################################################################################
### --- Password --- ###
# opt
function pqr() { pass otp uri -q $1; }

# opt insert
function pqri() { pass otp insert $1; }

# fzf pass
function pss() { pass show $(find $PASSWORD_STORE_DIR -type f -name '*.gpg' | sed 's|^''$PASSWORD_STORE_DIR/||; s/\.gpg$//' | fzf --cycle); }

# fzf pass and copy
function psc() { pass show -c $(find $PASSWORD_STORE_DIR -type f -name '*.gpg' | sed 's|^''$PASSWORD_STORE_DIR/||; s/\.gpg$//' | fzf --cycle); }

# qr code pass
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

# manipulate the previous command line
function precmd() {
    local prepend_command=$1
    local EDITOR=${SUDO_EDITOR:-${VISUAL:-$EDITOR}}
    [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
    local WHITESPACE=""

    # Remove leading whitespace and store it for later restoration
    if [[ ${LBUFFER:0:1} = " " ]]; then
        WHITESPACE=" "
        LBUFFER="${LBUFFER:1}"
    fi

    # Main logic block
    {
        local cmd="${${(Az)BUFFER}[1]}"
        local realcmd="${${(Az)aliases[$cmd]}[1]:-$cmd}"
        local editorcmd="${${(Az)EDITOR}[1]}"
        # Check if EDITOR is set, otherwise prepend the command and return
        if [[ -z "$EDITOR" ]]; then
            LBUFFER="$prepend_command $LBUFFER"
            return
        fi
        # Check if the command is an editor command
        is_editor_cmd=false
        # Check if realcmd matches EDITOR, editorcmd, or their case variations
        [[ "$realcmd" = (\$EDITOR|$editorcmd|${editorcmd:c}) || "${realcmd:c}" = ($editorcmd|${editorcmd:c}) ]] && is_editor_cmd=true
        # Check if the real command's executable path matches the editor command
        builtin which -a "$realcmd" | command grep -Fx -q "$editorcmd" && is_editor_cmd=true
        # Execute the command replacement if it's an editor command
        if $is_editor_cmd; then
            __command_replace_buffer "$cmd" "$prepend_command -e"
            return
        fi
        # Handle various command patterns in BUFFER
        case "$BUFFER" in
            $editorcmd\ *) __command_replace_buffer "$editorcmd" "$prepend_command -e" ;;
            \$EDITOR\ *) __command_replace_buffer '$EDITOR' "$prepend_command -e" ;;
            ${prepend_command}\ -e\ *) __command_replace_buffer "${prepend_command} -e" "$EDITOR" ;;
            ${prepend_command}\ *) __command_replace_buffer "${prepend_command}" "" ;;
            *) LBUFFER="$prepend_command $LBUFFER" ;;
        esac
        } always {
        # Cleanup code: restore leading whitespace and update the command line
        LBUFFER="${WHITESPACE}${LBUFFER}"
        zle && zle redisplay # Only run redisplay if zle is enabled
    }
}


###########################################################################################
###########################################################################################
### --- Tmux --- ###
# tmux init
function tit() {
    ! tmux has-session -t "$TERMINAL" 2>/dev/null && tmux new-session -d -s "$TERMINAL" -c "$HOME"
    [[ -n "$TMUX" ]] && tmux switch-client -t "$TERMINAL" || tmux attach-session -t "$TERMINAL"
}

# cd tmux session
function cds() { cd "$(tmux display-message -p '#{session_path}')"; }

# kill tmux session
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

# new or switch tmux
function tmn() {
    [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
    if [ $1 ]; then
        tmux $change -t "$1" >/dev/null 2>&1 || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
    fi
    session=$(tmux list-sessions -F "#{session_name}" >/dev/null 2>&1 | fzf --cycle --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}

# select tmux session
function tms() {
    local session
    session=$(tmux list-sessions -F "#{session_name}" \
        | fzf --cycle --query="$1" --select-1 --exit-0) &&
    tmux switch-client -t "$session"
}


###########################################################################################
###########################################################################################
### --- Virtual Env --- ###
# create venvs
function createv() {
    local env_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/venvs/${1:-venv}"
    local requirements_path="${XDG_DATA_HOME:-${HOME}/.local/share}/venvs/captured-requirements.txt"
    # Check if the environment already exists
    # Create the virtual environment
    echo "Creating new virtual environment '$env_dir'..."
    python3 -m venv $env_dir

    # Activate the virtual environment
    source $env_dir/bin/activate

    # Optional: Install any default packages
    pip3 install --upgrade pip
    pip3 install wheel

    if [ -f "$requirements_path" ]; then
        echo "Installing packages from '$requirements_path'..."
        pip3 install -r "$requirements_path"
    fi

    echo "Virtual environment '$env_dir' created and activated!"
}

# activate or switch venvs
function actv() {
    local venv="$1"
    if [[ -z "$venv" ]]; then
        venv=$(find "$XDG_DATA_HOME/venvs" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | fzf)
    fi
    source "$XDG_DATA_HOME/venvs/$venv/bin/activate"
}

# list venvs
function listv() {
    local venvs_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/venvs"
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

# deactivate venv
function deactv() {
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        if [[ ! -f "${XDG_DATA_HOME:-${HOME}/.local/share}/venvs/requirements.txt" ]]; then
            pip3 freeze > "${XDG_DATA_HOME:-${HOME}/.local/share}/venvs/captured-requirements.txt}"
        fi
        deactivate
        echo "Virtual environment deactivated and all installed packages captured"
    else
        echo "No virtual environment is active."
    fi
}

# delete venv
function delv() {
    local env_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/venvs"
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
