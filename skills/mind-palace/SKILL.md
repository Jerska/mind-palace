---
name: mind-palace
description: Persistent memory system for Claude. Use when you need to read, write, or search memories about the user, projects, or yourself.
---

# Mind Palace Skill

Use this skill to interact with your persistent memory system.

## Search (run directly)

```bash
~/.mind-palace/mp search "query"
~/.mind-palace/mp list [type]
```

## Read Memory

Spawn a sub-agent to keep your context lean:

```
Task: "Read mind-palace memory at <path>.
      First read ~/.mind-palace/skills/mind-palace/cli-reference.md for CLI usage.
      User wants to know: <specific question>.
      Return ONLY relevant info, under 100 words."
```

## Write Memory

Spawn a sub-agent:

```
Task: "Write to mind-palace at <path>.
      First read ~/.mind-palace/skills/mind-palace/cli-reference.md for CLI usage.
      Content to write:
      <content>
      Confirm when done."
```

## Session Writes

For current session, use path: `sessions/$MIND_PALACE_SESSION_NAME/<topic>.md`
