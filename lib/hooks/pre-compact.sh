#!/bin/bash
# Mind Palace pre-compact hook
# Runs before Claude Code context compaction to save session state

# Receives JSON via stdin with session_id, transcript_summary, etc.
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

if [[ -n "$SESSION_ID" ]]; then
  # TODO: Phase 3 - implement session save
  # ~/.mind-palace/mp session save "$SESSION_ID"
  :
fi
