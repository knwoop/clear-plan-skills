# Plan Mode Output Format

When creating a plan in Plan Mode, use the following five-section format.

## Contents

1. [What](#1-what) — goal, done criteria, scope, why now
2. [Requirements](#2-requirements) — rules and constraints
3. [TODO](#3-todo) — tasks grouped by module/directory, each with Done when / Verify
4. [References](#4-references) — files, PRs, documents
5. [Verification](#5-verification) — decision table, end-to-end check, test commands
6. [Complete Example](#complete-example)

## 1. What

The goal of this work. What we are trying to achieve and why.
This is not about how to implement it — it is the destination, not the route.
Write it so that anyone reading the plan understands the purpose at a glance.

```markdown
## What

<One sentence: what problem disappears when this is done?>

- Done: <observable acceptance criteria — how do you verify it works?>
- Scope: <what is included>
- Out of scope: <what is explicitly excluded and why>
- Why now: <what makes this the right time — urgency, dependency, opportunity>
```

### Writing Guidelines for What

- Lead with the problem being solved, not the solution or technology
- "Done" must be verifiable — a reviewer should be able to check it without asking
- Always state what is out of scope — prevents scope creep and sets expectations
- "Why now" prevents work that has no urgency from blocking what does
- Do not write a summary or overview — What is a decision tool, not a description

### Good vs Bad Examples

Bad (summary):
> Introduce Chromatic to host Storybook per PR and improve the review experience.

Good (decision tool):
> Eliminate the need for reviewers to run Storybook locally during PR review.
>
> - Done: Reviewers can view Storybook via a check link on the PR in Chromatic
> - Scope: web/farm and web/farm-shared (3 Storybooks)
> - Out of scope: Visual regression testing (snapshot diff detection)
> - Why now: Reviewer friction is a bottleneck for frontend PRs

## 2. Requirements

Specifications and constraints that shape the implementation.
This section answers "what are the rules?" — not "what are we building?" (that's What)
and not "how do we build it?" (that's TODO).

```markdown
## Requirements

- <status/state definitions, enums, transitions>
- <business rules or constraints>
- <integration points with existing systems>
- <non-functional requirements: performance, security, compatibility>
```

## 3. TODO

Group tasks by module or directory.
Each task specifies the target file, the implementation approach, what must be
true when it is done, and how to check it.
Include logic or code examples when the approach is non-trivial.

Each TODO is implemented in a fresh session after `/clear` and reviewed on its own,
so it carries its own acceptance criteria and verification:

- **Done when** — for the reviewer: observable behavior that must hold after the change.
  The reviewer checks the change against this list instead of reconstructing intent from the diff.
- **Verify** — for the implementing session: the command or check that proves
  the criteria hold before handing the change to review.

```markdown
## TODO

### <module_1>

- [ ] Task name
  → Target file and implementation approach
  → Include code examples as needed
  → Done when:
    - <observable behavior 1>
    - <observable behavior 2>
  → Verify: `<command that exercises the criteria>`

### <module_2>

- [ ] Task name
  → Implementation approach (can be multiple lines)
  → Details of conditions or logic:
    1. If condition A → Process A
    2. If condition B → Process B
  → Done when: Decision table rows #1–#3 hold
  → Verify: `<command>`
```

### TODO Writing Guidelines

- Each item should be independently implementable in one Claude Code session
- Specify the exact file path to create or modify
- When the approach involves branching logic, enumerate the conditions
- Code examples are encouraged for complex transformations or new patterns
- Order tasks by dependency — items that other tasks depend on come first

### Writing "Done when" and "Verify"

- Write observable behavior, not a restatement of the task.
  Bad: "SoftDeleteItem is implemented". Good: "Already DELETED item → returns AlreadyDeleted"
- "Tests pass" is not a criterion — it belongs in Verify, and only means something
  when the criteria say what the tests cover
- When the TODO implements decision table rows, reference them by number
  ("Decision table rows #1–#3 hold") instead of copying them. The table stays the single
  source, so updating a row updates every TODO that cites it
- Verify should be one command or a short, concrete manual check
  (e.g. "`curl -X DELETE /items/1` returns 204, then `GET /items` omits it")
- If you cannot write a meaningful "Done when", the TODO is too thin to review on its own —
  merge it into the task that first uses it (e.g. a bare field addition merges into
  the repository change that reads and writes it)

## 4. References

List related resources grouped by type: files in the codebase, PRs/commits,
and external documents. Include the reason each reference is relevant.

```markdown
## References

### Files

- `path/to/file` → Reason for reference
- `path/to/another` → Reference for similar implementation

### PRs / Commits

- https://github.com/org/repo/pull/123 → PR for similar feature
- https://github.com/org/repo/commit/abc123 → Reference implementation

### Documents

- https://notion.so/xxx → Design Doc
- https://example.com/yyy → External reference
```

## 5. Verification

Include a decision table (when applicable), the end-to-end check for the whole
feature, and test commands. Per-TODO checks live on each TODO; this section covers
what only holds once all TODOs are done.

### Decision Table

Use when the feature involves complex conditional logic.
The table helps both implementation and test case design.
Number the rows so TODOs can cite them in "Done when".

```markdown
### Decision Table

| # | Condition A | Condition B | Condition C | Expected Result |
|---|-------------|-------------|-------------|-----------------|
| 1 | Y           | Y           | -           | Result 1        |
| 2 | Y           | N           | Y           | Result 2        |
| 3 | N           | -           | -           | Result 3        |
```

### End-to-End Check

How to confirm the What section's "Done" once every TODO is complete.
Per-TODO checks can all pass while the pieces still fail to fit together.

```markdown
### End-to-End Check

<steps that exercise the feature through its real entry point>
```

### Test Commands

List commands to verify the implementation.
Adapt to the project's language and test framework.

```markdown
### Test Commands

<test runner command for the relevant module>
<lint or type-check command>
```

## Complete Example

```markdown
## What

Stop users from permanently losing items they deleted by accident.

- Done: A deleted item disappears from lists, can be restored within 30 days,
  and is purged automatically after that
- Scope: Item soft-delete, restore, and the 30-day purge job
- Out of scope: Bulk restore and an admin "trash" UI (no current demand)
- Why now: Accidental deletions are the top support ticket category this quarter

## Requirements

- ItemStatus: ACTIVE, DELETED
- Transition: ACTIVE → DELETED (via soft-delete), DELETED → ACTIVE (via restore)
- Items with DELETED status are excluded from list queries by default
- Soft-deleted items are permanently purged after 30 days

## TODO

### db

- [ ] Add nullable deleted_at column to items and the Item entity
  → `migrations/20261014_add_items_deleted_at.sql`, `src/domain/item.ts`
  → Nullable timestamp, no default; existing rows stay NULL
  → Done when:
    - Migration applies and rolls back cleanly
    - Existing items load with `deletedAt === null`
  → Verify: `npm run migrate && npm run migrate:rollback && npm run migrate && npm test -- --grep "Item"`

### repository

- [ ] Filter soft-deleted records and add soft-delete / restore methods to ItemRepository
  → `src/repository/item_repository.ts`
  → Add `WHERE deleted_at IS NULL` to list query
  → Add `softDelete(id)` (sets deleted_at to now) and `restore(id)` (clears it)
  → Done when:
    - `list()` omits items whose deleted_at is set
    - `softDelete` then `restore` returns the item to `list()` results
  → Verify: `npm test -- --grep "ItemRepository"`

### usecase

- [ ] Implement SoftDeleteItem usecase
  → `src/usecase/soft_delete_item.ts` (replaces the hard delete in `src/usecase/delete_item.ts`)
  → Validate item exists and is ACTIVE before soft-deleting
  → Done when: Decision table rows #1–#3 hold
  → Verify: `npm test -- --grep "SoftDeleteItem"`

- [ ] Implement RestoreItem usecase
  → `src/usecase/restore_item.ts`
  → Validate item exists and is DELETED before restoring
  → Done when: Decision table rows #4–#6 hold
  → Verify: `npm test -- --grep "RestoreItem"`

### job

- [ ] Add PurgeDeletedItems job
  → `src/job/purge_deleted_items.ts`
  → Hard-delete rows where `deleted_at < now() - interval '30 days'`; register in the daily scheduler
  → Done when:
    - Items deleted more than 30 days ago are removed
    - Items deleted 30 days ago or less are kept
    - ACTIVE items are untouched
  → Verify: `npm test -- --grep "PurgeDeletedItems"`

## References

### Files

- `src/domain/item.ts` → Existing Item entity definition
- `src/repository/item_repository.ts` → Current repository implementation
- `src/usecase/delete_item.ts` → Current hard-delete implementation to replace

### PRs / Commits

- https://github.com/user/repo/pull/42 → Similar soft-delete for User entity

### Documents

- https://notion.so/item-soft-delete-design → Design Doc

## Verification

### Decision Table

| # | Item Exists | Item Status | Action      | Expected Result             |
|---|-------------|-------------|-------------|-----------------------------|
| 1 | Y           | ACTIVE      | SoftDelete  | Set deleted_at, return OK   |
| 2 | Y           | DELETED     | SoftDelete  | Return AlreadyDeleted       |
| 3 | N           | -           | SoftDelete  | Return NotFound             |
| 4 | Y           | DELETED     | Restore     | Clear deleted_at, return OK |
| 5 | Y           | ACTIVE      | Restore     | Return AlreadyActive        |
| 6 | N           | -           | Restore     | Return NotFound             |

### End-to-End Check

1. Delete an item via the API → it disappears from the item list
2. Restore it → it reappears in the list
3. Run the purge job with the clock set 31 days ahead → a deleted item is gone and restore returns NotFound

### Test Commands

npm test
npm run lint
```
