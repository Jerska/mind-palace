#!/bin/bash
# mp reference - Print CLI reference for sub-agents

cmd_reference() {
  cat <<'EOF'
# Mind Palace CLI Reference

IMPORTANT: Use ONLY mp commands via Bash. Do NOT use Read, Edit, Write, Glob, or Grep tools.

## Commands

~/.mind-palace/mp search <query>      # Search memories
~/.mind-palace/mp list [type]         # List memories
~/.mind-palace/mp read <path>         # Read file
~/.mind-palace/mp write <path> <text> # Write file
~/.mind-palace/mp add <type> <name>   # Create memory (user|project|self|session)
~/.mind-palace/mp remove <path>       # Remove file/directory

All paths are relative to ~/.mind-palace (e.g., `mp read user/index.md`).

## Writing Content

Pass content as positional argument (not stdin):

~/.mind-palace/mp write <path> 'content here
multiline works'

Escape single quotes: 'it'\''s working'

## Session Writes

Use $MIND_PALACE_SESSION_NAME for current session:

~/.mind-palace/mp write sessions/$MIND_PALACE_SESSION_NAME/topic.md 'content'

## Important

- ONLY use ~/.mind-palace/mp commands
- Paths are relative (user/index.md, not ~/.mind-palace/user/index.md)
- Return concise summaries to main agent, not full file contents
EOF
}
