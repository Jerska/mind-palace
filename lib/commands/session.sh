#!/bin/bash
# mp session - Session memory management

cmd_session() {
  local subcmd="${1:-}"
  shift 2>/dev/null || true

  case "$subcmd" in
    check) session_check "$@" ;;
    list) session_list "$@" ;;
    clean) session_clean "$@" ;;
    *)
      echo "Usage: $MP_CMD session <subcommand>" >&2
      echo "" >&2
      echo "Subcommands:" >&2
      echo "  check [session-id]  Check if session exists (uses \$MIND_PALACE_SESSION_ID)" >&2
      echo "  list                List saved sessions" >&2
      echo "  clean [--days=N]    Remove sessions older than N days (default: 7)" >&2
      return 1
      ;;
  esac
}

# Find session directory by ID (handles date-time prefix)
find_session_dir() {
  local session_id="$1"
  local sessions_dir="$MIND_PALACE_DIR/sessions"

  # Look for folder ending with _$session_id
  find "$sessions_dir" -maxdepth 1 -type d -name "*_${session_id}" 2>/dev/null | head -1
}

session_check() {
  local session_id="${1:-$MIND_PALACE_SESSION_ID}"

  if [[ -z "$session_id" ]]; then
    echo "No session ID provided and MIND_PALACE_SESSION_ID not set" >&2
    return 1
  fi

  local session_dir
  session_dir=$(find_session_dir "$session_id")

  if [[ -n "$session_dir" && -d "$session_dir" ]]; then
    echo "found"
    return 0
  else
    echo "none"
    return 1
  fi
}

session_list() {
  local sessions_dir="$MIND_PALACE_DIR/sessions"

  if [[ ! -d "$sessions_dir" ]]; then
    echo "No sessions found."
    return 0
  fi

  local count=0
  for dir in "$sessions_dir"/*/; do
    [[ -d "$dir" ]] || continue
    local name
    name=$(basename "$dir")
    echo "$name"
    ((count++)) || true
  done

  if [[ $count -eq 0 ]]; then
    echo "No sessions found."
  fi
}

session_clean() {
  local days=7

  # Parse args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --days=*) days="${1#*=}"; shift ;;
      --days) days="$2"; shift 2 ;;
      *) echo "Error: Unknown option '$1'" >&2; return 1 ;;
    esac
  done

  local sessions_dir="$MIND_PALACE_DIR/sessions"

  if [[ ! -d "$sessions_dir" ]]; then
    echo "No sessions to clean."
    return 0
  fi

  local count=0
  local now
  now=$(date +%s)
  local cutoff=$((days * 86400))

  for dir in "$sessions_dir"/*/; do
    [[ -d "$dir" ]] || continue

    local name
    name=$(basename "$dir")

    # Extract date from folder name (format: YYYY-MM-DD_HH-MM_session_id)
    local created_date="${name:0:10}"
    local created_time="${name:11:5}"

    if [[ "$created_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      local created_epoch
      # macOS and Linux compatible date parsing
      if date -j -f "%Y-%m-%d_%H-%M" "${created_date}_${created_time}" +%s >/dev/null 2>&1; then
        created_epoch=$(date -j -f "%Y-%m-%d_%H-%M" "${created_date}_${created_time}" +%s)
      else
        created_epoch=$(date -d "${created_date} ${created_time//-/:}" +%s 2>/dev/null || echo "0")
      fi

      local age=$((now - created_epoch))
      if [[ $age -gt $cutoff ]]; then
        rm -rf "$dir"
        echo "Removed: sessions/$name"
        ((count++)) || true
      fi
    fi
  done

  if [[ $count -eq 0 ]]; then
    echo "No sessions older than $days days."
  else
    echo "Cleaned $count session(s)."
  fi
}
