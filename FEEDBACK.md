# Mind Palace - Claude UX Feedback

Feedback on using the `mp` tool as Claude.

## What Works Well

- **Permission bypass**: `mp read/write/remove` avoids constant permission prompts. Essential.
- **Relative paths**: Not having to think about `~/.mind-palace/` prefix in paths.
- **Search grouping**: Multiple matches from same memory shown together.
- **List with titles**: Seeing memory titles helps pick the right one.

## Pain Points

### No append command
To add to a memory, I must:
1. `mp read` the whole file
2. Hold content in context
3. `mp write` with old content + new content

An `mp append` would save context and reduce errors.

### mp add then mp read dance
After `mp add`, I need to `mp read` to see the template before I can write meaningful content. Could `mp add` just output the template directly? Or have a `--edit` flag that outputs the template for immediate modification?

## Minor Observations

- `~/.mind-palace/mp` is long but necessary for whitelist pattern
- Template placeholder text ("Brief summary (2-5 sentences)...") is helpful but adds noise when I write over it

## Feature Requests

1. `mp append <path>` - append stdin to file
2. `mp add --stdout` - output template to stdout instead of creating file (so I can pipe/modify)

