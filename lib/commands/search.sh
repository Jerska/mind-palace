#!/bin/bash
# mp search - Search memories

cmd_search() {
  local query="$1"
  local backend="${MP_BACKEND:-grep}"
  local limit=10

  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --backend=*)
        backend="${1#*=}"
        shift
        ;;
      --limit=*)
        limit="${1#*=}"
        shift
        ;;
      -*)
        echo "Unknown option: $1" >&2
        return 1
        ;;
      *)
        if [[ -z "$query" ]]; then
          query="$1"
        fi
        shift
        ;;
    esac
  done

  if [[ -z "$query" ]]; then
    echo "Usage: $MP_CMD search <query> [--backend=grep] [--limit=10]" >&2
    return 1
  fi

  # Check if mind-palace directory exists
  if [[ ! -d "$MIND_PALACE_DIR" ]]; then
    echo "Error: Mind Palace not initialized at $MIND_PALACE_DIR" >&2
    echo "Run the install script first." >&2
    return 1
  fi

  # Load backend
  local backend_file="$MP_ROOT/lib/backends/$backend.sh"
  if [[ ! -f "$backend_file" ]]; then
    echo "Error: Unknown backend '$backend'" >&2
    return 1
  fi
  source "$backend_file"

  # Run search and format results
  backend_search "$query" "$limit" | backend_format_results
}
