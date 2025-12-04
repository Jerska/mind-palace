#!/bin/bash
# mp link - Create symlink between memories

cmd_link() {
  local from="$1"
  local to="$2"

  if [[ -z "$from" || -z "$to" ]]; then
    echo "Usage: $MP_CMD link <from> <to>" >&2
    echo "" >&2
    echo "Creates a symlink in <from>/ pointing to <to>" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $MP_CMD link user/preferences user/jerska" >&2
    echo "  $MP_CMD link projects/mind-palace self/limitations" >&2
    return 1
  fi

  # Validate source memory exists
  local from_dir="$MIND_PALACE_DIR/$from"
  if [[ ! -d "$from_dir" ]]; then
    echo "Error: Source memory not found: $from" >&2
    return 1
  fi

  # Validate target memory exists
  local to_dir="$MIND_PALACE_DIR/$to"
  if [[ ! -d "$to_dir" ]]; then
    echo "Error: Target memory not found: $to" >&2
    return 1
  fi

  # Create symlink with target's basename as name, next to index.md
  local link_name
  link_name=$(basename "$to")
  local link_path="$from_dir/$link_name"

  # Check if link already exists
  if [[ -e "$link_path" || -L "$link_path" ]]; then
    echo "Error: Link already exists: $link_path" >&2
    return 1
  fi

  # Calculate relative path from from_dir to target
  # from_dir is at: $MIND_PALACE_DIR/$from
  # target is at: $MIND_PALACE_DIR/$to
  # We need to go up (depth of $from) then down to $to
  local depth=0
  local tmp="$from"
  while [[ "$tmp" == */* ]]; do
    ((depth++))
    tmp="${tmp#*/}"
  done
  ((depth++))  # for the first component of $from

  local rel_path=""
  for ((i=0; i<depth; i++)); do
    rel_path="../$rel_path"
  done
  rel_path="${rel_path}$to"

  ln -s "$rel_path" "$link_path"
  echo "Created: $from/$link_name -> $to"
}
