# Plan Mode Output Format

When creating a plan in Plan Mode, use the following five-section format.

## Contents

1. [What](#1-what) — goal, done criteria, scope, why now
2. [Requirements](#2-requirements) — rules and constraints
3. [TODO](#3-todo) — tasks split by layer (DDL, domain, repository, …), each with Done when / Verify
4. [References](#4-references) — files, PRs, documents
5. [Verification](#5-verification) — end-to-end check, test commands, shared decision tables
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

Split tasks by layer — one TODO changes one layer, so each TODO is reviewed
with one kind of expertise (migration safety for DDL, business rules for usecases,
API contracts for handlers). Headings name the layers in dependency order.
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

### <layer_1> (e.g. DDL)

- [ ] Task name
  → Target file and implementation approach
  → Include code examples as needed
  → Done when:
    - <observable behavior 1>
    - <observable behavior 2>
  → Verify: `<command that exercises the criteria>`

### <layer_2> (e.g. usecase)

- [ ] Task name
  → Implementation approach (can be multiple lines)
  → Done when:

    | Condition A | Condition B | Expected Result |
    |-------------|-------------|-----------------|
    | Y           | Y           | Result 1        |
    | Y           | N           | Result 2        |
    | N           | -           | Result 3        |

  → Verify: `<command>` (one test case per row)
```

### Splitting by Layer

- **Use the project's layers.** Take the layer list from the codebase
  (e.g. `migrations/`, `internal/domain`, `internal/repository`, `internal/usecase`,
  `internal/handler`), not from a template. For projects without application layers,
  use the equivalent units of responsibility (e.g. Terraform module, CI config, app code)
- **Order headings by dependency.** A typical order is
  DDL → domain → repository → usecase → handler → job / infra
- **One TODO changes one layer.** Never mix DDL with application code in one TODO —
  migrations are reviewed for locks, backward compatibility, and rollback, and often
  deploy separately
- **Split a large layer change by feature within that layer**, not across layers
  (e.g. two usecase TODOs: SoftDeleteItem and RestoreItem)
- **Write "Done when" at the layer's boundary** — what that layer exposes,
  tested with that layer's tests:

| Layer      | Done when (example)                                              | Verify                  |
|------------|------------------------------------------------------------------|-------------------------|
| DDL        | Migration applies and rolls back; column nullable; index exists  | migrate up / down / up  |
| Domain     | Entity exposes the new field; invalid states are rejected        | domain unit tests       |
| Repository | Query returns / omits the right rows                             | repository tests        |
| Usecase    | Decision table of business outcomes                              | usecase tests           |
| Handler    | Status code and body per outcome                                 | handler tests or `curl` |

### TODO Writing Guidelines

- Each item should be independently implementable in one Claude Code session
- Specify the exact file path to create or modify
- When the approach involves branching logic, put a decision table in "Done when"
  (see below) rather than listing the conditions in prose
- Code examples are encouraged for complex transformations or new patterns
- Order tasks by dependency — items that other tasks depend on come first

### Writing "Done when" and "Verify"

- Write observable behavior, not a restatement of the task.
  Bad: "SoftDeleteItem is implemented". Good: "Already DELETED item → returns AlreadyDeleted"
- "Tests pass" is not a criterion — it belongs in Verify, and only means something
  when the criteria say what the tests cover
- When the TODO involves conditional logic, write "Done when" as a decision table.
  It lists every case and its expected result, so the reviewer checks the change
  row by row and the implementing session writes one test case per row
  - Cover all meaningful combinations; use `-` for "don't care" conditions
  - Scope the table to this TODO only — columns that only distinguish between
    TODOs (such as an "Action" column) belong in separate TODOs' tables
- When a rule applies to several TODOs (e.g. a permission matrix every endpoint
  must follow), do not copy the table into each one. Put it under Verification →
  Shared Decision Tables and cite it ("Done when: Shared table *Permissions* rows #1–#4 hold")
- Verify should be one command or a short, concrete manual check
  (e.g. "`curl -X DELETE /items/1` returns 204, then `GET /items` omits it")
- A layer-only TODO is fine as long as its "Done when" can be checked at that layer.
  If even that is impossible (e.g. a constant nothing reads yet), merge it into the
  TODO in the same layer that first uses it

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

Per-TODO checks (including their decision tables) live on each TODO.
This section covers what only holds once all TODOs are done, plus any decision
table shared by several TODOs.

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

### Shared Decision Tables (only when needed)

Only for rules that several TODOs must follow. Name each table and number its rows
so TODOs can cite them. Omit this subsection when every table fits in one TODO.

```markdown
### Shared Decision Tables

#### Permissions

| # | Role   | Owns Resource | Expected Result |
|---|--------|---------------|-----------------|
| 1 | admin  | -             | Allow           |
| 2 | member | Y             | Allow           |
| 3 | member | N             | Return Forbidden|
| 4 | guest  | -             | Return Forbidden|
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

### DDL

- [ ] Add nullable deleted_at column to items
  → `migrations/20261014_add_items_deleted_at.sql`
  → Nullable timestamp, no default (no table rewrite, no backfill); add index on deleted_at for the purge job
  → Done when:
    - Migration applies and rolls back cleanly
    - Existing rows have `deleted_at = NULL`
    - Index `items_deleted_at_idx` exists
  → Verify: `npm run migrate && npm run migrate:rollback && npm run migrate`

### domain

- [ ] Add deletedAt to the Item entity
  → `src/domain/item.ts`
  → Nullable `Date`; derive `status` (ACTIVE / DELETED) from it
  → Done when:
    - Item with `deletedAt === null` has status ACTIVE
    - Item with `deletedAt` set has status DELETED
  → Verify: `npm test -- --grep "Item entity"`

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
  → Done when:

    | Item Exists | Item Status | Expected Result           |
    |-------------|-------------|---------------------------|
    | Y           | ACTIVE      | Set deleted_at, return OK |
    | Y           | DELETED     | Return AlreadyDeleted     |
    | N           | -           | Return NotFound           |

  → Verify: `npm test -- --grep "SoftDeleteItem"`

- [ ] Implement RestoreItem usecase
  → `src/usecase/restore_item.ts`
  → Validate item exists and is DELETED before restoring
  → Done when:

    | Item Exists | Item Status | Expected Result             |
    |-------------|-------------|-----------------------------|
    | Y           | DELETED     | Clear deleted_at, return OK |
    | Y           | ACTIVE      | Return AlreadyActive        |
    | N           | -           | Return NotFound             |

  → Verify: `npm test -- --grep "RestoreItem"`

### handler

- [ ] Expose soft-delete and restore endpoints
  → `src/handler/item_handler.ts`
  → `DELETE /items/:id` calls SoftDeleteItem; `POST /items/:id/restore` calls RestoreItem
  → Done when:

    | Endpoint                | Usecase Result | Response   |
    |-------------------------|----------------|------------|
    | DELETE /items/:id       | OK             | 204        |
    | DELETE /items/:id       | AlreadyDeleted | 409        |
    | POST /items/:id/restore | OK             | 200 + item |
    | POST /items/:id/restore | AlreadyActive  | 409        |
    | -                       | NotFound       | 404        |

  → Verify: `npm test -- --grep "item_handler"`

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

### End-to-End Check

1. Delete an item via the API → it disappears from the item list
2. Restore it → it reappears in the list
3. Run the purge job with the clock set 31 days ahead → a deleted item is gone and restore returns NotFound

### Test Commands

npm test
npm run lint
```
