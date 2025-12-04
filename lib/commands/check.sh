#!/bin/bash
# mp check - Find broken symlinks in memories

cmd_check() {
  if [[ ! -d "$MIND_PALACE_DIR" ]]; then
    echo "Error: Mind Palace not initialized at $MIND_PALACE_DIR" >&2
    return 1
  fi

  local broken=0
  local checked=0

  # Find all symlinks
  while IFS= read -r -d '' link; do
    ((checked++)) || true

    if [[ ! -e "$link" ]]; then
      local target
      target=$(readlink "$link")
      local rel_link="${link#$MIND_PALACE_DIR/}"
      echo "Broken: $rel_link -> $target"
      ((broken++)) || true
    fi
  done < <(find "$MIND_PALACE_DIR" -type l -print0 2>/dev/null)

  echo ""
  if [[ $broken -eq 0 ]]; then
    echo "All $checked symlinks OK"
  else
    echo "Found $broken broken symlink(s) out of $checked total"
    echo ""
    echo "To fix, either:"
    echo "  - Remove the broken link: $MP_CMD unlink <from> <to>"
    echo "  - Create the missing target: $MP_CMD add <type> <name>"
    return 1
  fi
}
