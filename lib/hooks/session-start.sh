#!/bin/bash
# Mind Palace session start hook
# Runs at Claude Code session start to:
# 1. Trigger permission prompt for mp:* if not yet whitelisted
# 2. Set environment variables for the session

# Receives JSON via stdin with session_id, source, transcript_path, etc.
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
SOURCE=$(echo "$INPUT" | jq -r '.source // empty')

# Trigger mp whitelist prompt (only matters on first run)
# Flags like --allow trigger "mp:*" pattern, positional args don't
~/.mind-palace/mp --allow

# Set session environment variables if CLAUDE_ENV_FILE is available
if [[ -n "$SESSION_ID" && -n "$CLAUDE_ENV_FILE" ]]; then
  echo "MIND_PALACE_SESSION_ID=$SESSION_ID" >> "$CLAUDE_ENV_FILE"

  # Detect sed command for cross-platform compatibility
  if [[ "$OSTYPE" == "darwin"* ]] && command -v gsed >/dev/null; then
    echo "MIND_PALACE_SED=gsed" >> "$CLAUDE_ENV_FILE"
  else
    echo "MIND_PALACE_SED=sed" >> "$CLAUDE_ENV_FILE"
  fi

  # Set restored flag if resuming after compaction
  if [[ "$SOURCE" == "compact" ]]; then
    echo "MIND_PALACE_RESTORED=1" >> "$CLAUDE_ENV_FILE"
  fi
fi

# Auto-update check (non-blocking)
~/.mind-palace/mp update --quiet 2>/dev/null || true
