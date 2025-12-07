#!/bin/bash

# --- Packages (bash version) ---
declare -A packages=(
  [zoxide]="--cmd cd --hook prompt"
)

eval_packages() {
  local package output
  for package in "${!packages[@]}"; do
    if command -v "$package" >/dev/null 2>&1; then
      # split args by space into array (preserve empty => zero args)
      local -a args=()
      if [[ -n "${packages[$package]}" ]]; then
        # Use builtin read to split on spaces (simple split)
        IFS=' ' read -r -a args <<<"${packages[$package]}"
      fi

      # Prefer initializing for bash (change to "zsh" if you really want zsh-init)
      if ((${#args[@]})); then
        output="$("$package" init bash "${args[@]}" 2>/dev/null)"
      else
        output="$("$package" init bash 2>/dev/null)"
      fi

      # If the command produced output, evaluate it in current shell
      if [[ -n "$output" ]]; then
        eval "$output"
      fi
    fi
  done
}

# run initialization
eval_packages
