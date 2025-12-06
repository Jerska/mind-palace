#!/bin/bash
# mp update - Update mind-palace from git

cmd_update() {
  local quiet=false

  # Parse args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --quiet|-q) quiet=true; shift ;;
      *) echo "Error: Unknown option '$1'" >&2; return 1 ;;
    esac
  done

  # Find the repo root (where .git is)
  local repo_dir="$MP_ROOT"
  if [[ ! -d "$repo_dir/.git" ]]; then
    $quiet || echo "Error: Not a git repository" >&2
    return 1
  fi

  # Check staleness (skip if updated within last hour)
  local last_update_file="$MIND_PALACE_DIR/.last-update"
  local now
  now=$(date +%s)

  if [[ -f "$last_update_file" ]]; then
    local last_update
    last_update=$(cat "$last_update_file")
    local age=$((now - last_update))

    # Skip if updated within last hour (3600 seconds)
    if [[ $age -lt 3600 ]]; then
      $quiet || echo "Skipped: updated $(($age / 60)) minutes ago"
      return 0
    fi
  fi

  # Do the update
  cd "$repo_dir" || return 1

  local output
  if output=$(git pull 2>&1); then
    echo "$now" > "$last_update_file"
    if [[ "$output" == "Already up to date." ]]; then
      $quiet || echo "Already up to date."
    else
      $quiet || echo "Updated successfully."
      $quiet || echo "$output"
    fi
  else
    $quiet || echo "Error: git pull failed" >&2
    $quiet || echo "$output" >&2
    return 1
  fi
}
