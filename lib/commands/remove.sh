#!/bin/bash
# mp remove - Remove a file or directory within mind-palace

cmd_remove() {
  local path="$1"

  if [[ -z "$path" ]]; then
    echo "Usage: $MP_CMD remove <path>" >&2
    echo "" >&2
    echo "Removes a file or directory within the mind-palace directory." >&2
    echo "Path must be relative and cannot escape the directory." >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $MP_CMD remove sessions/old-session" >&2
    return 1
  fi

  # Security: reject absolute paths
  if [[ "$path" == /* ]]; then
    echo "Error: Absolute paths not allowed" >&2
    return 1
  fi

  # Security: reject path traversal
  if [[ "$path" == *..* ]]; then
    echo "Error: Path traversal (..) not allowed" >&2
    return 1
  fi

  local target="$MIND_PALACE_DIR/$path"

  # Check target exists
  if [[ ! -e "$target" ]]; then
    echo "Error: $target does not exist" >&2
    return 1
  fi

  # Remove (file or directory)
  rm -rf "$target"

  echo "Removed: $target"
}
