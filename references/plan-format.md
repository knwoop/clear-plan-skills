# Plan Mode Output Format

When creating a plan in Plan Mode, use the following five-section format.

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
Each task specifies the target file and implementation approach.
Include logic or code examples when the approach is non-trivial.

```markdown
## TODO

### <module_1>

- [ ] Task name
  → Target file and implementation approach
  → Include code examples as needed

### <module_2>

- [ ] Task name
  → Implementation approach (can be multiple lines)
  → Details of conditions or logic:
    1. If condition A → Process A
    2. If condition B → Process B
```

### TODO Writing Guidelines

- Each item should be independently implementable in one Claude Code session
- Specify the exact file path to create or modify
- When the approach involves branching logic, enumerate the conditions
- Code examples are encouraged for complex transformations or new patterns
- Order tasks by dependency — items that other tasks depend on come first

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

Include a decision table (when applicable) and test commands.

### Decision Table

Use when the feature involves complex conditional logic.
The table helps both implementation and test case design.

```markdown
### Decision Table

| Condition A | Condition B | Condition C | Expected Result |
|-------------|-------------|-------------|-----------------|
| Y           | Y           | -           | Result 1        |
| Y           | N           | Y           | Result 2        |
| N           | -           | -           | Result 3        |
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

Allow items to be recoverable after deletion. Currently, deleting an item
is permanent and irreversible — users who accidentally delete an item lose
it forever. By introducing soft-delete, deleted items are hidden from
normal listing but retained in the database for 30 days, during which
they can be restored. Done means: users can delete and restore items,
and hard-deleted data is automatically cleaned up after the retention period.

## Requirements

- ItemStatus: ACTIVE, DELETED
- Transition: ACTIVE → DELETED (via soft-delete), DELETED → ACTIVE (via restore)
- Items with DELETED status are excluded from list queries by default
- Soft-deleted items are permanently purged after 30 days

## TODO

### domain

- [ ] Add deleted_at field to Item entity
  → `src/domain/item.ts`
  → Add nullable timestamp field for soft-delete tracking

### repository

- [ ] Update ItemRepository to filter soft-deleted records
  → `src/repository/item_repository.ts`
  → Add `WHERE deleted_at IS NULL` to list query
  → Add soft_delete method that sets deleted_at to current timestamp

### usecase

- [ ] Implement SoftDeleteItem usecase
  → `src/usecase/soft_delete_item.ts`
  → Validate item exists and is ACTIVE before soft-deleting
  → Return appropriate error if item is already deleted

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

| Item Exists | Item Status | Action      | Expected Result            |
|-------------|-------------|-------------|----------------------------|
| Y           | ACTIVE      | SoftDelete  | Set deleted_at, return OK  |
| Y           | DELETED     | SoftDelete  | Return AlreadyDeleted      |
| N           | -           | SoftDelete  | Return NotFound            |
| Y           | DELETED     | Restore     | Clear deleted_at, return OK|
| Y           | ACTIVE      | Restore     | Return AlreadyActive       |

### Test Commands

npm test -- --grep "SoftDelete"
npm run lint
```
