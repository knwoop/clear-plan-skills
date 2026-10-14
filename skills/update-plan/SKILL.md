---
name: update-plan
description: >
  Updates an existing implementation plan based on new information discovered
  during development. Merges the user's current plan with new findings
  (edge cases, API changes, scope changes, discovered dependencies) and
  outputs an updated plan, then copies it to the clipboard. Use this skill
  when the user says "update the plan", "revise the plan", "plan changed",
  "found a new edge case", "the approach needs to change", "replan",
  "adjust TODO", or pastes an existing plan and describes what changed.
  Also trigger when the user reports implementation surprises, blockers,
  or scope adjustments that affect the plan.
argument-hint: "[what changed]"
---

# Update Plan

Revise an existing plan based on new information and copy the updated
version to the clipboard.

## IMPORTANT: Enter Plan Mode first

Before doing anything else, enter Plan Mode (use the `EnterPlanMode` tool if
you are not already in it). Do not write or modify any code.
Plan Mode allows you to explore the codebase read-only and revise the plan
without making changes.

## Process

### Step 1: Receive the Current Plan and Changes

What changed: $ARGUMENTS

If `$ARGUMENTS` is provided, use it as the description of what changed.
If empty, use the conversation context to understand the changes.
If neither provides enough detail, ask the user what changed.

The user provides:

1. **The current plan** — pasted from their notes (full or partial)
2. **What changed** — described in natural language

If the current plan is not provided in the conversation or arguments,
ask the user to choose:
- Paste the current plan
- Infer from conversation context

Common types of changes:

| Change Type | Example |
|---|---|
| New edge case | "The API returns 404 when the resource is soft-deleted, we need to handle this" |
| Scope adjustment | "We decided not to implement restore for v1" |
| Approach change | "The ORM doesn't support bulk upsert, need to use raw SQL" |
| New dependency | "This requires a migration to add the deleted_at column first" |
| Task splitting | "The repository TODO is too large, needs to be split" |
| Completed items | "I finished the domain and repository tasks" |
| Criteria change | "Restore should also work on items deleted by an admin" |

### Step 2: Generate the Updated Plan

Apply the changes to the plan while following these rules:

1. **Preserve completed items** — Keep `[x]` items as-is for history
2. **Mark removed items** — Use ~~strikethrough~~ with a reason, don't silently delete
3. **Add new items at the correct dependency position** — not just appended at the end
4. **Update What** — if the goal or scope fundamentally changed, revise it
5. **Update the decision tables** — if edge cases changed, update the table in the
   affected TODO's "Done when" (or the shared table, if several TODOs follow it)
6. **Update references** — add new files, PRs, or documents discovered during work
7. **Update requirements** — if the specifications or constraints changed
8. **Keep "Done when" and "Verify" in sync** — when a TODO's approach or scope changes,
   update its "Done when" and "Verify". When a shared decision table row is added,
   removed, or renumbered, update every open TODO that cites it. New TODOs need both fields

Output the full updated plan following the same five-section format.
The format specification is shared with create-plan; read it at
`${CLAUDE_SKILL_DIR}/../create-plan/references/plan-format.md`.

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

Copy the updated plan (without the diff summary) to the clipboard with the
clipboard script bundled in create-plan:

```bash
"${CLAUDE_SKILL_DIR}/../create-plan/scripts/copy-to-clipboard.sh" <<'PLAN_EOF'
<the updated plan>
PLAN_EOF
```

If the script exits non-zero (no clipboard tool available), output the plan
in a single fenced code block so the user can copy it manually.

Inform the user the updated plan is on their clipboard so they can replace
the old version in their notes.

## Guidelines

- Do not alter completed `[x]` items unless the user explicitly asks
- When splitting a TODO, preserve the original intent and add sub-tasks;
  divide the original "Done when" between them so no criterion is lost
- If the change invalidates a decision table row, update it — don't just add rows
- If the user provides only partial plan text, ask for the missing sections
  before generating the update (or note assumptions clearly)
- Keep the same format as the original plan — consistency matters for the workflow
