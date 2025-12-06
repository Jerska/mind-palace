# Mind Palace CLI Reference

Operational reference for executing `mp` commands via Bash.

IMPORTANT: `~/.mind-palace/mp` is a CLI tool. Run it with Bash, do NOT use the Read tool on it.

## Commands

```bash
~/.mind-palace/mp search <query>      # Search memories
~/.mind-palace/mp list                # List memories (excludes sessions)
~/.mind-palace/mp list [type]         # List specific type (user|project|self|session)
~/.mind-palace/mp read <path>         # Read file contents
~/.mind-palace/mp add <type> <name>   # Create memory (types: user|project|self|session)
~/.mind-palace/mp write <path> <text> # Write text to file
~/.mind-palace/mp remove <path>       # Remove file or directory
~/.mind-palace/mp rename <from> <to>  # Rename/move memory (updates symlinks)
~/.mind-palace/mp link <from> <to>    # Create symlink between memories
~/.mind-palace/mp unlink <from> <to>  # Remove symlink
~/.mind-palace/mp check               # Find broken symlinks
~/.mind-palace/mp session check       # Check if session exists
~/.mind-palace/mp session list        # List saved sessions
~/.mind-palace/mp session clean       # Remove old sessions (default: >7 days)
~/.mind-palace/mp help                # Show usage
```

All paths are relative to ~/.mind-palace (e.g., `mp read user/preferences/index.md`).

## Writing Content

Content is passed as a positional argument (not stdin):

```bash
~/.mind-palace/mp write <path> 'content here
multiline works'
```

**Escaping single quotes**: End the string, add `\'`, start new string:
```bash
~/.mind-palace/mp write path 'it'\''s working'
# Results in: it's working
```

**Why not stdin/heredoc**: Heredocs trigger permission prompts even when `mp:*` is allowed (Claude Code bug #11932).

## Creating Memories

```bash
# Create new memory (generates template)
~/.mind-palace/mp add <type> <name>

# Read the generated template
~/.mind-palace/mp read <type>/<name>/index.md

# Write your content
~/.mind-palace/mp write <type>/<name>/index.md 'content'
```

Types: `user`, `project`, `self`, `session`

## Sessions

Sessions are created automatically at startup. Use the `$MIND_PALACE_SESSION_NAME` env var:

```bash
~/.mind-palace/mp write sessions/$MIND_PALACE_SESSION_NAME/topic.md 'content'
```

Session folder format: `YYYY-MM-DD_HH-MM_<session_id>`

## Environment Variables

Available in your shell:
- `MIND_PALACE_SESSION_ID` - Claude Code's session identifier
- `MIND_PALACE_SESSION_NAME` - Full session folder name
- `MIND_PALACE_RESTORED` - "1" if resuming after context compaction

## Important

- `~/.mind-palace/mp` is a Bash command - run it with Bash tool, never Read tool
- Paths passed to mp are relative (e.g., `user/index.md`, not `~/.mind-palace/user/index.md`)
- Return concise summaries to the main agent, not full file contents
