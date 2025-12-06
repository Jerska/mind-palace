#!/bin/bash
# mp write - Write content to a file within mind-palace
#
# Content is passed as a positional argument rather than stdin because:
# - Heredocs (<<'EOF') trigger permission prompts even when mp:* is allowed
#   (Claude Code bug #11932 - multiline commands fail pattern matching)
# - Multiline strings as arguments work: mp write path 'line1
#   line2'

cmd_write() {
  local path="$1"
  local content="$2"

  if [[ -z "$path" || -z "$content" ]]; then
    echo "Usage: $MP_CMD write <path> <content>" >&2
    echo "" >&2
    echo "Writes content to a file within the mind-palace directory." >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $MP_CMD write user/prefs.md 'line 1" >&2
    echo "  line 2'" >&2
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

  # Write content to file
  printf '%s\n' "$content" > "$target"

  echo "Wrote: $path"
}
