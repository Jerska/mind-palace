---
name: mind-palace
description: Persistent memory system for Claude. Use when you need to read, write, or search memories about the user, projects, or yourself.
---

# Mind Palace Skill

Use this skill to interact with your persistent memory system.

## Direct Commands (search/list only)

```bash
~/.mind-palace/mp search "query"
~/.mind-palace/mp list [type]
```

## Read/Write Memory

**NEVER call `mp read` or `mp write` directly.** Always spawn a sub-agent to keep context lean.

### Read

```
Task: "Run ~/.mind-palace/mp reference to see CLI usage.
      ONLY use mp commands via Bash. Do NOT use Read, Glob, Grep, or any other tools.

      Operations: <list operations: search, list, read paths>
      User wants to know: <specific question>.

      Return ONLY relevant info, under 100 words."
```

Example: "Operations: search 'auth', read user, read projects/myapp"

### Write

```
Task: "Run ~/.mind-palace/mp reference to see CLI usage.
      ONLY use mp commands via Bash. Do NOT use Read, Glob, Grep, or any other tools.

      Write to <path>:
      <content>

      After writing, use mp search to find related memories and mp link if appropriate.
      Confirm when done."
```

## Session Writes

For current session, use path: `sessions/$MIND_PALACE_SESSION_NAME/<topic>.md`
