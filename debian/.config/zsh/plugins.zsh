#!/bin/zsh

### --- Plugins --- ###
plugins=(
    "Aloxaf/fzf-tab"
    "kutsan/zsh-system-clipboard"
    "MichaelAquilina/zsh-you-should-use"
    # "marlonrichert/zsh-autocomplete"
    "ohmyzsh/command-not-found"
    #"ohmyzsh/sudo"
    # "romkatv/powerlevel10k"
    "wfxr/forgit"
    "zdharma-continuum/fast-syntax-highlighting"
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-completions"
)

### --- Source Plugins --- ###
# Check plugins
zsh_check_plugins() {
    installed="true"
    for plugin in "${plugins[@]}"; do
        PLUGIN_NAME=$(echo "$plugin" | cut -d '/' -f 2)
        PLUGIN_PATH="$ZPLUGINDIR/$PLUGIN_NAME"
        [ -d "$PLUGIN_PATH" ] && zsh_source_plugin "$PLUGIN_NAME/$PLUGIN_NAME" || { installed="false"; break; }
    done
    [ "$installed" = "true" ] || zsh_add_plugins "${plugins[@]}"
}

# Function to source plugin files
zsh_source_plugin() {
    for file in "$@"; do
        [ -f "$ZPLUGINDIR/$file.plugin.zsh" ] && . "$ZPLUGINDIR/$file.plugin.zsh"
        [ -f "$ZPLUGINDIR/$file.zsh" ] && . "$ZPLUGINDIR/$file.zsh"
        [ -f "$ZPLUGINDIR/$file.zsh-theme" ] && . "$ZPLUGINDIR/$file.zsh-theme" && . "${XDG_CONFIG_HOME:-${HOME}/.config}/shell/p10k"
    done
}

# Function to add plugins
zsh_add_plugins() {
    for plugin do
        PLUGIN_NAME=$(echo "$plugin" | cut -d '/' -f 2)
        PLUGIN_PATH="$ZPLUGINDIR/$PLUGIN_NAME"

        if [ -d "$PLUGIN_PATH" ]; then
            zsh_source_plugin "$PLUGIN_NAME/$PLUGIN_NAME"
        else
            ORG_NAME=$(echo "$plugin" | cut -d '/' -f 1)
            case "$ORG_NAME" in
                "ohmyzsh")
                    [ ! -d "$ZPLUGINDIR/oh-my-zsh" ] && git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZPLUGINDIR/oh-my-zsh" >/dev/null 2>&1

                    OHMYZSH_PLUGIN_PATH="$ZPLUGINDIR/oh-my-zsh/plugins/$PLUGIN_NAME"
                    cp -r "$OHMYZSH_PLUGIN_PATH" "$ZPLUGINDIR/" >/dev/null 2>&1
                    rm -rf "$ZPLUGINDIR/oh-my-zsh" >/dev/null 2>&1
                    ;;
                *)
                    git clone "https://github.com/$plugin.git" "$PLUGIN_PATH" >/dev/null 2>&1
                    ;;
            esac
            chmod +x "$PLUGIN_PATH"
        fi
    done
}

# Function to update plugins
zsh_update_plugins() {
    ZPLUGINDIR="$HOME/.local/share/zsh"
    ACTIVE_PLUGINS=$(grep '^[[:space:]]*"[^"]\+"' ~/.config/zsh/plugins.zsh | sed 's|.*/\([^/"]*\)".*|\1|')

    for PLUGIN_DIR in "$ZPLUGINDIR"/*; do
        if [ -d "$PLUGIN_DIR" ]; then
            PLUGIN_NAME=$(basename "$PLUGIN_DIR")

            echo "$ACTIVE_PLUGINS" | grep -q "$PLUGIN_NAME" || {
                echo "Removing unused plugin: $PLUGIN_NAME"
                rm -rf "$PLUGIN_DIR"
            }
        fi
    done
}

zsh_check_plugins "${plugins[@]}"
zsh_update_plugins
