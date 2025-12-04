#!/bin/bash
# grep backend for Mind Palace search

backend_search() {
  local query="$1"
  local limit="${2:-10}"

  if [[ -z "$query" ]]; then
    return 1
  fi

  # Search markdown files, case insensitive
  # Output format: filepath:line:content
  grep -ri --include="*.md" "$query" "$MIND_PALACE_DIR" 2>/dev/null | head -n "$limit" || true
}

# Format search results for display
backend_format_results() {
  local line
  while IFS= read -r line; do
    if [[ -z "$line" ]]; then
      continue
    fi

    # Parse grep output: /path/to/file.md:content
    local file="${line%%:*}"
    local content="${line#*:}"

    # Make path relative to MIND_PALACE_DIR
    local rel_path="${file#$MIND_PALACE_DIR/}"

    # Extract memory path (remove index.md if present)
    local memory_path="${rel_path%/index.md}"

    # Truncate content for display
    if [[ ${#content} -gt 80 ]]; then
      content="${content:0:77}..."
    fi

    echo "$memory_path"
    echo "  $content"
    echo ""
  done
}

# Not applicable for grep backend
backend_index() {
  echo "grep backend does not require indexing"
}

backend_reindex() {
  echo "grep backend does not require indexing"
}
