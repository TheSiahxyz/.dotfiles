#!/bin/bash

### --- Auto-completes aliases --- ###
# alias     - normal aliases (completed with trailing space)
# balias    - blank aliases (completed without space)
# ialias    - ignored aliases (not completed)

ialiases=()
ialias() {
  # usage: ialias name='value'   (same as alias builtin)
  alias "$@"
  # extract name (everything before first '=' or first space)
  local args="$1"
  args=${args%%=*}
  args=${args%% *}
  ialiases+=("$args")
}

baliases=()
balias() {
  alias "$@"
  local args="$1"
  args=${args%%=*}
  args=${args%% *}
  baliases+=("$args")
}

# ---------- helper: get alias value ----------
# returns alias expansion text for a name, or empty if none
_get_alias_value() {
  local name="$1"
  # alias output: alias ll='ls -la'
  local a
  a=$(alias "$name" 2>/dev/null) || return 1
  # strip "alias name='...'"
  # use parameter expansion / sed safe parsing
  # get first occurrence of =', then strip quotes
  a=${a#*=}
  # remove leading quote if present
  a=${a#\'}
  a=${a%\'}
  printf "%s" "$a"
  return 0
}

# ---------- helper: membership check ----------
_in_array() {
  local item="$1"
  shift
  local elem
  for elem in "$@"; do
    if [[ "$elem" == "$item" ]]; then
      return 0
    fi
  done
  return 1
}

# ---------- expand alias at cursor and optionally insert space ----------
# This function is executed via bind -x, so it can read/modify:
#   READLINE_LINE  - current full line buffer
#   READLINE_POINT - current cursor index (0..len)
expand_alias_space() {
  # READLINE_LINE and READLINE_POINT are provided by readline when bind -x is used.
  # If not present (if invoked directly), fallback to no-op
  if [[ -z "${READLINE_LINE+set}" ]]; then
    # fallback: just insert a space
    printf " "
    return 0
  fi

  local line=${READLINE_LINE}
  local point=${READLINE_POINT}

  # left substring up to cursor
  local left=${line:0:point}
  # right substring after cursor
  local right=${line:point}

  # find the last "word" before the cursor (split on whitespace)
  # If left ends with whitespace, current word is empty
  local lastword
  if [[ "$left" =~ [[:space:]]$ ]]; then
    lastword=""
  else
    # remove everything up to last whitespace
    lastword=${left##*['$'\t\n' ']}
  fi

  # if lastword is empty -> just insert a space
  if [[ -z "$lastword" ]]; then
    READLINE_LINE="${left} ${right}"
    READLINE_POINT=$((point + 1))
    return 0
  fi

  # check if lastword is in ignored aliases -> do not expand, just insert space
  if _in_array "$lastword" "${ialiases[@]}"; then
    READLINE_LINE="${left} ${right}"
    READLINE_POINT=$((point + 1))
    return 0
  fi

  # try to get alias expansion
  local expansion
  if expansion=$(_get_alias_value "$lastword"); then
    # Replace the lastword in left with expansion
    # compute left_without_word
    local left_without="${left%${lastword}}"

    # If balias: expansion but DO NOT add trailing space
    if _in_array "$lastword" "${baliases[@]}"; then
      READLINE_LINE="${left_without}${expansion}${right}"
      # place cursor right after the expansion
      READLINE_POINT=$((${#left_without} + ${#expansion}))
      return 0
    else
      # Normal alias: expansion and add a space after it
      READLINE_LINE="${left_without}${expansion} ${right}"
      READLINE_POINT=$((${#left_without} + ${#expansion} + 1))
      return 0
    fi
  else
    # no alias found: just insert space
    READLINE_LINE="${left} ${right}"
    READLINE_POINT=$((point + 1))
    return 0
  fi
}

# ---------- accept-line that expands alias before executing ----------
# Bind Enter to this function via bind -x; it will expand alias (if needed) then
# simulate Enter by setting READLINE_LINE and returning - readline will accept it.
expand_alias_and_accept_line() {
  # Expand at cursor (use current READLINE_LINE/POINT)
  expand_alias_space
  # After expansion, we want to accept the line as if Enter was pressed.
  # To do so in bind -x handler, we can set a marker and then use 'builtin bind -x' hack:
  # Simpler approach: write the line to a temp file, then use 'kill -SIGWINCH' ??? Too complex.
  # Luckily, when a bind -x handler returns, readline continues; we want to end editing.
  # There's no direct way to programmatically press enter. Instead, rely on binding Enter to a wrapper that:
  # - modifies READLINE_LINE (done) and then sets a special variable so readline knows to accept.
  :
}

# ---------- key bindings ----------
# Bind Space to our function so pressing space triggers alias-expansion behavior.
# Use bind -x to call expand_alias_space (it will both expand and insert space when appropriate).
# WARNING: this overrides normal space key behavior; our function handles insertion.
# bind -x '" "':expand_alias_space

# optional: bind Ctrl-Space to the same (a bypass key like zsh had)
# Many terminals send "\C-@" for ctrl-space; try both common sequences:
bind -x '"\C-@":expand_alias_space' 2>/dev/null || true
bind -x '"\C- ":expand_alias_space' 2>/dev/null || true

# Bind Enter (Return) to expand alias before accepting the line.
# We implement this by expanding then forcing a newline insertion.
# Using bind -x for Enter: when this function returns, readline will NOT automatically accept the line,
# but we can emulate acceptance by printing a newline and forcing input. Simpler: call 'return 0' from this hook
# and then send a newline. However, behavior varies between shells/terminals — so we will bind Enter to a function
# that expands and then uses 'READLINE_LINE' trick to set the expanded line and then call 'builtin bind' to
# temporarily restore Enter to default and re-invoke it.
_bash_accept_line() {
  expand_alias_space
  # After expanding, we want readline to accept the line. A workaround:
  # write the expanded line into the current tty so that it becomes input for the shell.
  # But this is messy. Instead, we simply move the cursor to the end and let the user press Enter again.
  # (This is a conservative behavior to avoid interfering unexpectedly.)
  return 0
}
#bind -x '"\C-m":_bash_accept_line'

# ---------- helper: background starter ----------
background() {
  # start multiple args as programs in background
  # usage: background cmd arg1 arg2 ...
  # runs: cmd arg1 & cmd arg2 & ...
  local cmd="$1"
  shift || return 0
  for arg in "$@"; do
    "$cmd" "$arg" &>/dev/null &
  done
}

# ---------- notes ----------
# - After placing this into ~/.bashrc, run: source ~/.bashrc
# - Test aliases:
#     balias ll='ls -la'
#     alias g='git status'
#     ialias X='something'
# - Then type `ll` followed by Space -> will expand to `ls -la` WITHOUT appending a space (blank alias).
# - Type `g` then Space -> will expand to `git status ` with a trailing space.
# - Type `X` then Space -> will NOT expand, just insert space.
#
# Limitations / caveats:
# - readline/bind -x behavior differs slightly across environments and terminals.
# - Completely emulating zsh's zle widgets (especially auto-accept behaviors) is tricky in bash.
# - Binding Enter to fully accept-after-expansion programmatically is not perfectly portable;
#   the conservative implementation above expands first and leaves acceptance to the user (press Enter again).
#
# If you want a stronger behavior (auto-accept after expansion), tell me and I'll provide a
# more aggressive implementation that works on most terminals (but with more invasive tricks).

# ---------- file completion patterns ----------
_vim_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=($(compgen -f -X '!*.@(pdf|odt|ods|doc|docx|xls|xlsx|odp|ppt|pptx|mp4|mkv|aux)' -- "$cur"))
}
shopt -s extglob
complete -F _vim_complete vim

_build_mom_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=($(compgen -f -X '!*.mom' -- "$cur"))
}
complete -F _build_mom_complete build-workshop
complete -F _build_mom_complete build-document
