#!/bin/bash
# grep backend for Mind Palace search

MATCHES_PER_FILE=3

backend_search() {
  local query="$1"
  local limit="${2:-10}"

  if [[ -z "$query" ]]; then
    return 1
  fi

  local -a terms
  read -ra terms <<< "$query"
  local count=0
  local pattern="${terms[0]}"

  # Find matching files
  local files
  if [[ ${#terms[@]} -eq 1 ]]; then
    files=$(grep -ri --include="*.md" -l "$query" "$MIND_PALACE_DIR" 2>/dev/null)
  else
    # Multi-term: find files with progressively fewer required matches
    local all_files
    all_files=$(find "$MIND_PALACE_DIR" -name "*.md" -type f 2>/dev/null)

    # Count matches per file (content + path matches)
    # Format: "count:filepath" for sorting
    local scored_files=""
    while IFS= read -r file; do
      [[ -z "$file" ]] && continue

      local match_count=0
      local rel_path="${file#$MIND_PALACE_DIR/}"
      local rel_lower=$(echo "$rel_path" | tr '[:upper:]' '[:lower:]')

      for term in "${terms[@]}"; do
        local term_lower=$(echo "$term" | tr '[:upper:]' '[:lower:]')
        # Check path match or content match
        if [[ "$rel_lower" == *"$term_lower"* ]] || grep -qi "$term" "$file" 2>/dev/null; then
          ((match_count++))
        fi
      done

      if [[ $match_count -gt 0 ]]; then
        scored_files+="$match_count:$file"$'\n'
      fi
    done <<< "$all_files"

    # Find max match count and filter to only those files
    local max_matches
    max_matches=$(echo "$scored_files" | cut -d: -f1 | sort -rn | head -1)

    local matching_files=""
    while IFS= read -r scored; do
      [[ -z "$scored" ]] && continue
      local score="${scored%%:*}"
      local file="${scored#*:}"
      if [[ "$score" -eq "$max_matches" ]]; then
        matching_files+="$file"$'\n'
      fi
    done <<< "$scored_files"

    files=$(echo "$matching_files" | sort -u)
  fi

  # Output matches from each file
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    [[ $count -ge $limit ]] && break

    local matches
    matches=$(grep -i "$pattern" "$file" 2>/dev/null | head -n "$MATCHES_PER_FILE")
    while IFS= read -r match; do
      [[ -z "$match" ]] && continue
      [[ $count -ge $limit ]] && break
      echo "$file:$match"
      ((count++))
    done <<< "$matches"
  done <<< "$files"
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

    echo "> $content"
  done
}

# Not applicable for grep backend
backend_index() {
  echo "grep backend does not require indexing"
}

backend_reindex() {
  echo "grep backend does not require indexing"
}
