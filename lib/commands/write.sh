#!/bin/bash
# mp write - Write content to a file within mind-palace

cmd_write() {
  local path="$1"

  if [[ -z "$path" ]]; then
    echo "Usage: $MP_CMD write <path>" >&2
    echo "" >&2
    echo "Writes stdin to a file within the mind-palace directory." >&2
    echo "Path must be relative and cannot escape the directory." >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $MP_CMD write user/preferences/index.md <<'EOF'" >&2
    echo "  content here" >&2
    echo "  EOF" >&2
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

  # Ensure parent directory exists
  local parent
  parent=$(dirname "$target")
  mkdir -p "$parent"

  # Write stdin to file
  cat > "$target"

  echo "Wrote: $target"
}
