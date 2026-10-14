# Plan Mode Output Format

When creating a plan in Plan Mode, use the following five-section format.

## Contents

1. [What](#1-what) — goal, done criteria, scope, why now
2. [Requirements](#2-requirements) — rules and constraints
3. [TODO](#3-todo) — PRs, each split into layer TODOs (DDL, domain, repository, …) with Done when / Verify
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

Group the work into PRs, and split each PR into TODOs by layer:

- **PR** — the review and merge unit. One purpose, stated in one line, that a reviewer
  can review in one sitting and that can merge and deploy on its own
- **Layer** — inside a PR, one heading per layer in dependency order. One TODO changes
  one layer, so each TODO is reviewed with one kind of expertise (migration safety for
  DDL, business rules for usecases, API contracts for handlers)

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

### PR 1: <scope>: <one-line purpose>

#### <layer_1> (e.g. DDL)

- [ ] Task name
  → Target file and implementation approach
  → Include code examples as needed
  → Done when:
    - <observable behavior 1>
    - <observable behavior 2>
  → Verify: `<command that exercises the criteria>`

### PR 2: <scope>: <one-line purpose>

→ Starts after: <only if gated on something beyond PR order, e.g. PR 1 released>

#### <layer_2> (e.g. usecase)

- [ ] Task name
  → Implementation approach (can be multiple lines)
  → Done when:

    | <Condition A>? | <Condition B>? | Expected Result |
    |----------------|----------------|-----------------|
    | Y              | Y              | Result 1        |
    | Y              | N              | Result 2        |
    | N              | -              | Result 3        |

  → Verify: `<command>` (one test case per row)
```

### Splitting into PRs

- **One purpose per PR.** Write the heading as `PR <n>: <scope>: <one-line purpose>`,
  where the purpose says what changes for users or operators, not which files change
- **Each PR merges and deploys on its own** — tests pass and nothing is half-wired
  after it merges. Number PRs in dependency order
- **Give DDL its own PR** when the migration must be deployed before the code that
  uses it, or when your team reviews migrations separately
- **Split a feature across PRs by behavior**, e.g. soft-delete in one PR and restore
  in the next, each going through all the layers it needs
- **Add "Starts after"** only when a PR waits on something other than the previous PR
  merging (a release, a metric, a manual step)
- **A small task is still `PR 1`** — keep the heading so the structure stays the same

### Splitting by Layer

- **Use the project's layers.** Take the layer list from the codebase
  (e.g. `migrations/`, `internal/domain`, `internal/repository`, `internal/usecase`,
  `internal/handler`), not from a template. For projects without application layers,
  use the equivalent units of responsibility (e.g. Terraform module, CI config, app code)
- **Order layer headings by dependency within each PR.** A typical order is
  DDL → domain → repository → usecase → handler → job / infra
- **One TODO changes one layer.** Never mix DDL with application code in one TODO —
  migrations are reviewed for locks, backward compatibility, and rollback, and often
  deploy separately
- **Split a large layer change by feature within that layer**, not across layers;
  if the PR is still too large to review in one sitting, split the PR
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
  row by row and the implementing session writes one test case per row.
  See [Decision Tables](#decision-tables) below
- When a rule applies to several TODOs (e.g. a permission matrix every endpoint
  must follow), do not copy the table into each one. Put it under Verification →
  Shared Decision Tables and cite it ("Done when: Shared table *Permissions* rows #1–#4 hold")
- Verify should be one command or a short, concrete manual check
  (e.g. "`curl -X DELETE /items/1` returns 204, then `GET /items` omits it")
- A layer-only TODO is fine as long as its "Done when" can be checked at that layer.
  If even that is impossible (e.g. a constant nothing reads yet), merge it into the
  TODO in the same layer that first uses it

### Decision Tables

- **Every condition is a yes/no question.** Name the column as a question ending in `?`
  ("Item exists?", "Session expired?") and fill cells with `Y`, `N`, or `-` (don't care).
  Labels like "valid / expired" or "ACTIVE / DELETED" leave room for interpretation;
  a yes/no answer does not
- **Give every question an exact threshold.** "Session expired?" must be defined
  precisely somewhere — "`auth_time + 3 days - 5 min` has passed", not "a few minutes".
  A reviewer must be able to answer Y or N for any input
- **Cover every combination exactly once.** With n questions there are 2^n combinations;
  after expanding `-`, each must match exactly one row. Counting rows this way is how
  the reviewer spots gaps
- **Order columns so earlier answers make later ones irrelevant** (e.g. "Item exists?"
  before "Already deleted?"), which keeps `-` doing the work instead of extra rows
- **Write impossible combinations as rows**, with the result `— (cannot happen: <reason>)`,
  so the reviewer can see they were considered
- **Results stay free text.** If a row triggers several actions, list them all
- **Mapping tables are the exception.** When the table maps one value to another
  (usecase result → HTTP status), use value columns instead of questions
- **Scope the table to one TODO.** A column that only says which TODO or which moment
  a row belongs to ("Action", "When") means the table should be split per TODO

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
If the rows split cleanly by TODO or by moment ("before render" vs "before send"),
the table is not shared — move each part into its TODO.

```markdown
### Shared Decision Tables

#### Permissions

| # | Admin? | Member of the team? | Owns resource? | Expected Result  |
|---|--------|---------------------|----------------|------------------|
| 1 | Y      | -                   | -              | Allow            |
| 2 | N      | Y                   | Y              | Allow            |
| 3 | N      | Y                   | N              | Return Forbidden |
| 4 | N      | N                   | -              | Return Forbidden |
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

### PR 1: items: add deleted_at column

#### DDL

- [ ] Add nullable deleted_at column to items
  → `migrations/20261014_add_items_deleted_at.sql`
  → Nullable timestamp, no default (no table rewrite, no backfill); add index on deleted_at for the purge job
  → Done when:
    - Migration applies and rolls back cleanly
    - Existing rows have `deleted_at = NULL`
    - Index `items_deleted_at_idx` exists
  → Verify: `npm run migrate && npm run migrate:rollback && npm run migrate`

### PR 2: items: deleting an item hides it instead of removing it

#### domain

- [ ] Add deletedAt to the Item entity
  → `src/domain/item.ts`
  → Nullable `Date`; derive `status` (ACTIVE / DELETED) from it
  → Done when:
    - Item with `deletedAt === null` has status ACTIVE
    - Item with `deletedAt` set has status DELETED
  → Verify: `npm test -- --grep "Item entity"`

#### repository

- [ ] Filter soft-deleted records and add softDelete to ItemRepository
  → `src/repository/item_repository.ts`
  → Add `WHERE deleted_at IS NULL` to list query
  → Add `softDelete(id)` that sets deleted_at to now
  → Done when:
    - `list()` omits items whose deleted_at is set
    - `softDelete` sets deleted_at and leaves the row in the table
  → Verify: `npm test -- --grep "ItemRepository"`

#### usecase

- [ ] Implement SoftDeleteItem usecase
  → `src/usecase/soft_delete_item.ts` (replaces the hard delete in `src/usecase/delete_item.ts`)
  → Done when:

    | Item exists? | Already deleted? | Expected Result           |
    |--------------|------------------|---------------------------|
    | Y            | N                | Set deleted_at, return OK |
    | Y            | Y                | Return AlreadyDeleted     |
    | N            | -                | Return NotFound           |

  → Verify: `npm test -- --grep "SoftDeleteItem"`

#### handler

- [ ] Route DELETE /items/:id to SoftDeleteItem
  → `src/handler/item_handler.ts`
  → Done when (mapping):

    | Usecase Result | Response |
    |----------------|----------|
    | OK             | 204      |
    | AlreadyDeleted | 409      |
    | NotFound       | 404      |

  → Verify: `npm test -- --grep "item_handler delete"`

### PR 3: items: restore a deleted item

#### repository

- [ ] Add restore to ItemRepository
  → `src/repository/item_repository.ts`
  → Add `restore(id)` that clears deleted_at
  → Done when: `softDelete` then `restore` returns the item to `list()` results
  → Verify: `npm test -- --grep "ItemRepository"`

#### usecase

- [ ] Implement RestoreItem usecase
  → `src/usecase/restore_item.ts`
  → Done when:

    | Item exists? | Deleted? | Expected Result             |
    |--------------|----------|-----------------------------|
    | Y            | Y        | Clear deleted_at, return OK |
    | Y            | N        | Return AlreadyActive        |
    | N            | -        | Return NotFound             |

  → Verify: `npm test -- --grep "RestoreItem"`

#### handler

- [ ] Add POST /items/:id/restore
  → `src/handler/item_handler.ts`
  → Done when (mapping):

    | Usecase Result | Response   |
    |----------------|------------|
    | OK             | 200 + item |
    | AlreadyActive  | 409        |
    | NotFound       | 404        |

  → Verify: `npm test -- --grep "item_handler restore"`

### PR 4: items: purge items deleted more than 30 days ago

→ Starts after: PR 3 released, so users can still restore within the 30 days

#### job

- [ ] Add PurgeDeletedItems job
  → `src/job/purge_deleted_items.ts`
  → Hard-delete rows where `deleted_at < now() - interval '30 days'`; register in the daily scheduler
  → Done when:

    | Deleted? | `deleted_at` older than 30 days (720 h)? | Expected Result |
    |----------|------------------------------------------|-----------------|
    | N        | -                                        | Keep            |
    | Y        | N                                        | Keep            |
    | Y        | Y                                        | Remove the row  |

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
