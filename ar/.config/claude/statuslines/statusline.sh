#!/usr/bin/env bash
set -euo pipefail 2>/dev/null || set -eu

# ============================================================
# STATUSLINE v2.1.0 - Claude Code Status Line
# ============================================================

readonly STATUSLINE_VERSION="2.1.0"

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
readonly DAILY_COST_ICON="📅"
readonly TOKEN_ICON="📊"
readonly CACHE_ICON="💾"
readonly TIME_ICON="🕒"
readonly REMAINING_ICON="⏳"
readonly VERSION_ICON="📟"
readonly PYTHON_ICON="🐍"
readonly GO_ICON="🦫"
readonly NODE_ICON="📦"
readonly RUST_ICON="🦀"

# Git state constants
readonly STATE_NOT_REPO="not_repo"
readonly STATE_CLEAN="clean"
readonly STATE_DIRTY="dirty"

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

# ============================================================
# LANGUAGE/RUNTIME DETECTION
# ============================================================

detect_language_info() {
  local current_dir="$1"
  local lang_info=""

  # Use current_dir or fallback to PWD
  local check_dir="${current_dir:-$PWD}"
  [[ "$check_dir" == "$NULL_VALUE" || "$check_dir" == "unknown" ]] && check_dir="$PWD"

  # Check for Python project
  if [[ -n "${VIRTUAL_ENV:-}" ]]; then
    local venv_name="${VIRTUAL_ENV##*/}"
    local folder_name="${check_dir##*/}"
    # Show venv name unless it's generic
    if [[ "$venv_name" == ".venv" || "$venv_name" == "venv" ]]; then
      venv_name="$folder_name"
    fi
    local pyver
    pyver=$(python3 --version 2>/dev/null | cut -d' ' -f2 || echo '')
    [[ -n "$pyver" ]] && lang_info="${PYTHON_ICON} ${GREEN}${pyver}${NC} ${GRAY}(${venv_name})${NC}"
  elif [[ -f "$check_dir/requirements.txt" || -f "$check_dir/setup.py" || -f "$check_dir/pyproject.toml" || -f "$check_dir/Pipfile" ]]; then
    local pyver
    pyver=$(python3 --version 2>/dev/null | cut -d' ' -f2 || echo '')
    [[ -n "$pyver" ]] && lang_info="${PYTHON_ICON} ${GREEN}${pyver}${NC}"
  # Check for Go project
  elif [[ -f "$check_dir/go.mod" || -f "$check_dir/go.sum" ]]; then
    local gover
    gover=$(go version 2>/dev/null | grep -oE 'go[0-9]+\.[0-9]+(\.[0-9]+)?' | sed 's/go//' || echo '')
    [[ -n "$gover" ]] && lang_info="${GO_ICON} ${CYAN}${gover}${NC}"
  # Check for Node.js project
  elif [[ -f "$check_dir/package.json" ]]; then
    local nodever
    nodever=$(node --version 2>/dev/null | sed 's/v//' || echo '')
    [[ -n "$nodever" ]] && lang_info="${NODE_ICON} ${GREEN}${nodever}${NC}"
  # Check for Rust project
  elif [[ -f "$check_dir/Cargo.toml" ]]; then
    local rustver
    rustver=$(rustc --version 2>/dev/null | cut -d' ' -f2 || echo '')
    [[ -n "$rustver" ]] && lang_info="${RUST_ICON} ${ORANGE}${rustver}${NC}"
  fi

  echo "$lang_info"
}

# ============================================================
# CCUSAGE DATA FETCHING
# ============================================================

get_ccusage_data() {
  local session_id="$1"

  # Check if npx is available
  command -v npx >/dev/null 2>&1 || return 1

  # Get daily cost
  local daily_cost=""
  local daily_json
  daily_json=$(npx ccusage daily --json 2>/dev/null)
  if [[ -n "$daily_json" ]]; then
    daily_cost=$(echo "$daily_json" | jq -r '.totals.totalCost // 0' 2>/dev/null)
  fi

  # Get active block data (projections, remaining time)
  local remaining_minutes="" projected_cost="" block_cost="" burn_rate=""
  local blocks_json
  blocks_json=$(npx ccusage blocks --active --json 2>/dev/null)
  if [[ -n "$blocks_json" ]]; then
    remaining_minutes=$(echo "$blocks_json" | jq -r '.blocks[0].projection.remainingMinutes // empty' 2>/dev/null)
    projected_cost=$(echo "$blocks_json" | jq -r '.blocks[0].projection.totalCost // empty' 2>/dev/null)
    block_cost=$(echo "$blocks_json" | jq -r '.blocks[0].costUSD // empty' 2>/dev/null)
    burn_rate=$(echo "$blocks_json" | jq -r '.blocks[0].burnRate.costPerHour // empty' 2>/dev/null)
  fi

  # Output: daily_cost|remaining_minutes|projected_cost|block_cost|burn_rate
  echo "${daily_cost:-0}|${remaining_minutes:-0}|${projected_cost:-0}|${block_cost:-0}|${burn_rate:-0}"
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
    .session_id // "",
    (.context_window.current_usage.cache_creation_input_tokens // 0),
    (.context_window.current_usage.cache_read_input_tokens // 0)
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
  local cache_creation cache_read

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
  cache_creation=$(extract_json_string "$input" "cache_creation_input_tokens" "0")
  cache_read=$(extract_json_string "$input" "cache_read_input_tokens" "0")

  printf '%s\n' "$model_name" "$current_dir" "$context_size" "$current_usage" \
    "$total_input" "$total_output" "$cost_usd" "$duration_ms" "$version" "$session_id" \
    "$cache_creation" "$cache_read"
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

  echo -n "${CONTEXT_ICON} ${GRAY}[${NC}${bar}${GRAY}]${NC} ${context_percent}% ${usage_fmt}/${size_fmt}"
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

build_language_component() {
  local lang_info="$1"
  [[ -z "$lang_info" ]] && return 0
  echo -n "$lang_info"
}

build_daily_cost_component() {
  local daily_cost="$1"

  [[ -z "$daily_cost" || "$daily_cost" == "0" || "$daily_cost" == "$NULL_VALUE" ]] && return 0

  local cost_fmt
  cost_fmt=$(format_cost "$daily_cost")
  echo -n "${DAILY_COST_ICON} ${ORANGE}\$${cost_fmt}/day${NC}"
}

build_remaining_time_component() {
  local remaining_minutes="$1"
  local projected_cost="$2"

  [[ -z "$remaining_minutes" || "$remaining_minutes" == "0" || "$remaining_minutes" == "$NULL_VALUE" ]] && return 0

  local hours=$((remaining_minutes / 60))
  local mins=$((remaining_minutes % 60))

  local time_str
  if [[ "$hours" -gt 0 ]]; then
    time_str="${hours}h ${mins}m"
  else
    time_str="${mins}m"
  fi

  # Color based on remaining time
  local time_color
  if [[ "$remaining_minutes" -gt 120 ]]; then
    time_color="$GREEN"
  elif [[ "$remaining_minutes" -gt 60 ]]; then
    time_color="$YELLOW"
  elif [[ "$remaining_minutes" -gt 30 ]]; then
    time_color="$ORANGE"
  else
    time_color="$RED"
  fi

  echo -n "${REMAINING_ICON} ${time_color}${time_str} left${NC}"

  # Show projected cost if available
  if [[ -n "$projected_cost" && "$projected_cost" != "0" && "$projected_cost" != "$NULL_VALUE" ]]; then
    local proj_fmt
    proj_fmt=$(format_cost "$projected_cost")
    echo -n " ${GRAY}(💵\$${proj_fmt})${NC}"
  fi
}

build_cache_component() {
  local cache_creation="$1"
  local cache_read="$2"

  # Skip if no significant cache usage
  local total_cache=$((cache_creation + cache_read))
  [[ "$total_cache" -lt 1000 ]] && return 0

  local creation_fmt read_fmt
  creation_fmt=$(format_number "$cache_creation")
  read_fmt=$(format_number "$cache_read")

  # Calculate cache hit ratio
  local hit_ratio=0
  if [[ "$total_cache" -gt 0 ]]; then
    hit_ratio=$((cache_read * 100 / total_cache))
  fi

  # Color based on hit ratio (higher is better for cost)
  local ratio_color
  if [[ "$hit_ratio" -ge 80 ]]; then
    ratio_color="$GREEN"
  elif [[ "$hit_ratio" -ge 50 ]]; then
    ratio_color="$YELLOW"
  else
    ratio_color="$ORANGE"
  fi

  echo -n "${CACHE_ICON} ${GRAY}+${creation_fmt}${NC}/${ratio_color}↺${read_fmt}${NC} ${GRAY}(${hit_ratio}% hit)${NC}"
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
  local cache_creation cache_read
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
    read -r cache_creation
    read -r cache_read
  } <<<"$parsed"

  log_debug "Parsed: model=$model_name, dir=$current_dir, context=$current_usage/$context_size, cost=$cost_usd, duration=$duration_ms"

  # Get git info
  local git_data
  git_data=$(get_git_info "$current_dir")

  # Get language/runtime info
  local lang_info
  lang_info=$(detect_language_info "$current_dir")

  # Get ccusage data (daily cost, remaining time, etc.)
  local ccusage_data="" daily_cost="" remaining_minutes="" projected_cost="" block_cost="" ccusage_burn_rate=""
  if check_jq; then
    ccusage_data=$(get_ccusage_data "$session_id" 2>/dev/null || echo "")
    if [[ -n "$ccusage_data" ]]; then
      IFS='|' read -r daily_cost remaining_minutes projected_cost block_cost ccusage_burn_rate <<<"$ccusage_data"
    fi
  fi

  # Build components
  local output=""

  # Line 1: Model | Directory | Language | Git | Version
  output+=$(build_model_component "$model_name")
  output+=$(sep)
  output+=$(build_directory_component "$current_dir")

  local lang_component
  lang_component=$(build_language_component "$lang_info")
  [[ -n "$lang_component" ]] && {
    output+=$(sep)
    output+="$lang_component"
  }

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

  # Line 2: Context | Tokens | Time (현재 세션 상태)
  local token_component time_component
  token_component=$(build_token_component "$total_input" "$total_output" "$duration_ms")
  time_component=$(build_time_component "$duration_ms")

  output+=$'\n'
  output+=$(build_context_component "$context_size" "$current_usage")
  [[ -n "$token_component" ]] && {
    output+=$(sep)
    output+="$token_component"
  }
  [[ -n "$time_component" ]] && {
    output+=$(sep)
    output+="$time_component"
  }

  # Line 3: Cost | Daily Cost | Remaining (비용/리소스)
  local cost_component daily_cost_component remaining_component cache_component
  cost_component=$(build_cost_component "$cost_usd" "$duration_ms")
  daily_cost_component=$(build_daily_cost_component "$daily_cost")
  remaining_component=$(build_remaining_time_component "$remaining_minutes" "$projected_cost")
  cache_component=$(build_cache_component "${cache_creation:-0}" "${cache_read:-0}")

  if [[ -n "$cost_component" || -n "$daily_cost_component" || -n "$remaining_component" ]]; then
    output+=$'\n'
    local first=1
    if [[ -n "$cost_component" ]]; then
      output+="$cost_component"
      first=0
    fi
    if [[ -n "$daily_cost_component" ]]; then
      [[ "$first" -eq 0 ]] && output+=$(sep)
      output+="$daily_cost_component"
      first=0
    fi
    if [[ -n "$remaining_component" ]]; then
      [[ "$first" -eq 0 ]] && output+=$(sep)
      output+="$remaining_component"
    fi
  fi

  # Line 4: Cache info (if significant)
  if [[ -n "$cache_component" ]]; then
    output+=$'\n'
    output+="$cache_component"
  fi

  echo -e "$output"
}

main "$@"
