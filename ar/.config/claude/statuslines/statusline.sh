#!/usr/bin/env bash
set -euo pipefail 2>/dev/null || set -eu

# ============================================================
# STATUSLINE v2.0.0 - Claude Code Status Line
# ============================================================

readonly STATUSLINE_VERSION="2.0.0"

# ============================================================
# CONFIGURATION
# ============================================================
readonly BAR_WIDTH=12
readonly BAR_FILLED="█"
readonly BAR_EMPTY="░"

# Colors (256-color palette)
readonly RED='\033[38;5;203m'
readonly GREEN='\033[38;5;150m'
readonly BLUE='\033[38;5;117m'
readonly MAGENTA='\033[38;5;147m'
readonly CYAN='\033[38;5;81m'
readonly ORANGE='\033[38;5;215m'
readonly YELLOW='\033[38;5;222m'
readonly GRAY='\033[38;5;245m'
readonly LIGHT_GRAY='\033[38;5;249m'
readonly NC='\033[0m'

# Derived constants
readonly SEPARATOR="${GRAY}│${NC}"
readonly NULL_VALUE="null"

# Icons
readonly MODEL_ICON="🤖"
readonly CONTEXT_ICON="🧠"
readonly DIR_ICON="📁"
readonly GIT_ICON="🌿"
readonly COST_ICON="💰"
readonly TOKEN_ICON="📊"
readonly TIME_ICON="🕒"
readonly VERSION_ICON="📟"

# Git state constants
readonly STATE_NOT_REPO="not_repo"
readonly STATE_CLEAN="clean"
readonly STATE_DIRTY="dirty"

# Context usage messages (tiered by usage percentage)
readonly CONTEXT_MSG_VERY_LOW=(
  "just getting started"
  "barely touched it"
  "fresh as a daisy"
  "room for an elephant"
  "zero stress mode"
  "could do this all day"
  "warming up the engines"
  "practically empty"
  "smooth sailing ahead"
  "all systems nominal"
)

readonly CONTEXT_MSG_LOW=(
  "light snacking"
  "taking it easy"
  "smooth operator"
  "just vibing"
  "cruising altitude"
  "nice and steady"
  "zen mode activated"
  "coasting along"
  "comfortable cruise"
  "looking good"
)

readonly CONTEXT_MSG_MEDIUM=(
  "halfway there"
  "finding the groove"
  "building momentum"
  "picking up speed"
  "getting interesting"
  "entering the zone"
  "getting warmer"
  "balanced perfectly"
  "sweet spot territory"
  "gears are meshing"
)

readonly CONTEXT_MSG_HIGH=(
  "getting spicy"
  "filling up fast"
  "things heating up"
  "turning up the heat"
  "entering danger zone"
  "feeling the pressure"
  "approaching red zone"
  "intensity rising"
  "full throttle mode"
  "hold on tight"
)

readonly CONTEXT_MSG_CRITICAL=(
  "living dangerously"
  "pushing the limits"
  "houston we have a problem"
  "danger zone activated"
  "running on fumes"
  "this is fine 🔥"
  "critical mass approaching"
  "maximum overdrive"
  "context go brrrr"
  "about to explode"
)

# ============================================================
# LOGGING
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/statusline.log"

log_debug() {
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] $*" >>"$LOG_FILE" 2>/dev/null || true
}

# ============================================================
# UTILITY FUNCTIONS
# ============================================================

# Check jq availability
check_jq() {
  command -v jq >/dev/null 2>&1
}

# String utilities
get_dirname() { echo "${1##*/}"; }
sep() { echo -n " ${SEPARATOR} "; }

# Format numbers with K/M suffixes
format_number() {
  local num="${1:-0}"
  [[ ! "$num" =~ ^[0-9]+$ ]] && {
    echo "$num"
    return
  }

  if [[ "$num" -lt 1000 ]]; then
    echo "$num"
  elif [[ "$num" -lt 1000000 ]]; then
    local k=$((num / 1000))
    local remainder=$((num % 1000))
    if [[ "$k" -lt 10 ]]; then
      local decimal=$((remainder / 100))
      echo "${k}.${decimal}K"
    else
      echo "${k}K"
    fi
  else
    local m=$((num / 1000000))
    local remainder=$((num % 1000000))
    if [[ "$m" -lt 10 ]]; then
      local decimal=$((remainder / 100000))
      echo "${m}.${decimal}M"
    else
      echo "${m}M"
    fi
  fi
}

# Format duration (ms to human readable)
format_duration() {
  local ms="${1:-0}"
  [[ ! "$ms" =~ ^[0-9]+$ ]] && {
    echo ""
    return
  }

  local seconds=$((ms / 1000))
  local minutes=$((seconds / 60))
  local hours=$((minutes / 60))

  if [[ "$hours" -gt 0 ]]; then
    local remaining_mins=$((minutes % 60))
    echo "${hours}h${remaining_mins}m"
  elif [[ "$minutes" -gt 0 ]]; then
    local remaining_secs=$((seconds % 60))
    echo "${minutes}m${remaining_secs}s"
  else
    echo "${seconds}s"
  fi
}

# Format cost
format_cost() {
  local cost="${1:-0}"
  if [[ "$cost" =~ ^[0-9.]+$ ]]; then
    printf "%.2f" "$cost"
  else
    echo "0.00"
  fi
}

# Get random context message based on usage percentage
get_context_message() {
  local percent="${1:-0}"
  local messages=()

  if [[ "$percent" -le 20 ]]; then
    messages=("${CONTEXT_MSG_VERY_LOW[@]}")
  elif [[ "$percent" -le 40 ]]; then
    messages=("${CONTEXT_MSG_LOW[@]}")
  elif [[ "$percent" -le 60 ]]; then
    messages=("${CONTEXT_MSG_MEDIUM[@]}")
  elif [[ "$percent" -le 80 ]]; then
    messages=("${CONTEXT_MSG_HIGH[@]}")
  else
    messages=("${CONTEXT_MSG_CRITICAL[@]}")
  fi

  local count=${#messages[@]}
  local index=$((RANDOM % count))
  echo "${messages[$index]}"
}

# ============================================================
# JSON PARSING
# ============================================================

parse_with_jq() {
  local input="$1"

  echo "$input" | jq -r '
    .model.display_name // "Claude",
    .workspace.current_dir // .cwd // "unknown",
    (.context_window.context_window_size // 200000),
    (
      (.context_window.current_usage.input_tokens // 0) +
      (.context_window.current_usage.cache_creation_input_tokens // 0) +
      (.context_window.current_usage.cache_read_input_tokens // 0)
    ),
    (.context_window.total_input_tokens // 0),
    (.context_window.total_output_tokens // 0),
    (.cost.total_cost_usd // 0),
    (.cost.total_duration_ms // 0),
    .version // "",
    .session_id // ""
  ' 2>/dev/null
}

# Bash fallback for JSON parsing
extract_json_string() {
  local json="$1"
  local key="$2"
  local default="${3:-}"

  local value
  value=$(echo "$json" | grep -o "\"${key}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/')

  if [[ -z "$value" || "$value" == "null" ]]; then
    value=$(echo "$json" | grep -o "\"${key}\"[[:space:]]*:[[:space:]]*[0-9.]\+" | head -1 | sed 's/.*:[[:space:]]*\([0-9.]\+\).*/\1/')
  fi

  if [[ -n "$value" && "$value" != "null" ]]; then
    echo "$value"
  else
    echo "$default"
  fi
}

parse_without_jq() {
  local input="$1"

  local model_name current_dir context_size current_usage
  local total_input total_output cost_usd duration_ms version session_id

  model_name=$(extract_json_string "$input" "display_name" "Claude")
  current_dir=$(extract_json_string "$input" "current_dir" "")
  [[ -z "$current_dir" ]] && current_dir=$(extract_json_string "$input" "cwd" "unknown")

  context_size=$(extract_json_string "$input" "context_window_size" "200000")
  current_usage=$(extract_json_string "$input" "input_tokens" "0")
  total_input=$(extract_json_string "$input" "total_input_tokens" "0")
  total_output=$(extract_json_string "$input" "total_output_tokens" "0")
  cost_usd=$(extract_json_string "$input" "total_cost_usd" "0")
  duration_ms=$(extract_json_string "$input" "total_duration_ms" "0")
  version=$(extract_json_string "$input" "version" "")
  session_id=$(extract_json_string "$input" "session_id" "")

  printf '%s\n' "$model_name" "$current_dir" "$context_size" "$current_usage" \
    "$total_input" "$total_output" "$cost_usd" "$duration_ms" "$version" "$session_id"
}

# ============================================================
# GIT OPERATIONS (Optimized with porcelain v2)
# ============================================================

get_git_info() {
  local current_dir="$1"
  local git_opts=()

  [[ -n "$current_dir" && "$current_dir" != "$NULL_VALUE" && "$current_dir" != "unknown" ]] && git_opts=(-C "$current_dir")

  # Check if git repo
  git "${git_opts[@]}" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "$STATE_NOT_REPO"
    return 0
  }

  # Single git status call with all info (porcelain v2)
  local status_output
  status_output=$(git "${git_opts[@]}" status --porcelain=v2 --branch --untracked-files=all 2>/dev/null) || {
    # Fallback for older git versions
    local branch
    branch=$(git "${git_opts[@]}" branch --show-current 2>/dev/null || git "${git_opts[@]}" rev-parse --short HEAD 2>/dev/null || echo "unknown")
    echo "$STATE_CLEAN|$branch|0|0"
    return 0
  }

  # Parse porcelain v2 output
  local branch="" ahead="0" behind="0"
  while IFS= read -r line; do
    case "$line" in
    "# branch.head "*)
      branch="${line#\# branch.head }"
      ;;
    "# branch.ab "*)
      local ab="${line#\# branch.ab }"
      ahead="${ab%% *}"
      ahead="${ahead#+}"
      behind="${ab##* }"
      behind="${behind#-}"
      ;;
    esac
  done <<<"$status_output"

  branch="${branch:-(detached)}"
  ahead="${ahead:-0}"
  behind="${behind:-0}"

  # Count modified files (lines not starting with #)
  local file_count=0
  while IFS= read -r line; do
    [[ "$line" != \#* && -n "$line" ]] && ((file_count++))
  done <<<"$status_output"

  if [[ "$file_count" -eq 0 ]]; then
    echo "$STATE_CLEAN|$branch|$ahead|$behind"
    return 0
  fi

  # Get line changes
  local added=0 removed=0
  local diff_output
  diff_output=$(git "${git_opts[@]}" diff HEAD --numstat 2>/dev/null || true)
  if [[ -n "$diff_output" ]]; then
    while IFS=$'\t' read -r a r _; do
      [[ "$a" =~ ^[0-9]+$ ]] && added=$((added + a))
      [[ "$r" =~ ^[0-9]+$ ]] && removed=$((removed + r))
    done <<<"$diff_output"
  fi

  echo "$STATE_DIRTY|$branch|$file_count|$added|$removed|$ahead|$behind"
}

# ============================================================
# COMPONENT BUILDERS
# ============================================================

build_model_component() {
  local model_name="$1"
  echo -n "${MODEL_ICON} ${CYAN}${model_name}${NC}"
}

build_context_component() {
  local context_size="$1"
  local current_usage="$2"

  local context_percent=0
  if [[ "$current_usage" != "0" && "$context_size" -gt 0 ]] 2>/dev/null; then
    context_percent=$((current_usage * 100 / context_size))
  fi

  # Determine color based on usage (inverted - higher usage = more warning)
  local bar_color
  if [[ "$context_percent" -le 20 ]]; then
    bar_color="$GREEN"
  elif [[ "$context_percent" -le 40 ]]; then
    bar_color="$CYAN"
  elif [[ "$context_percent" -le 60 ]]; then
    bar_color="$YELLOW"
  elif [[ "$context_percent" -le 80 ]]; then
    bar_color="$ORANGE"
  else
    bar_color="$RED"
  fi

  # Build progress bar
  local filled=$((context_percent * BAR_WIDTH / 100))
  local empty=$((BAR_WIDTH - filled))
  local bar="${bar_color}"
  local i
  for ((i = 0; i < filled; i++)); do bar+="$BAR_FILLED"; done
  bar+="${GRAY}"
  for ((i = 0; i < empty; i++)); do bar+="$BAR_EMPTY"; done
  bar+="${NC}"

  # Format numbers
  local usage_fmt size_fmt
  usage_fmt=$(format_number "$current_usage")
  size_fmt=$(format_number "$context_size")

  # Get random message
  local message
  message=$(get_context_message "$context_percent")

  echo -n "${CONTEXT_ICON} ${GRAY}[${NC}${bar}${GRAY}]${NC} ${context_percent}% ${usage_fmt}/${size_fmt} ${GRAY}· ${message}${NC}"
}

build_directory_component() {
  local current_dir="$1"

  local dir_name
  if [[ -n "$current_dir" && "$current_dir" != "$NULL_VALUE" && "$current_dir" != "unknown" ]]; then
    # Replace home with ~
    current_dir="${current_dir/#$HOME/\~}"
    dir_name=$(get_dirname "$current_dir")
  else
    dir_name=$(get_dirname "$PWD")
  fi

  echo -n "${DIR_ICON} ${BLUE}${dir_name}${NC}"
}

build_git_component() {
  local git_data="$1"

  local state
  IFS='|' read -r state _ <<<"$git_data"

  case "$state" in
  "$STATE_NOT_REPO")
    return 0
    ;;
  "$STATE_CLEAN")
    local branch ahead behind
    IFS='|' read -r _ branch ahead behind <<<"$git_data"
    echo -n "${GIT_ICON} ${MAGENTA}${branch}${NC}"
    [[ "$ahead" -gt 0 ]] 2>/dev/null && echo -n " ${GREEN}↑${ahead}${NC}"
    [[ "$behind" -gt 0 ]] 2>/dev/null && echo -n " ${RED}↓${behind}${NC}"
    ;;
  "$STATE_DIRTY")
    local branch files added removed ahead behind
    IFS='|' read -r _ branch files added removed ahead behind <<<"$git_data"
    echo -n "${GIT_ICON} ${MAGENTA}${branch}${NC}"
    [[ "$ahead" -gt 0 ]] 2>/dev/null && echo -n " ${GREEN}↑${ahead}${NC}"
    [[ "$behind" -gt 0 ]] 2>/dev/null && echo -n " ${RED}↓${behind}${NC}"
    echo -n " ${GRAY}·${NC} ${ORANGE}${files} files${NC}"
    if [[ "$added" -gt 0 || "$removed" -gt 0 ]] 2>/dev/null; then
      echo -n " ${GREEN}+${added}${NC}/${RED}-${removed}${NC}"
    fi
    ;;
  esac
}

build_cost_component() {
  local cost_usd="$1"
  local duration_ms="$2"

  [[ -z "$cost_usd" || "$cost_usd" == "0" || "$cost_usd" == "$NULL_VALUE" ]] && return 0

  local cost_fmt
  cost_fmt=$(format_cost "$cost_usd")
  echo -n "${COST_ICON} ${YELLOW}\$${cost_fmt}${NC}"

  # Calculate burn rate ($/hour)
  if [[ -n "$duration_ms" && "$duration_ms" -gt 0 ]] 2>/dev/null; then
    local burn_rate
    burn_rate=$(echo "$cost_usd $duration_ms" | awk '{printf "%.2f", $1 * 3600000 / $2}')
    echo -n " ${GRAY}(\$${burn_rate}/h)${NC}"
  fi
}

build_token_component() {
  local total_input="$1"
  local total_output="$2"
  local duration_ms="$3"

  local total_tokens=$((total_input + total_output))
  [[ "$total_tokens" -eq 0 ]] && return 0

  local tokens_fmt
  tokens_fmt=$(format_number "$total_tokens")
  echo -n "${TOKEN_ICON} ${LIGHT_GRAY}${tokens_fmt} tok${NC}"

  # Calculate TPM
  if [[ -n "$duration_ms" && "$duration_ms" -gt 0 ]] 2>/dev/null; then
    local tpm
    tpm=$(echo "$total_tokens $duration_ms" | awk '{if ($2 > 0) printf "%.0f", $1 * 60000 / $2; else print "0"}')
    echo -n " ${GRAY}(${tpm} tpm)${NC}"
  fi
}

build_time_component() {
  local duration_ms="$1"

  [[ -z "$duration_ms" || "$duration_ms" == "0" || "$duration_ms" == "$NULL_VALUE" ]] && return 0

  local duration_fmt
  duration_fmt=$(format_duration "$duration_ms")
  [[ -n "$duration_fmt" ]] && echo -n "${TIME_ICON} ${LIGHT_GRAY}${duration_fmt}${NC}"
}

build_version_component() {
  local version="$1"

  [[ -z "$version" || "$version" == "$NULL_VALUE" ]] && return 0
  echo -n "${VERSION_ICON} ${GRAY}v${version}${NC}"
}

# ============================================================
# MAIN
# ============================================================

main() {
  # Read input
  local input
  input=$(cat) || {
    echo "Error: Failed to read stdin" >&2
    exit 1
  }

  log_debug "Status line triggered (v${STATUSLINE_VERSION})"

  # Parse JSON
  local parsed
  if check_jq; then
    parsed=$(parse_with_jq "$input")
    log_debug "Using jq for JSON parsing"
  else
    parsed=$(parse_without_jq "$input")
    log_debug "Using bash fallback for JSON parsing"
  fi

  if [[ -z "$parsed" ]]; then
    echo "Error: Failed to parse input" >&2
    exit 1
  fi

  # Extract fields
  local model_name current_dir context_size current_usage
  local total_input total_output cost_usd duration_ms version session_id
  {
    read -r model_name
    read -r current_dir
    read -r context_size
    read -r current_usage
    read -r total_input
    read -r total_output
    read -r cost_usd
    read -r duration_ms
    read -r version
    read -r session_id
  } <<<"$parsed"

  log_debug "Parsed: model=$model_name, dir=$current_dir, context=$current_usage/$context_size, cost=$cost_usd, duration=$duration_ms"

  # Get git info
  local git_data
  git_data=$(get_git_info "$current_dir")

  # Build components
  local output=""

  # Line 1: Model | Directory | Git | Version
  output+=$(build_model_component "$model_name")
  output+=$(sep)
  output+=$(build_directory_component "$current_dir")

  local git_component
  git_component=$(build_git_component "$git_data")
  [[ -n "$git_component" ]] && {
    output+=$(sep)
    output+="$git_component"
  }

  local version_component
  version_component=$(build_version_component "$version")
  [[ -n "$version_component" ]] && {
    output+=$(sep)
    output+="$version_component"
  }

  # Line 2: Context
  output+=$'\n'
  output+=$(build_context_component "$context_size" "$current_usage")

  # Line 3: Cost | Tokens | Time
  local cost_component token_component time_component
  cost_component=$(build_cost_component "$cost_usd" "$duration_ms")
  token_component=$(build_token_component "$total_input" "$total_output" "$duration_ms")
  time_component=$(build_time_component "$duration_ms")

  if [[ -n "$cost_component" || -n "$token_component" || -n "$time_component" ]]; then
    output+=$'\n'
    local first=1
    if [[ -n "$cost_component" ]]; then
      output+="$cost_component"
      first=0
    fi
    if [[ -n "$token_component" ]]; then
      [[ "$first" -eq 0 ]] && output+=$(sep)
      output+="$token_component"
      first=0
    fi
    if [[ -n "$time_component" ]]; then
      [[ "$first" -eq 0 ]] && output+=$(sep)
      output+="$time_component"
    fi
  fi

  echo -e "$output"
}

main "$@"
