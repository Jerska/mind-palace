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

# Format search results for display, grouped by memory
backend_format_results() {
  local last_memory=""
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

    # Extract memory path (remove index.md or other filename)
    local memory_path
    if [[ "$rel_path" == */index.md ]]; then
      memory_path="${rel_path%/index.md}"
    else
      memory_path="$(dirname "$rel_path")"
    fi

    # Only print memory path if different from last
    if [[ "$memory_path" != "$last_memory" ]]; then
      if [[ -n "$last_memory" ]]; then
        echo ""
      fi
      echo "$memory_path"
      last_memory="$memory_path"
    fi

    # Truncate content for display
    if [[ ${#content} -gt 80 ]]; then
      content="${content:0:77}..."
    fi

    echo "  $content"
  done
}

# Not applicable for grep backend
backend_index() {
  echo "grep backend does not require indexing"
}

backend_reindex() {
  echo "grep backend does not require indexing"
}
