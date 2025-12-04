#!/bin/bash
# mp add - Create new memory

cmd_add() {
  local type="$1"
  local name="$2"

  if [[ -z "$type" || -z "$name" ]]; then
    echo "Usage: $MP_CMD add <type> <name>" >&2
    echo "" >&2
    echo "Types: user, project, self, session" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $MP_CMD add user preferences" >&2
    echo "  $MP_CMD add project jerska/mind-palace" >&2
    echo "  $MP_CMD add self limitations" >&2
    return 1
  fi

  # Validate type
  case "$type" in
    user|project|self|session) ;;
    *)
      echo "Error: Invalid type '$type'" >&2
      echo "Valid types: user, project, self, session" >&2
      return 1
      ;;
  esac

  # Build path
  local memory_dir="$MIND_PALACE_DIR/$type/$name"
  local index_file="$memory_dir/index.md"

  # Check if already exists
  if [[ -d "$memory_dir" ]]; then
    echo "Error: Memory already exists at $memory_dir" >&2
    return 1
  fi

  # Create directory
  mkdir -p "$memory_dir"

  # Get current date
  local today
  today=$(date +%Y-%m-%d)

  # Generate title from name (last path component, replace dashes/underscores with spaces)
  local title
  title=$(basename "$name" | sed 's/[-_]/ /g')
  # Capitalize first letter
  title="$(echo "${title:0:1}" | tr '[:lower:]' '[:upper:]')${title:1}"

  # Create index.md template
  cat > "$index_file" <<EOF
---
type: $type
tags: []
created: $today
---

# $title

Brief summary (2-5 sentences). What is this, why does it matter.

## Key Points
-

## Pointers
- File: \`path/to/file.ts\`
- Function: \`functionName\` in \`path/to/file.ts:42\`

## Related
- [related-memory](related-memory)
EOF

  echo "Created: $index_file"
  echo ""
  echo "Edit the file to add content, then optionally:"
  echo "  $MP_CMD link $type/$name <other-memory>"
}
