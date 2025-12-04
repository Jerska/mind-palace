#!/bin/bash
# mp unlink - Remove symlink between memories

cmd_unlink() {
  local from="$1"
  local to="$2"

  if [[ -z "$from" || -z "$to" ]]; then
    echo "Usage: $MP_CMD unlink <from> <to>" >&2
    echo "" >&2
    echo "Removes a symlink from <from>/<to-name>" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $MP_CMD unlink user/preferences user/jerska" >&2
    return 1
  fi

  # Build link path
  local link_name
  link_name=$(basename "$to")
  local link_path="$MIND_PALACE_DIR/$from/$link_name"

  # Check if link exists
  if [[ ! -L "$link_path" ]]; then
    if [[ -e "$link_path" ]]; then
      echo "Error: $link_path exists but is not a symlink" >&2
      return 1
    fi
    echo "Error: Link not found: $from/$link_name" >&2
    return 1
  fi

  rm "$link_path"
  echo "Removed: $from/$link_name"
}
