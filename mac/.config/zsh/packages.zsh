#!/bin/zsh

### --- Packages --- ###
# Value format: "<subcmd> [args...]"
# Most tools use `init` (zoxide/atuin/batman/...); some use `hook` (direnv),
# `activate` (mise), `env` (fnm), etc. — encode it per-package.
typeset -A packages
packages=(
    atuin "init --disable-up-arrow"
    batman "init --export-env"
    direnv "hook"
    zoxide "init --cmd cd --hook prompt"
    tmuxdbussync "init"
)

### --- Eval Function --- ###
eval_packages() {
    for package in ${(k)packages}; do
        if command -v "$package" >/dev/null; then
            local parts=(${(s: :)packages[$package]})
            (( ${#parts[@]} > 0 )) || continue
            local subcmd=${parts[1]}
            local args=(${parts[2,-1]})
            eval "$($package $subcmd zsh ${args[@]})"
        fi
    done
}

### --- Init --- ###
eval_packages
