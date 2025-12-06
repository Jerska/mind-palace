---
name: mind-palace
description: |
      Persistent memory system.
      Use whenever:
      1. the user references something from a previous conversation (plans, decisions, prior work)
      2. before searching the codebase for context - check if prior exploration exists in memories
      3. you become aware of new information, either provided by the user or discovered on your own (e.g. during an analysis or planning phase)
      4. you complete a task or make significant progress - record it in sessions/
---

# Mind Palace Skill

Use this skill to interact with your persistent memory system.

## Model Selection

- **haiku**: Simple reads, single file lookups
- **sonnet/opus**: Writes, multi-file operations (including search), aggregation

## Direct Commands (search/list only)

NEVER run tools on the ~/.mind-palace folder (because this triggers a permission prompt).
To list, access, modify or even remove files in this folder, you MUST use `~/.mind-palace/mp` or spawn a Task as described below.

```bash
~/.mind-palace/mp search "query"
~/.mind-palace/mp list            # List all (excludes sessions)
~/.mind-palace/mp list sessions   # List sessions
```

Run `~/.mind-palace/mp reference` if the tools listed here are not enough for you.

## Read/Write Memory

**NEVER call `mp read` or `mp write` directly.** Always spawn a sub-agent to keep context lean.

### Read

```
Task: "## Rules
      FORBIDDEN: All tools except Bash(~/.mind-palace/mp:*)

      ## Setup
      Run: ~/.mind-palace/mp reference

      ## Task
      Operations: <list operations: search, list, read paths>
      User wants to know: <specific question>

      ## Output
      Return ONLY relevant info, under 100 words."
```

Example: "Operations: search 'auth', read user, read projects/myapp"

### Write

```
Task: "## Rules
      FORBIDDEN: All tools except Bash(~/.mind-palace/mp:*)

      ## Setup
      Run: ~/.mind-palace/mp reference

      ## Task
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

      ## Output
      Confirm when done, listing all memoies updated and any links created."
```

## Session Writes

For current session, use path: `sessions/$MIND_PALACE_SESSION_NAME/<topic>.md`
