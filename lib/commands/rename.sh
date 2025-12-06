#!/bin/bash
# mp rename - Rename/move a memory

cmd_rename() {
  local from="$1"
  local to="$2"

  if [[ -z "$from" || -z "$to" ]]; then
    echo "Usage: $MP_CMD rename <from> <to>" >&2
    echo "" >&2
    echo "Renames or moves a memory. Symlinks are updated automatically." >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $MP_CMD rename user/old-name user/new-name" >&2
    echo "  $MP_CMD rename projects/foo projects/bar" >&2
    return 1
  fi

  # Security: reject absolute paths
  if [[ "$from" == /* || "$to" == /* ]]; then
    echo "Error: Absolute paths not allowed" >&2
    return 1
  fi

  # Security: reject path traversal
  if [[ "$from" == *..* || "$to" == *..* ]]; then
    echo "Error: Path traversal (..) not allowed" >&2
    return 1
  fi

  local from_path="$MIND_PALACE_DIR/$from"
  local to_path="$MIND_PALACE_DIR/$to"

  # Check source exists
  if [[ ! -e "$from_path" ]]; then
    echo "Error: $from does not exist" >&2
    return 1
  fi

  # Check target doesn't exist
  if [[ -e "$to_path" ]]; then
    echo "Error: $to already exists" >&2
    return 1
  fi

  # Find all symlinks that point to the old path (or files under it)
  local links_data
  links_data=$(find "$MIND_PALACE_DIR" -type l 2>/dev/null | while IFS= read -r link; do
    # Get the directory containing the symlink
    local link_dir
    link_dir=$(dirname "$link")

    # Resolve the symlink target to absolute path
    local target
    target=$(readlink "$link")

    # If relative, make it absolute from link's directory
    local abs_target
    if [[ "$target" == /* ]]; then
      abs_target="$target"
    else
      abs_target=$(cd "$link_dir" && cd "$(dirname "$target")" 2>/dev/null && pwd)/$(basename "$target")
    fi

    # Normalize the path (remove . and ..)
    abs_target=$(cd "$(dirname "$abs_target")" 2>/dev/null && pwd)/$(basename "$abs_target") 2>/dev/null || continue

    # Check if this symlink points to something under from_path
    if [[ "$abs_target" == "$from_path" || "$abs_target" == "$from_path"/* ]]; then
      # Calculate relative path within the renamed tree
      local rel_within="${abs_target#$from_path}"
      printf '%s\t%s\n' "$link" "$rel_within"
    fi
  done)

  local -a links_to_update=()
  local -a link_targets=()
  if [[ -n "$links_data" ]]; then
    while IFS=$'\t' read -r link rel_within; do
      links_to_update+=("$link")
      link_targets+=("$rel_within")
    done <<< "$links_data"
  fi

  # Ensure parent directory exists
  local parent
  parent=$(dirname "$to_path")
  mkdir -p "$parent"

  # Move
  mv "$from_path" "$to_path"

  # Update symlinks
  local updated=0
  for i in "${!links_to_update[@]}"; do
    local link="${links_to_update[$i]}"
    local rel_within="${link_targets[$i]}"
    local new_target="$to_path$rel_within"
    local link_dir
    link_dir=$(dirname "$link")

    # Calculate relative path from link location to new target
    local rel_path
    rel_path=$(calculate_relative_path "$link_dir" "$new_target")

    # Update the symlink
    ln -sf "$rel_path" "$link"
    ((updated++))
  done

  echo "Renamed: $from -> $to"
  if [[ $updated -gt 0 ]]; then
    echo "Updated $updated symlink(s)"
  fi
}

# Calculate relative path from one directory to another
calculate_relative_path() {
  local from_dir="$1"
  local to_path="$2"

  # Normalize paths
  from_dir=$(cd "$from_dir" && pwd)
  local to_dir
  to_dir=$(dirname "$to_path")
  to_dir=$(cd "$to_dir" 2>/dev/null && pwd) || to_dir="$to_path"
  local to_name
  to_name=$(basename "$to_path")

  # Count common prefix
  local common=""
  local from_rest="$from_dir"
  local to_rest="$to_dir"

  # Split into components and find common prefix
  IFS='/' read -ra from_parts <<< "$from_dir"
  IFS='/' read -ra to_parts <<< "$to_dir"

  local i=0
  while [[ $i -lt ${#from_parts[@]} && $i -lt ${#to_parts[@]} && "${from_parts[$i]}" == "${to_parts[$i]}" ]]; do
    ((i++))
  done

  # Build relative path: go up from from_dir, then down to to_dir
  local rel=""
  local j=$i
  while [[ $j -lt ${#from_parts[@]} ]]; do
    rel="../$rel"
    ((j++))
  done

  while [[ $i -lt ${#to_parts[@]} ]]; do
    rel="$rel${to_parts[$i]}/"
    ((i++))
  done

  echo "${rel}$to_name"
}
