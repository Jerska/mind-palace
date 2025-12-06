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
~/.mind-palace/mp rename <from> <to># Rename/move memory (updates symlinks)
~/.mind-palace/mp link <from> <to>  # Create symlink between memories
~/.mind-palace/mp unlink <from> <to># Remove symlink
~/.mind-palace/mp check             # Find broken symlinks
~/.mind-palace/mp session check     # Check if session exists
~/.mind-palace/mp session list      # List saved sessions
~/.mind-palace/mp session clean     # Remove old sessions (default: >7 days)
~/.mind-palace/mp help              # Show usage
```

All paths are relative to ~/.mind-palace (e.g., `mp read user/preferences/index.md`).

## Environment Variables

Set automatically by SessionStart hook:
- `MIND_PALACE_SESSION_ID` - Claude Code's session identifier
- `MIND_PALACE_SESSION_NAME` - Session folder name (e.g., `2025-12-06_08-00_abc123`)
- `MIND_PALACE_RESTORED` - Set to "1" if resuming after context compaction

## Sessions

Sessions are created automatically at startup. Use `$MIND_PALACE_SESSION_NAME` to write to the current session:

```bash
~/.mind-palace/mp write sessions/$MIND_PALACE_SESSION_NAME/topic.md 'content here'
```

Sessions are a **working scratchpad** for transient context:
- Write summaries as you work, not just at the end
- Multiple topic files per session (e.g., `phase-2.md`, `debugging.md`)
- Temporary/in-progress information goes here

**Permanent learnings** should go directly to the appropriate memory:
- User preferences → `user/`
- Project knowledge → `projects/`
- Claude learnings → `self/`

## When to Query Memories

- At session start: check for relevant project/user memories
- Before deep dives: see if prior exploration exists
- When context feels incomplete: search for related memories
- After compaction: if `MIND_PALACE_RESTORED=1`, read session files for context

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

Write content (pass as argument to avoid heredoc permission issues):
```bash
~/.mind-palace/mp write <path> 'content here
multiline works'
```
Note: to include a single quote, end the string, add `\'`, then start a new string: `'it'\''s working'`

Remove memory:
```bash
~/.mind-palace/mp remove <path>
```

## When to Update Memories

### user/
- Learning user preferences or workflows
- Discovering how the user likes to communicate
- When explicitly told "remember that I..."

### self/
- Discovering Claude's strengths or limitations
- Learning effective patterns for specific tasks
- Meta-observations about what works/doesn't

### projects/
- Key files, commands, or conventions change
- Finding important project files - add to Pointers
- Learning project structure or architecture
- After significant code exploration

### sessions/
- Quick notes, work-in-progress
- Context that won't matter after session ends
- Will be cleaned up after ~7 days

### projects/ (subfiles)
- Detailed analysis worth keeping permanently
- Write directly here, don't "graduate" from session later
- Example: `projects/X/feature-design.md` for deep dive documentation
- Update index.md to point to subfiles

## Memory in Task Planning

When planning tasks with TODOs, include memory operations:
- **Start**: "Check memories for <relevant context>" (user prefs, project architecture, prior sessions)
- **End**: "Update memories with <learnings>" (new discoveries, decisions, conventions)

## Memory Structure

Each memory is a folder with:
- `index.md` - Small overview with pointers, kept concise
- Sub-files for detailed topics (e.g., `user/bash.md`, `user/communication.md`)
- Symlinks to related memories

Keep `index.md` as a summary with pointers to sub-files. Create sub-memories for specific topics rather than growing index.md.
