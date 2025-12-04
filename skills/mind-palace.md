# Mind Palace Skill

You have access to a memory system at ~/.mind-palace.

IMPORTANT: Always use `mp` commands for all memory operations. Do NOT use Read, Edit, Write, or rm tools on ~/.mind-palace files - use the mp CLI instead.

## CLI Reference

```bash
~/.mind-palace/mp search <query>    # Search memories
~/.mind-palace/mp list [type]       # List all memories (or filter by type)
~/.mind-palace/mp read <path>       # Read file contents
~/.mind-palace/mp add <type> <name> # Create memory (types: user|project|self|session)
~/.mind-palace/mp write <path>      # Write stdin to file
~/.mind-palace/mp remove <path>     # Remove file or directory
~/.mind-palace/mp link <from> <to>  # Create symlink between memories
~/.mind-palace/mp unlink <from> <to># Remove symlink
~/.mind-palace/mp check             # Find broken symlinks
~/.mind-palace/mp help              # Show usage
```

All paths are relative to ~/.mind-palace (e.g., `mp read user/preferences/index.md`).

## When to Query Memories

- At session start: check for relevant project/user memories
- Before deep dives: see if prior exploration exists
- When context feels incomplete: search for related memories
- When user references past conversations: check session memories

## How to Search

```bash
~/.mind-palace/mp search "query"
```

Results show memory paths and matching snippets.

## How to Read Memories

Spawn a sub-agent to keep your context lean:

```
Task: "Read memory using: ~/.mind-palace/mp read projects/X/index.md
      User wants to know: <specific question>.
      Return ONLY relevant info, under 100 words, except if absolutely necessary.
      IMPORTANT: Use mp read, NOT the Read tool."
```

## How to Create/Update Memories

Create new memory:
```bash
~/.mind-palace/mp add <type> <name>
# Then read the generated template:
~/.mind-palace/mp read <type>/<name>/index.md
```

Write content (use heredoc):
```bash
~/.mind-palace/mp write <path> <<'EOF'
content here
EOF
```

Remove memory:
```bash
~/.mind-palace/mp remove <path>
```

## When to Create/Update Memories

- After significant code exploration: update project memories
- When learning user preferences: update user memories
- When asked to remember something: create appropriate memory

## Memory Structure

Each memory is a folder with:
- `index.md` - Dense summary with frontmatter metadata
- Symlinks to related memories (siblings to index.md)

Keep memories concise: summaries with pointers to files/functions, not dumps.
