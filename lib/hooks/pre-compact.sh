#!/bin/bash
# Mind Palace pre-compact hook
# Runs before Claude Code context compaction
#
# With the new session workflow, Claude writes to session files during work,
# so no special action is needed here. This hook exists for future extensibility.

# Receives JSON via stdin with session_id, transcript_path, trigger, etc.
# INPUT=$(cat)
# SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

# No action needed - sessions are managed during the conversation
exit 0
