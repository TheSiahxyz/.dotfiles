#!/bin/zsh

### --- Packages --- ###
typeset -A packages
packages=(
    atuin ""
    zoxide "--cmd cd"
)

### --- Eval Function --- ###
eval_packages() {
    for package in ${(k)packages}; do
        if command -v "$package" >/dev/null; then
            local args=(${(s: :)packages[$package]})
            if [[ ${#args[@]} -gt 0 ]]; then
                eval "$($package init zsh ${args[@]})"
            else
                eval "$($package init zsh)"
            fi
        fi
    done
}

### --- Init --- ###
eval_packages
