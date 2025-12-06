#!/bin/bash
# mp list - List memories

list_memory() {
  local mem_path="$1"
  local indent="$2"
  local mem_dir="$MIND_PALACE_DIR/$mem_path"

  # Get title from index.md if exists
  local title=""
  if [[ -f "$mem_dir/index.md" ]]; then
    title=$(grep -m1 "^# " "$mem_dir/index.md" 2>/dev/null | sed 's/^# //')
  fi

  if [[ -n "$title" ]]; then
    echo "${indent}$mem_path - $title"
  else
    echo "${indent}$mem_path"
  fi

  # List files in this memory (excluding index.md)
  find "$mem_dir" -maxdepth 1 -type f ! -name "index.md" 2>/dev/null | sort | while read -r f; do
    local filename=$(basename "$f")
    echo "${indent}  $filename"
  done
}

list_type() {
  local dir="$1"
  local indent="${2:-  }"

  if [[ ! -d "$MIND_PALACE_DIR/$dir" ]]; then
    return 0
  fi

  # Find all memories (folders with index.md)
  find "$MIND_PALACE_DIR/$dir" -name "index.md" -type f 2>/dev/null | sort | while read -r f; do
    local rel="${f#$MIND_PALACE_DIR/}"
    local mem="${rel%/index.md}"
    list_memory "$mem" "$indent"
  done
}

cmd_list() {
  local type="$1"

  if [[ ! -d "$MIND_PALACE_DIR" ]]; then
    echo "Error: Mind Palace not initialized at $MIND_PALACE_DIR" >&2
    return 1
  fi

  # If type specified, list only that type
  if [[ -n "$type" ]]; then
    case "$type" in
      user|project|self|session|projects|sessions)
        # Normalize to directory name
        local dir="$type"
        [[ "$type" == "project" ]] && dir="projects"
        [[ "$type" == "session" ]] && dir="sessions"

        if [[ ! -d "$MIND_PALACE_DIR/$dir" ]]; then
          echo "No $type memories found"
          return 0
        fi

        echo "$dir:"
        list_type "$dir"
        ;;
      *)
        echo "Error: Unknown type '$type'" >&2
        echo "Valid types: user, project, self, session" >&2
        return 1
        ;;
    esac
  else
    # List all types except sessions by default
    for dir in user self projects; do
      if [[ -d "$MIND_PALACE_DIR/$dir" ]]; then
        local count
        count=$(find "$MIND_PALACE_DIR/$dir" -name "index.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$count" -gt 0 ]]; then
          echo "$dir/"
          list_type "$dir"
          echo ""
        fi
      fi
    done

    # Note about sessions
    if [[ -d "$MIND_PALACE_DIR/sessions" ]]; then
      local session_count
      session_count=$(find "$MIND_PALACE_DIR/sessions" -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
      session_count=$((session_count - 1))  # Exclude sessions dir itself
      if [[ "$session_count" -gt 0 ]]; then
        echo "(sessions: $session_count - use 'mp list sessions' to show)"
      fi
    fi
  fi
}
