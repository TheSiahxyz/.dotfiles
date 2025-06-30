#!/bin/zsh

###########################################################################################
###########################################################################################
### --- ALIAS --- ###
# find aliases
alias ali=fzf_aliases
function fzf_aliases() {
    local aliases=$(alias)
    local max_length=$(echo "$aliases" | cut -d'=' -f1 | awk '{print length}' | sort -nr | head -n 1)
    [ "$max_length" -gt 20 ] && max_length=20
    format_aliases() {
        echo "$aliases" | while IFS= read -r line; do
            alias_name=$(echo "$line" | cut -d'=' -f1)
            alias_command=$(echo "$line" | cut -d'=' -f2- | sed "s/^'//;s/'$//")
            printf "%-${max_length}s = %s\n" "$alias_name" "$alias_command"
        done
    }
    alias_file="${XDG_CONFIG_HOME:-${HOME}/.config}/shell/aliasrc"
    selected_alias=$(format_aliases | fzf --header="select an alias")
    # check if an alias was selected
    if [ -n "$selected_alias" ]; then
        # extract the alias name
        alias_name=$(echo "$selected_alias" | cut -d'=' -f1 | xargs)

        # get the line number from the alias file
        line_number=$(grep -n "^alias $alias_name=" "$alias_file" | cut -d':' -f1)

        # open nvim at the specified line
        if [ -n "$line_number" ]; then
            nvim "+$line_number" "$alias_file"
        else
            scripts_file="${ZDOTDIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/zsh}/7-scripts.zsh"
            line_number=$(grep -n "^alias $alias_name=" "$scripts_file" | cut -d':' -f1)
            nvim "+$line_number" "$scripts_file"
        fi
    fi
}


###########################################################################################
###########################################################################################
### --- CHEAT.SH --- ###
function cht() {
    if [ -z "$1" ]; then
        printf "Enter program name: "
        read prog
        curl cht.sh/"$prog"
    else
        curl cht.sh/"$1"
    fi
}


###########################################################################################
###########################################################################################
### --- COLOR --- ###
# print color
alias pcol=print_col
function print_col() {
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
### --- COMMAND OUTPUT --- ###
# print last command output
alias ilco=insert_last_command_output
function insert_last_command_output() { LBUFFER+="$(eval $history[$((HISTCMD-1))])"; }


###########################################################################################
###########################################################################################
### --- CONFIG --- ###
# fzf config
alias fcfg=fzf_config
function fzf_config() {
    [ $# -gt 0 ] && zoxide query -i "$1" | xargs "${EDITOR}" && return
    local file
    file="$(zoxide query -l | fzf --cycle -1 -0 --no-sort +m)" && cd "${file}" || return 1
}


###########################################################################################
###########################################################################################
### --- COPY --- ###
# copy file name to clipboard
alias cpfn=copy_filename
function copy_filename() {
    if ! command -v xclip >/dev/null; then
        echo "Error: 'xclip' is not installed." >&2
        return 1
    fi

    if ! command -v fzf >/dev/null; then
        echo "Error: 'fzf' is not installed." >&2
        return 1
    fi

    local file="$1"

    # If no argument is provided, use fzf to select a file
    if [ -z "$file" ]; then
        file=$(fzf --cycle --preview "cat {}")
    fi

    # Check if a file was found or selected
    if [ -n "$file" ]; then
        local filename=$(basename "$file")
        echo -n "$filename" | xclip -selection clipboard
        echo "Filename copied to clipboard: $filename"
    else
        echo "No file selected."
    fi
}

# copy file contents
alias cpfc=copy_contents
function copy_contents() {
    if ! command -v xclip >/dev/null; then
        echo "Error: 'xclip' is not installed." >&2
        return 1
    fi

    if ! command -v fzf >/dev/null; then
        echo "Error: 'fzf' is not installed." >&2
        return 1
    fi

    local file="$1"

    # If no argument is provided, use fzf to select a file
    if [ -z "$file" ]; then
        file=$(fzf --cycle --preview "cat {}")
    fi

    # Check if a file was found or selected
    if [ -n "$file" ]; then
        # Use `sed` to delete only the last newline character
        cat "$file" | sed ':a;N;$!ba;s/\n$//' | xclip -selection clipboard
        echo "Contents of '$file' copied to clipboard."
    else
        echo "No file selected."
    fi
}

# copy the current working directory path to the clipboard
alias cpcp=copy_current_path
function copy_current_path() {
    if command -v xclip >/dev/null; then
        printf "%s" "$PWD" | xclip -selection clipboard
        printf "%s\n" "Current working directory '$(basename "$PWD")' path copied to clipboard."
    else
        printf "%s\n" "Error: 'xclip' command not found. Please install 'xclip' to use this function."
    fi
}

# copy file real path
alias cprp=copy_real_path
function copy_real_path() {
    if ! command -v xclip >/dev/null; then
        echo "Error: 'xclip' is not installed." >&2
        return 1
    fi

    if ! command -v fzf >/dev/null; then
        echo "Error: 'fzf' is not installed." >&2
        return 1
    fi

    local file="$1"

    # If no argument is provided, use fzf to select a file
    if [ -z "$file" ]; then
        file=$(fzf --cycle --preview "cat {}")
    fi

    # Check if a file was found or selected
    if [ -n "$file" ]; then
        local full_path=$(realpath "$file")
        echo -n "$full_path" | xclip -selection clipboard
        echo "File path copied to clipboard: $full_path"
    else
        echo "No file selected."
    fi
}


###########################################################################################
###########################################################################################
### --- CREATE --- ###
# mkdir && cd
alias mc=mkcd
function mkcd() { mkdir -p "$@" && cd "$_"; }

# create dir with current date
function mkdt () { mkdir -p ${1:+$1$prefix_separator}"$(date +%F)"; }


###########################################################################################
###########################################################################################
### --- DOCKER --- ###
# select a docker container to start and attach to
alias doca=docker_container_init
function docker_container_init() {
    local cid
    cid=$(docker ps -a | sed 1d | fzf --cycle -1 -q "$1" | awk '{print $1}')

    [ -n "$cid" ] && docker start "$cid" && docker attach "$cid"
}

# select a running docker container to stop
alias docs=docker_stop
function docker_stop() {
    local cid
    cid=$(docker ps | sed 1d | fzf --cycle -q "$1" | awk '{print $1}')

    [ -n "$cid" ] && docker stop "$cid"
}

# select a docker container or containers to remove
alias docrmc=docker_remove_containers
function docker_remove_containers() { docker ps -a | sed 1d | fzf --cycle -q "$1" --no-sort -m --tac | awk '{ print $1 }' | xargs -r docker rm; }

# select a docker image or images to remove
alias docrmi=docker_remove_images
function docker_remove_images() { docker images | sed 1d | fzf --cycle -q "$1" --no-sort -m --tac | awk '{ print $3 }' | xargs -r docker rmi; }


###########################################################################################
###########################################################################################
### --- ECRYPTFS --- ###
# mount ecryptfs
alias emt=ecryptfs_mount
function ecryptfs_mount() {
    ! mount | grep -q " $1 " && echo "$(pass show encryption/ecryptfs)" | sudo mount -t ecryptfs "$1" "$2" \
        -o ecryptfs_cipher=aes,ecryptfs_key_bytes=32,ecryptfs_passthrough=no,ecryptfs_enable_filename_crypto=yes,ecryptfs_sig="$(sudo cat /root/.ecryptfs/sig-cache.txt)",ecryptfs_fnek_sig="$(sudo cat /root/.ecryptfs/sig-cache.txt)",passwd="$(pass show encryption/ecryptfs)" >/dev/null 2>&1 &&
    echo "'$2' folder is mounted!"
}


###########################################################################################
###########################################################################################
### --- GIT --- ###
# TheSiahxyz's git repos
alias gcggg=thesiahxyz_git
function thesiahxyz_git() {
    choice=$(ssh "$THESIAH_GIT" "ls -a | grep -i \".*\\.git$\"" | fzf --cycle --prompt="  " --height=50% --layout=reverse --border --exit-0)
    [ -n "$choice" ] && [ -n "$1" ] && git clone "${THESIAH_GIT:-git@${THESIAH:-thesiah.xyz}}":"$choice" "$1" ||
    [ -n "$choice" ] && git clone "${THESIAH_GIT:-git@${THESIAH:-thesiah.xyz}}":"$choice"
}


###########################################################################################
###########################################################################################
### --- GOTO --- ###
# go to the path stored in the clipboard
alias cdp=cd_clipboard_path
function cd_clipboard_path() {
    if command -v xclip >/dev/null; then
        local target_dir
        target_dir="$(xclip -o -sel clipboard)"
        if [[ -d "${target_dir}" ]]; then
            cd "${target_dir}" && printf "%s\n" "Changed directory to: ${target_dir}"
        else
            printf "%s\n" "Error: Invalid directory path or directory does not exist."
        fi
    else
        printf "%s\n" "Error: 'xclip' command not found. Please install 'xclip' to use this function."
    fi
}

# fzf directory and go to the parent directory
alias fD=fzf_directory
function fzf_directory() {
    dirs="$(find "$HOME" -type d \( -path "**/.git/*" -o -path "**/.cache/*" -o -path "**/yay/*" -o -path "$HOME/.local/bin/zsh" \) -prune -o -type d -print | fzf --multi)"
    [ -d "$dirs" ] && cd "$dirs" && ls -A || opensessions "$dirs"
}

# search scripts in ~/.local/bin
alias sscs=search_scripts
function search_scripts() {
    choice="$(find ${HOME}/.local/bin -mindepth 1 -not -path "${HOME}/.local/bin/zsh" -not -path "${HOME}/.local/bin/zsh/*" -printf '%P\n' | fzf)"
    [ -f "$HOME/.local/bin/$choice" ] && $EDITOR "$HOME/.local/bin/$choice"
}

# check git status by directories in specific path
alias fgst=fetch_git_repos_status
function fetch_git_repos_status() {
    SELECTED_DIRS=$(bash << 'EOF'
        # Source the Git prompt script to get access to __git_ps1
        source /usr/share/git/completion/git-prompt.sh

        # Enable symbols for dirty state, untracked files, and branch ahead/behind
        export GIT_PS1_SHOWDIRTYSTATE="auto"
        export GIT_PS1_SHOWUNTRACKEDFILES="auto"
        export GIT_PS1_SHOWUPSTREAM="auto"

        # Define an array of target directories
        TARGET_DIRECTORIES=(
            "$HOME/.dotfiles"
            "$HOME/.local/share/.password-store"
            "$HOME/.local/src/suckless"
        )

        # Check the directories under the paths. eg. ../repos/*
        GIT_DIRS=("$HOME/Private/repos" "$HOME/Public/repos")

        # Append all subdirectories under GIT_DIRS that are Git repositories
        for GIT_DIR in "${GIT_DIRS[@]}"; do
            if [ -d "$GIT_DIR" ]; then
                for SUBDIR in "$GIT_DIR"/*; do
                    if [ -d "$SUBDIR/.git" ]; then
                        TARGET_DIRECTORIES+=("$SUBDIR")
                    fi
                done
            fi
        done

        # Create an array to store the output
        OUTPUT=()

        # Function to colorize only the Git status symbols
        colorize_git_status() {
            local status="$1"
            # Colorize the entire status with a single color
            echo -e "\033[33m${status}\033[0m"  # Apply yellow color to the status
        }

        update_time() {
            timestamp_file="${HOME}/.cache/gitreposupdate"
            current_time=$(date +%s)
            if [[ -f "$timestamp_file" ]] && (($(cat "$timestamp_file") > (current_time - 86400))); then
                return 1 # No update needed
            else
                echo "$current_time" >"$timestamp_file"
                return 0 # Update needed
            fi
        }
        update_time && update=true || update=false

        # Loop through each directory and get the Git status
        for DIR in "${TARGET_DIRECTORIES[@]}"; do
            if [ -d "$DIR/.git" ]; then
                cd "$DIR" || continue

                if $update; then
                    if [ "$(dirname $DIR)" = ".password-store" ]; then
                        pass git fetch >/dev/null 2>&1
                    else
                        git fetch --all --prune --jobs=10 >/dev/null 2>&1
                    fi
                fi

                # Get Git branch and status using __git_ps1
                GIT_STATUS=$(__git_ps1 "%s")

                # Colorize the Git status
                COLORED_GIT_STATUS=$(colorize_git_status "$GIT_STATUS")

                # Add formatted output with colored Git status and directory
                OUTPUT+=("$(printf "%-20s %s" "$COLORED_GIT_STATUS" "$DIR")")
            fi
        done

        # Pass the output to fzf with multi-select enabled (-m)
        SELECTED=$(printf "%s\n" "${OUTPUT[@]}" | fzf -m --ansi --layout=reverse)

        # Filter out lines that do not end with a valid directory path and are not empty
        echo "$SELECTED" | awk '{if (NF > 1 && system("[ -d \""$NF"\" ]") == 0) print $NF}'
EOF
    )
    [[ -z "${SELECTED_DIRS// }" ]] && return
    if [[ "$(echo "$SELECTED_DIRS" | wc -l)" -eq 1 ]]; then
        cd "$SELECTED_DIRS"
        if  [[ -n "$(git -C "$SELECTED_DIRS" status --porcelain)" ]]; then
            git status --porcelain 2>/dev/null
        fi
    else
        opensessions "$SELECTED_DIRS"
    fi
}


###########################################################################################
###########################################################################################
### --- HELP --- ###
# help opt colored by bat
alias bathelp='bat --plain --language=help'
function help() { "$@" --help 2>&1 | bathelp; }


###########################################################################################
###########################################################################################
### --- KEYS --- ###
# list setxkbmap options
alias xkey=xset_options
function xset_options() { grep --color -E "$1" /usr/share/X11/xkb/rules/base.lst; }

# print raw xev key events
alias keys=xev_raw_key_event
function xev_raw_key_event() {
    xev -event keyboard | awk '
    /^KeyPress/,/^KeyRelease/ {
        if ($0 ~ /keysym/) print $0
    }'
}

# print aligned xev key events
alias key=xev_aligned_key_event
function xev_aligned_key_event() {
    xev -event keyboard | awk '
    /^(KeyPress|KeyRelease)/ {
        event_type = $1
    }
    /keysym/ {
        gsub(/\),$/, "", $7)
        printf "%-12s %-3s %s\n", event_type, $4, $7
    }'
}


###########################################################################################
###########################################################################################
### --- KILL --- ###
# kill process
alias fpkill=fzf_kill_process
function fzf_kill_process() {
    ps aux | grep -e "^$(whoami)" |
    fzf --height 40% \
        --layout=reverse \
        --header-lines=1 \
        --prompt="Select process to kill: " \
        --preview 'echo {}' \
        --preview-window up:3:hidden:wrap \
        --bind 'F2:toggle-preview' |
    awk '{print $2}' |
    xargs -r bash -c '
        if ! kill -9 "$1" 2>/dev/null; then
            echo "Regular kill failed. Attempting with sudo..."
            sudo kill -9 "$1" || echo "Failed to kill process $1" >&2
        fi
    ' --
}


###########################################################################################
###########################################################################################
### --- LF --- ###
# open lf and cd to the file path
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
### --- MAN --- ###
# color man page
function van() {
    if [[ -z "$@" ]]; then
        if command -v fzf >/dev/null 2>&1; then
            local page=$(command man -k . | fzf --prompt='Man> ' --exit-0 | awk '{print $1}')
            if [[ -n $page ]]; then
                nvim +"Man $page | only"
            fi
        fi
    else
        nvim +"Man $@ | only"
    fi
}
function ban() {
    BAT_THEME="ansi" command batman "$@"
    return $?
}


###########################################################################################
###########################################################################################
### --- NVIM --- ###
# rename nvim directory
alias ctn=rename_nvim_dir
function rename_nvim_dir() {
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

# change nvim config
alias cnf=change_nvim_config_dir
function change_nvim_config_dir() {
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
alias vtc=nvim_target_config
function nvim_target_config() {
    items=("Default" "TheSiahxyz" "LazyVim" "NvChad")
    config=$(printf "%s\n" "${items[@]}" | fzf --cycle --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
    [[ -z $config ]] && return 0
    NVIM_APPNAME=$config nvim $@
}


###########################################################################################
###########################################################################################
### --- PASS --- ###
# otp
function pass_otp() { pass otp uri -q $1; }

# otp insert
function pass_otp_insert() { pass otp insert $1; }

# copy pass qr code
alias cpqr=pass_qr
function pass_qr() { qrencode -o "$1".png -t png -Sv 40 < "$1".pgp; }


###########################################################################################
###########################################################################################
### --- PASTE --- ###
if ls "${ZPLUGINDIR:-${XDG_SCRIPTS_HOME:-${HOME}/.local/bin}/zsh}/zsh-autosuggestions" >/dev/null 2>&1; then
    autoload -Uz url-quote-magic
    function pasteinit() {
        OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
        zle -N self-insert url-quote-magic
    }
    function pastefinish() {
        zle -N self-insert $OLD_SELF_INSERT
    }
    zstyle :bracketed-paste-magic paste-init pasteinit
    zstyle :bracketed-paste-magic paste-finish pastefinish
fi


###########################################################################################
###########################################################################################
### --- SDCV --- ###
function def() {
    sdcv -n --utf8-output --color "$@" 2>&1 | \
        fold --width=$(tput cols) | \
        less --quit-if-one-screen -RX
}


###########################################################################################
###########################################################################################
### --- STOW --- ###
# run stow script from dotfiles repo
alias dstw=dotfeils_stw
function dotfiles_stw() { "${XDG_DOTFILES_DIR:-${HOME}/.dotfiles}/$(whereami)/.local/bin/stw"; }


###########################################################################################
###########################################################################################
### --- SUDO --- ###
# insert prefix at the beginning of the previous command
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
function pre_cmd() {
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
### --- TMUX --- ###
# tmux init
alias tit=tmux_init
function tmux_init() {
    ! tmux has-session -t "$TERMINAL" 2>/dev/null && tmux new-session -d -s "$TERMINAL" -c "$HOME"
    [[ -n "$TMUX" ]] && tmux switch-client -t "$TERMINAL" || tmux attach-session -t "$TERMINAL"
}

# cd tmux session
alias cds=cd_session_path
function cd_session_path() { cd "$(tmux display-message -p '#{session_path}')"; }

# kill tmux session
alias tmk='kill_tmux_sessions'
function kill_tmux_sessions() {
    local sessions
    sessions="$(tmux ls | fzf --cycle --exit-0 --multi)"  || return $?
    local i
    for i in "${(f@)sessions}"
    do
        [[ $i =~ '([^:]*):.*' ]] && {
            echo "Killing $match[1]"
            tmux kill-session -t "$match[1]"
        }
    done
}

# switch tmux session
alias tms='switch_tmux_session'
function switch_tmux_session() {
    local session
    session=$(tmux list-sessions -F "#{session_name}" \
        | fzf --cycle --query="$1" --select-1 --exit-0) &&
    tmux switch-client -t "$session"
}


###########################################################################################
###########################################################################################
### --- VIRTUAL ENV --- ###
# create venvs
alias createv=create_venv
function create_venv() {
    local env_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/venvs/${1:-venv}"
    local requirements_path="${XDG_DATA_HOME:-${HOME}/.local/share}/venvs"

    # Check if the environment already exists
    # Create the virtual environment
    echo "Creating new virtual environment in '$env_dir'..."
    python3 -m venv $env_dir

    # Activate the virtual environment
    source $env_dir/bin/activate

    # Optional: Install any default packages
    pip3 install --upgrade pip >/dev/null 2>&1

    if [ -f "$requirements_path/default-requirements.txt" ]; then
        echo "Installing packages from '$requirements_path/default-requirements.txt'..."
        pip3 install -r "$requirements_path/default-requirements.txt" >/dev/null 2>&1
    fi

    if [ -f "$requirements_path/captured-requirements.txt" ]; then
        echo "Installing packages from '$requirements_path/captured-requirements.txt'..."
        pip3 install -r "$requirements_path/captured-requirements.txt" >/dev/null 2>&1
    fi

    echo "Virtual environment '${1:-venv}' created and activated!"
}

# activate or switch venvs
alias actv=active_venv
function active_venv() {
    local venv="$1"
    if [[ -z "$venv" ]]; then
        venv=$(find "$XDG_DATA_HOME/venvs" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | fzf)
    fi
    source "$XDG_DATA_HOME/venvs/$venv/bin/activate"
    python -m ensurepip --upgrade >/dev/null 2>&1
    python -m pip install --upgrade pip >/dev/null 2>&1
    jupyter kernel --kernel=$venv
}

# list venvs
alias listv=list_venv
function list_venv() {
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
alias deactv=deactive_venv
function deactive_venv() {
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        if [[ ! -f "${XDG_DATA_HOME:-${HOME}/.local/share}/venvs/requirements.txt" ]]; then
            pip3 freeze > "${XDG_DATA_HOME:-${HOME}/.local/share}/venvs/captured-requirements.txt"
        fi
        deactivate
        echo "Virtual environment deactivated and all installed packages captured"
    else
        echo "No virtual environment is active."
    fi
}

# delete venv
alias delv=delete_venv
function delete_venv() {
    local venv="$1"
    local env_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/venvs"

    if [[ -z $venv ]]; then
        local options=($(find "$env_dir" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;))
        options+=("Delete All")

        # Prompt user to select virtual environments or choose to delete all
        local selected_envs=$(printf "%s\n" "${options[@]}" | fzf --cycle --prompt="venvs  " --height=~50% --layout=reverse --border --multi --exit-0)

        if [[ -z $selected_envs ]]; then
            echo "No venvs selected"
            return 0
        elif [[ $selected_envs == *"Delete All"* ]]; then
            rm -rf "$env_dir"/*
            echo "All venvs deleted"
        else
            # Loop through selected environments and delete each
            local env
            while IFS= read -r env; do
                rm -rf "$env_dir/$env"
                echo "$env deleted"
            done <<< "$selected_envs"
        fi
    else
        rm -rf "$env_dir/$venv"
        echo "$venv deleted"
    fi
}
