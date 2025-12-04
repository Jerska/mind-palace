# Mind Palace - Implementation Plan

A memory system for Claude Code that addresses context window limitations through dense summaries with detailed sources accessible on-demand.

## Design Principles

- **Low-tech**: Bash scripts, markdown files, filesystem links
- **Markdown as source of truth**: Search indexes are derived, rebuildable
- **Dense summaries, detailed sources**: Memories are pointers, not dumps
- **Sub-agent retrieval**: Keep main context lean by delegating reads
- **Swappable backends**: Start with grep, add SQLite/Algolia later

## Architecture Overview

```
~/.mind-palace/
  mp -> ~/.claude/plugins/marketplaces/jerska/mind-palace/bin/mp
  .config                         (backend settings, last update, etc.)

  user/                           (user memories)
    preferences/
      index.md
      personality -> ../personality/
    personality/
      index.md
    company/
      index.md
    skills/
      index.md

  self/                           (memories about Claude)
    strengths/
      index.md
    limitations/
      index.md

  projects/                       (per-project memories)
    jerska/
      mind-palace/
        index.md
        code-graph/
          index.md
          features/
            auth/
              index.md

  sessions/                       (temporary session memories)
    <session-id>/
      index.md
      context-snapshot.md

~/.claude/plugins/marketplaces/jerska/mind-palace/
  .claude-plugin/
    plugin.json
    marketplace.json
  bin/
    mp
  lib/
    commands/
      search.sh
      add.sh
      link.sh
      check.sh
      update.sh
      session.sh
    backends/
      grep.sh                     (v1 default)
      sqlite.sh                   (v2)
      algolia.sh                  (future)
    hooks/
      session-start.sh
      pre-compact.sh
  skills/
    mind-palace.md
  hooks/
    hooks.json                    (hook configuration)
  commands/
    mp-search.md
```

## Memory Structure

Each memory is a folder with:
- `index.md` - Dense summary with frontmatter metadata
- Symlinks to related memories (siblings to index.md)
- Additional files as needed (scripts, configs, examples)

### index.md Format

```markdown
---
type: project|user|self|session|code-graph
tags: [tag1, tag2]
created: 2025-12-04
updated: 2025-12-04
---

# Memory Title

Brief summary (2-5 sentences). What is this, why does it matter.

## Key Points
- Point 1
- Point 2

## Pointers
- File: `src/auth/index.ts`
- Function: `validateToken` in `src/auth/jwt.ts:42`
- See: [related-memory](related-memory)

## Related
- [other-memory](other-memory)
```

## CLI Commands

```bash
mp search <query>               # Search memories (uses configured backend)
mp search --backend=grep <q>    # Force specific backend
mp add <type> <name>            # Create new memory folder + index.md
mp link <from> <to>             # Create symlink between memories
mp unlink <from> <to>           # Remove symlink
mp check                        # Find broken symlinks
mp update                       # Git pull if stale
mp config [key] [value]         # Get/set config
mp help                         # Show help

# Session memory commands
mp session check                # Check for saved session state (uses $MIND_PALACE_SESSION_ID)
mp session save [session-id]    # Save context snapshot for session
mp session list                 # List saved sessions
mp session clean [--days=N]     # Remove sessions older than N days

# Backend-specific (when using indexed backends)
mp index                        # Rebuild search index
mp index <path>                 # Index specific memory
```

## Search Backends

### grep (v1 default)
- No index, no setup
- `grep -ri --include="*.md" "query" ~/.mind-palace`
- Good enough for hundreds of memories

### sqlite (v2)
- SQLite FTS5 full-text search
- Faster for large memory sets
- Requires `mp index` after changes

### algolia (future)
- Cloud-hosted search
- Requires API keys in config

Backend interface (each implements):
```bash
backend_search "$query"   # Returns: path, title, snippet
backend_index "$path"     # Index single memory (if applicable)
backend_reindex           # Full reindex (if applicable)
```

## Claude Code Integration

### Skill: mind-palace.md

```markdown
# Mind Palace Skill

You have access to a memory system at ~/.mind-palace.

## Session Restoration (IMPORTANT)

At session start, ALWAYS run:
~/.mind-palace/mp session check

If $MIND_PALACE_RESTORED is set, this means context was compacted and there may
be saved state. The command will tell you if saved context exists.

If saved context exists, spawn a sub-agent to read and summarize it:
Task: "Read session memory at <path>. Summarize key context: what was the user
      working on, what decisions were made, what's pending. Under 150 words."

## When to Query Memories

- At session start: check for relevant project/user memories
- Before deep dives: see if prior exploration exists
- When context feels incomplete: search for related memories
- When user references past conversations: check session memories

## How to Search

Use bash:
~/.mind-palace/mp search "query"

## How to Read Memories

Spawn a sub-agent to keep your context lean:

Task: "Read memory at ~/.mind-palace/projects/X/index.md.
      User wants to know: <specific question>.
      Return ONLY relevant info, under 100 words."

## When to Create/Update Memories

- After significant code exploration: update project code-graph
- When learning user preferences: update user memories
- Before context compaction: save key session state (automatic via hook)
- When asked to remember something: create appropriate memory

To create: ~/.mind-palace/mp add <type> <name>
Then edit the generated index.md.

## Environment Variables

These are set by hooks and available in bash:
- $MIND_PALACE_SESSION_ID - current session identifier
- $MIND_PALACE_RESTORED - set to "1" if resuming after context compaction
- $MIND_PALACE_SED - "gsed" on macOS, "sed" on Linux (for cross-platform scripts)
```

### Hooks

**hooks.json:**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "~/.mind-palace/lib/hooks/session-start.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "~/.mind-palace/lib/hooks/pre-compact.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

**lib/hooks/session-start.sh:**
```bash
#!/bin/bash
# Receives JSON via stdin with session_id, source, transcript_path, etc.
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
SOURCE=$(echo "$INPUT" | jq -r '.source')

# Make session ID available to subsequent bash commands
echo "MIND_PALACE_SESSION_ID=$SESSION_ID" >> "$CLAUDE_ENV_FILE"

# Set sed command (gsed on macOS, sed on Linux)
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "MIND_PALACE_SED=gsed" >> "$CLAUDE_ENV_FILE"
else
  echo "MIND_PALACE_SED=sed" >> "$CLAUDE_ENV_FILE"
fi

# Signal if resuming after compaction (so skill knows to check for saved state)
if [ "$SOURCE" = "compact" ]; then
  echo "MIND_PALACE_RESTORED=1" >> "$CLAUDE_ENV_FILE"
fi

# Auto-update if stale (quiet, non-blocking)
~/.mind-palace/mp update --quiet 2>/dev/null || true
```

**lib/hooks/pre-compact.sh:**
```bash
#!/bin/bash
# Save session state before context compaction
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path')

# Save session memory (transcript available for context extraction)
~/.mind-palace/mp session save "$SESSION_ID" --transcript="$TRANSCRIPT"
```

**Session restoration flow:**
1. PreCompact hook saves session state with `session_id`
2. After compaction, SessionStart fires with `source: "compact"`
3. Hook sets `MIND_PALACE_SESSION_ID` and `MIND_PALACE_RESTORED=1` in env
4. Skill instructs Claude to run `mp session check`
5. If saved state exists, sub-agent reads and summarizes it

### Slash Command: /mp-search

Quick search from conversation without typing full path.

## Sub-Agent Pattern

Main Claude calls:
```
Task: Read memory at <path>. Question: "<question>".
      Return ONLY relevant information, under 100 words.
```

Sub-agent reads full content, returns summary. Main context stays lean.

## Implementation Phases

### Phase 1: Core Foundation
- [x] Project structure (bin/, lib/, skills/, hooks/)
- [x] Compatibility check (OS detection, required tools)
- [x] CLI entry point with argument parsing
- [x] `mp add <type> <name>` - create memory folder + template
- [x] `mp search <query>` - grep-based search
- [x] `mp link <from> <to>` - create symlinks
- [x] `mp check` - find broken symlinks
- [x] `mp help` - usage info
- [x] Basic skill file
- [x] Installation script (runs compat check, creates ~/.mind-palace, symlink)

### Phase 2: Claude Code Plugin
- [ ] Plugin structure (plugin.json, marketplace.json)
- [ ] Hooks (SessionStart for auto-update)
- [ ] Slash command wrapper (/mp-search)
- [ ] `mp update` - git pull with staleness check
- [ ] `mp config` - manage settings

### Phase 3: Session Memory
- [ ] Session memory structure
- [ ] Hook for context snapshot (verify PreCompact exists)
- [ ] Session cleanup command
- [ ] Skill instructions for session use

### Phase 4: Search Backends
- [ ] Backend abstraction (interface in lib/backends/)
- [ ] SQLite FTS5 backend
- [ ] `mp index` command for indexed backends
- [ ] Backend configuration

### Phase 5: Code Discovery Graph
- [ ] Graph memory structure
- [ ] Integration patterns for code exploration
- [ ] Skill instructions for graph maintenance

### Phase 6: Polish
- [ ] Additional backends (Algolia, etc.)
- [ ] Memory templates per type
- [ ] Validation/linting
- [ ] Statistics

## Open Questions

1. ~~**PreCompact hook**: Does this exist?~~ ✓ Yes, fires before context compaction with `trigger` field.
2. ~~**Session ID in hooks**: How do hooks access session info?~~ ✓ Via stdin JSON (`session_id`, `transcript_path`). Persisted via `CLAUDE_ENV_FILE`.
3. **Code graph granularity**: File, class, function level?
4. **Shared memories**: Future support for team-shared?

## Supported Platforms

- macOS 10.15+
- Linux (Ubuntu 20.04+, Debian 10+, and similar)
- Windows via WSL (WSL 1 or WSL 2)

**Not supported:**
- Native Windows (PowerShell) - would require separate implementation
- Git for Windows (Git Bash) - untested, path handling issues likely

### Install-time Compatibility Check

```bash
#!/bin/bash
# lib/check-compat.sh

check_compatibility() {
  # Check OS
  case "$OSTYPE" in
    darwin*|linux*) ;;
    msys*|cygwin*|win32*)
      echo "Error: Native Windows is not supported."
      echo "Please use WSL (Windows Subsystem for Linux)."
      echo "See: https://docs.microsoft.com/en-us/windows/wsl/install"
      exit 1
      ;;
    *)
      echo "Warning: Unrecognized OS ($OSTYPE). Proceeding anyway."
      ;;
  esac

  # Check jq (required for JSON parsing in hooks)
  if ! command -v jq >/dev/null; then
    echo "Error: jq is required but not installed."
    [[ "$OSTYPE" == "darwin"* ]] && echo "Install with: brew install jq"
    exit 1
  fi

  # On macOS, require gsed (GNU sed) for consistent behavior
  if [[ "$OSTYPE" == "darwin"* ]] && ! command -v gsed >/dev/null; then
    echo "Error: gsed (GNU sed) is required on macOS."
    echo "Install with: brew install coreutils"
    exit 1
  fi

  # Check bash version (need 4+ for associative arrays, etc.)
  local bash_major="${BASH_VERSION%%.*}"
  if [ "$bash_major" -lt 4 ]; then
    echo "Warning: Bash $BASH_VERSION detected. Version 4+ recommended."
    echo "On macOS: brew install bash"
  fi
}

# Note: MIND_PALACE_SED is set by the SessionStart hook via CLAUDE_ENV_FILE
# Scripts should use $MIND_PALACE_SED instead of sed directly
```

## Installation (Post-Implementation)

```bash
# Add marketplace and install plugin
claude plugin marketplace add jerska/mind-palace
claude plugin install mind-palace

# Or manual setup
git clone https://github.com/jerska/mind-palace ~/.mind-palace-repo
~/.mind-palace-repo/install.sh

# Verify
~/.mind-palace/mp help

# Create first memory
~/.mind-palace/mp add user preferences
# Edit the generated index.md

# Search
~/.mind-palace/mp search "preferences"
```
