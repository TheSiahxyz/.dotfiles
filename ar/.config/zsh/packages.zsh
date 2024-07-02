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
            [[ ${#args[@]} -gt 0 ]] && eval "$($package init zsh ${args[@]})" || eval "$($package init zsh)"
        fi
    done
}

### --- Init --- ###
eval_packages
