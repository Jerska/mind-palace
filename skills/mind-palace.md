# Mind Palace Skill

You have access to a memory system at ~/.mind-palace.

## When to Query Memories

- At session start: check for relevant project/user memories
- Before deep dives: see if prior exploration exists
- When context feels incomplete: search for related memories
- When user references past conversations: check session memories

## How to Search

Use bash:
```bash
~/.mind-palace/mp search "query"
```

Results show memory paths and matching snippets.

## How to Read Memories

Spawn a sub-agent to keep your context lean:

```
Task: "Read memory at ~/.mind-palace/projects/X/index.md.
      User wants to know: <specific question>.
      Return ONLY relevant info, under 100 words, except if you consider it absolutely necessary to go beyond this limit."
```

## When to Create/Update Memories

- After significant code exploration: update project memories
- When learning user preferences: update user memories
- When asked to remember something: create appropriate memory

To create:
```bash
~/.mind-palace/mp add <type> <name>
# Types: user, project, self, session
```

Then edit the generated index.md.

## CLI Reference

```bash
mp search <query>       # Search memories
mp add <type> <name>    # Create memory (types: user|project|self|session)
mp link <from> <to>     # Create symlink between memories
mp unlink <from> <to>   # Remove symlink
mp check                # Find broken symlinks
mp help                 # Show usage
```

## Memory Structure

Each memory is a folder with:
- `index.md` - Dense summary with frontmatter metadata
- Symlinks to related memories (siblings to index.md)

Keep memories concise: summaries with pointers to files/functions, not dumps.
