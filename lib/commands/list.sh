#!/bin/bash
# mp list - List memories

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
        # Normalize plural to singular for directory
        local dir="$type"
        [[ "$type" == "projects" ]] && dir="projects"
        [[ "$type" == "sessions" ]] && dir="sessions"
        [[ "$type" == "user" ]] && dir="user"
        [[ "$type" == "project" ]] && dir="projects"
        [[ "$type" == "self" ]] && dir="self"
        [[ "$type" == "session" ]] && dir="sessions"

        if [[ ! -d "$MIND_PALACE_DIR/$dir" ]]; then
          echo "No $type memories found"
          return 0
        fi

        echo "$type:"
        find "$MIND_PALACE_DIR/$dir" -name "index.md" -type f 2>/dev/null | while read -r f; do
          local rel="${f#$MIND_PALACE_DIR/}"
          local mem="${rel%/index.md}"
          # Extract title from frontmatter or first heading
          local title
          title=$(grep -m1 "^# " "$f" 2>/dev/null | sed 's/^# //')
          if [[ -n "$title" ]]; then
            echo "  $mem - $title"
          else
            echo "  $mem"
          fi
        done
        ;;
      *)
        echo "Error: Unknown type '$type'" >&2
        echo "Valid types: user, project, self, session" >&2
        return 1
        ;;
    esac
  else
    # List all types
    for dir in user self projects sessions; do
      if [[ -d "$MIND_PALACE_DIR/$dir" ]]; then
        local count
        count=$(find "$MIND_PALACE_DIR/$dir" -name "index.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$count" -gt 0 ]]; then
          echo "$dir/ ($count)"
          find "$MIND_PALACE_DIR/$dir" -name "index.md" -type f 2>/dev/null | while read -r f; do
            local rel="${f#$MIND_PALACE_DIR/}"
            local mem="${rel%/index.md}"
            echo "  $mem"
          done
          echo ""
        fi
      fi
    done
  fi
}
