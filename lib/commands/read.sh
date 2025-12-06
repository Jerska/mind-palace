#!/bin/bash
# mp read - Read a file within mind-palace

cmd_read() {
  local path="$1"

  if [[ -z "$path" ]]; then
    echo "Usage: $MP_CMD read <path>" >&2
    echo "" >&2
    echo "Reads a file within the mind-palace directory." >&2
    echo "Path must be relative and cannot escape the directory." >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $MP_CMD read user/preferences/index.md" >&2
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
    echo "Error: $path does not exist" >&2
    return 1
  fi

  # Handle directories: try index.md
  if [[ -d "$target" ]]; then
    if [[ -f "$target/index.md" ]]; then
      echo "Warning: $path is a directory, reading index.md" >&2
      cat "$target/index.md"
      return 0
    else
      echo "Error: $path is a directory with no index.md" >&2
      return 1
    fi
  fi

  # Check it's a file
  if [[ ! -f "$target" ]]; then
    echo "Error: $path is not a file" >&2
    return 1
  fi

  cat "$target"
}
