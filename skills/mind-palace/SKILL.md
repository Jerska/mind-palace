---
name: mind-palace
description: Persistent memory system for Claude. Use when you need to read, write, or search memories about the user, projects, or yourself.
---

# Mind Palace Skill

Use this skill to interact with your persistent memory system.

## Model Selection

- **haiku**: Simple reads, single file lookups
- **sonnet/opus**: Writes, multi-file operations, aggregation

## Direct Commands (search/list only)

```bash
~/.mind-palace/mp search "query"
~/.mind-palace/mp list            # List all (excludes sessions)
~/.mind-palace/mp list sessions   # List sessions
```

## Read/Write Memory

**NEVER call `mp read` or `mp write` directly.** Always spawn a sub-agent to keep context lean.

### Read

```
Task: "Run ~/.mind-palace/mp reference to see CLI usage.
      ONLY use mp commands via Bash. Do NOT use Read, Write, Edit, Glob, or Grep tools.

      Operations: <list operations: search, list, read paths>
      User wants to know: <specific question>.

      Return ONLY relevant info, under 100 words."
```

Example: "Operations: search 'auth', read user, read projects/myapp"

### Write

```
Task: "Run ~/.mind-palace/mp reference to see CLI usage.
      ONLY use mp commands via Bash. Do NOT use Read, Write, Edit, Glob, or Grep tools.

      Write to <path>:
      <content>

      After writing, find related memories:
      1. Run mp list to see all memories
      2. Search for 2-3 keywords from the content (mp search 'keyword')
      3. Review results - only link if genuinely related (not just keyword match)
      4. For same-folder links: add markdown links in a '## See Also' section
         (e.g., in self/limitations.md: 'See also: [strengths](strengths.md)')
      5. For cross-folder links: create bidirectional symlinks AND document:
         mp link <this-memory> <related-memory>
         mp link <related-memory> <this-memory>
         Then append '## Related' section to both files

      Confirm when done, listing any links created."
```

## Session Writes

For current session, use path: `sessions/$MIND_PALACE_SESSION_NAME/<topic>.md`
