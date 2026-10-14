---
name: clear-command-driven-dev
description: >
  Explains a development workflow methodology: plan with Plan Mode, copy the
  plan to clipboard, execute TODOs one at a time with /clear between each task,
  and update the plan when new information emerges. Use this skill when the user
  asks about "clear command driven development", "clear-driven workflow",
  "how to structure Claude Code sessions", or wants an overview of the
  plan-clear-execute cycle. For creating a new plan, see /create-plan.
  For updating an existing plan, see /update-plan.
---

# Clear Command Driven Development

A workflow methodology: persist Plan Mode output externally, execute TODOs
one at a time with `/clear` between each, and continuously update the plan
as new information emerges. The 1M token context window is irrelevant —
small, focused context produces better results.

## Core Principles

1. **Plan first, code later** — Always start in Plan Mode to design before implementing
2. **Externalize memory** — Your note app is the persistent store; Claude's context is ephemeral
3. **One TODO, one session** — Each `/clear` resets context; each task gets full attention
4. **Living plans** — Plans are updated as implementation reveals new information

## The Cycle

```
Plan Mode ──→ Copy to clipboard ──→ Paste into your notes
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

## Related Skills

| Skill | When to use |
|-------|-------------|
| `/create-plan` | Start a new plan for a feature or task |
| `/update-plan` | Revise an existing plan based on new findings |

## Execution Tips

- **Context loading**: When starting a TODO, provide only what Claude needs —
  the specific task (including its "Done when" and "Verify"), its target files,
  relevant references, and any shared decision table rows it cites. Do not paste the entire plan.
- **CLAUDE.md synergy**: Project-wide conventions belong in CLAUDE.md; task-level
  planning lives in your external notes. Do not duplicate.
- **Verify before commit**: Run the TODO's "Verify" step and confirm each
  "Done when" item holds before committing. Reviewers check the change against
  the same list.
- **Commit cadence**: Commit after each TODO completion, before `/clear`.
- **Update before clear**: If you discover something unexpected, run `/update-plan`
  while the context is still available, then `/clear` after committing.
- **Granularity**: Each TODO item should be completable in a single Claude Code
  session (roughly 10–30 minutes of implementation).

## Anti-Patterns

- Pasting the entire plan into every session (defeats the purpose of `/clear`)
- Skipping the plan update phase when encountering surprises
- Mixing layers in one TODO (DDL and application code together are hard to review)
- PRs with more than one purpose (if the heading needs "and", split the PR)
- Making TODO items too large (split a big layer change by feature within that layer)
- Keeping stale plans — always reflect reality in your notes
