#!/bin/bash
# Mind Palace session start hook
# Runs at Claude Code session start to:
# 1. Trigger permission prompt for mp:* if not yet whitelisted
# 2. Create session and set environment variables

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

  # Create or find session
  sessions_dir="$HOME/.mind-palace/sessions"
  existing=$(find "$sessions_dir" -maxdepth 1 -type d -name "*_${SESSION_ID}" 2>/dev/null | head -1)

  if [[ -n "$existing" ]]; then
    # Session exists (resume/compact/clear)
    session_name=$(basename "$existing")
  elif [[ "$SOURCE" == "startup" ]]; then
    # New session - create it
    ~/.mind-palace/mp add session "$SESSION_ID" >/dev/null 2>&1
    existing=$(find "$sessions_dir" -maxdepth 1 -type d -name "*_${SESSION_ID}" 2>/dev/null | head -1)
    session_name=$(basename "$existing")
  fi

  if [[ -n "$session_name" ]]; then
    echo "MIND_PALACE_SESSION_NAME=$session_name" >> "$CLAUDE_ENV_FILE"
  fi
fi

# Auto-update check (non-blocking)
~/.mind-palace/mp update --quiet 2>/dev/null || true

# Build context for Claude
context="## Mind Palace

You have persistent memory across sessions. Use the mind-palace skill when you need to read or write memories.

### Memory Types
- **user/** - User preferences, workflows, communication style
- **self/** - Your learnings, effective patterns, limitations
- **projects/** - Project knowledge, architecture, conventions
- **sessions/** - Working scratchpad (auto-cleaned after ~7 days)

### When to Query
- When user references prior conversations: plans, decisions, prior work
- Before searching the codebase: check if prior exploration exists
- After compaction: read session files if MIND_PALACE_RESTORED=1

### When to Update
- **user/**: Learning preferences, told \"remember that I...\"
- **self/**: Discovering effective patterns, what works/doesn't
- **projects/**: Key files, architecture, conventions learned
- **sessions/**: Write after completing tasks or making progress

### Core Memories (provided directly - no need to read these)"

# Append user memory if exists
if [[ -f "$HOME/.mind-palace/user/index.md" ]]; then
  user_content=$(~/.mind-palace/mp read user/index.md)
  context="$context

#### user/index.md
\`\`\`
$user_content
\`\`\`"
fi

# Append self memory if exists
if [[ -f "$HOME/.mind-palace/self/index.md" ]]; then
  self_content=$(~/.mind-palace/mp read self/index.md)
  context="$context

#### self/index.md
\`\`\`
$self_content
\`\`\`"
fi

# Output as JSON for Claude Code to inject into context
jq -n --arg ctx "$context" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
