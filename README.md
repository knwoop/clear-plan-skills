# clear-plan-skills

**The 1M token context window is irrelevant — Clear Command Driven Development**

Design with Plan Mode, save to external notes, `/clear` before each TODO, and implement.
This repository provides that workflow as a set of Claude Code Skills.

## Workflow

```
Plan Mode ──→ Copy to clipboard ──→ Paste into your note app
                                          │
                ┌─────────────────────────┘
                ▼
         Pick a TODO item
                │
                ▼
         /clear ──→ Paste TODO + minimal context ──→ Implement
                │                                        │
                │              ┌─────────────────────────┘
                │              ▼
                │       Discovered something new?
                │         Yes ──→ /update-plan ──→ Update notes ──→ Commit ──→ /clear
                │          No ──→ Commit ──→ Mark TODO [x] ──→ /clear
                │              │
                └──────────────┘
```

**The idea**: Your context window is a workbench. Clear it before starting the next task.
Plans are persisted in your external notes, so `/clear` loses nothing.

## Skills

| Skill | Description |
|---|---|
| `create-plan` | Generate a plan in the 5-section format and copy it to the clipboard |
| `update-plan` | Revise an existing plan based on new findings and copy it to the clipboard |
| `clear-command-driven-dev` | Overview of the workflow philosophy and cycle |

### Plan Format (5 Sections)

1. **What** — Goal and purpose. What to achieve and why
2. **Requirements** — Specifications and constraints
3. **TODO** — Tasks grouped by module/directory
4. **References** — Related files, PRs, and documents
5. **Verification** — Decision tables and test commands

## Installation

### Claude Code Plugin (Recommended)

```bash
/plugin marketplace add knwoop/clear-plan-skills
/plugin install clear-plan-skills@knwoop-clear-plan-skills
```

### Manual Installation

```bash
git clone https://github.com/knwoop/clear-plan-skills.git
cp -r clear-plan-skills/skills/* ~/.claude/skills/
cp -r clear-plan-skills/references ~/.claude/skills/
```

## Usage

### 1. Create a Plan

Discuss a feature or task in Claude Code, then invoke `/create-plan`.
The plan is generated and copied to your clipboard — paste it into your favorite note app.

### 2. Execute a TODO

```
/clear
```

Pick one TODO from your notes, paste it into Claude Code along with the target file paths, and implement it.
Commit when done, then mark the TODO as `[x]` in your notes.

### 3. Update the Plan

When something unexpected comes up during implementation, invoke `/update-plan` **before** `/clear` —
the context from your current session is needed to generate the update.
The updated plan is copied to your clipboard — replace the old version in your notes, then commit and `/clear`.

### 4. Repeat

Repeat steps 2 and 3 until every TODO is `[x]`.

## License

MIT
