---
name: update-plan
description: >
  Update an existing implementation plan based on new information discovered
  during development. Merges the user's current plan with new findings
  (edge cases, API changes, scope changes, discovered dependencies) and
  outputs an updated plan, then copies it to the clipboard. Use this skill
  when the user says "update the plan", "revise the plan", "plan changed",
  "found a new edge case", "the approach needs to change", "replan",
  "adjust TODO", or pastes an existing plan and describes what changed.
  Also trigger when the user reports implementation surprises, blockers,
  or scope adjustments that affect the plan.
---

# Update Plan

Revise an existing plan based on new information and copy the updated
version to the clipboard.

## When to Use

- During the execution loop, when implementation reveals something unexpected
- After code review feedback that changes scope or approach
- When a dependency or API behaves differently than expected
- When TODO items need to be split, reordered, or removed
- After discussing with team members and adjusting requirements

## Process

### Step 1: Receive the Current Plan and Changes

The user provides:

1. **The current plan** — pasted from their notes (full or partial)
2. **What changed** — described in natural language

Common types of changes:

| Change Type | Example |
|---|---|
| New edge case | "The API returns 404 when the resource is soft-deleted, we need to handle this" |
| Scope adjustment | "We decided not to implement restore for v1" |
| Approach change | "The ORM doesn't support bulk upsert, need to use raw SQL" |
| New dependency | "This requires a migration to add the deleted_at column first" |
| Task splitting | "The repository TODO is too large, needs to be split" |
| Completed items | "I finished the domain and repository tasks" |

### Step 2: Generate the Updated Plan

Apply the changes to the plan while following these rules:

1. **Preserve completed items** — Keep `[x]` items as-is for history
2. **Mark removed items** — Use ~~strikethrough~~ with a reason, don't silently delete
3. **Add new items at the correct dependency position** — not just appended at the end
4. **Update What** — if the goal or scope fundamentally changed, revise it
5. **Update the decision table** — if edge cases changed, the table must reflect it
6. **Update references** — add new files, PRs, or documents discovered during work
7. **Update requirements** — if the specifications or constraints changed

Output the full updated plan following the same five-section format
defined in [references/plan-format.md](../../references/plan-format.md).

### Step 3: Show the Diff Summary

Before the full plan, provide a brief summary of what changed:

```
### Plan Changes

- Added: <new TODO items or sections>
- Modified: <changed approach or scope>
- Removed: <items no longer needed, with reason>
- Reordered: <dependency changes>
```

This helps the user quickly verify the update matches their intent.

### Step 4: Copy to Clipboard

Copy the updated plan (without the diff summary) to the clipboard using
the same approach as create-plan:

- macOS: `pbcopy`
- Linux (X11): `xclip -selection clipboard` or `xsel --clipboard --input`
- Linux (Wayland): `wl-copy`
- WSL: `clip.exe`

Inform the user the updated plan is on their clipboard so they can replace
the old version in their notes.

## Guidelines

- Do not alter completed `[x]` items unless the user explicitly asks
- When splitting a TODO, preserve the original intent and add sub-tasks
- If the change invalidates a decision table row, update it — don't just add rows
- If the user provides only partial plan text, ask for the missing sections
  before generating the update (or note assumptions clearly)
- Keep the same format as the original plan — consistency matters for the workflow

## Plan Format Reference

See [references/plan-format.md](../../references/plan-format.md) for the complete
five-section format specification (What, Requirements, TODO, References, Verification).
