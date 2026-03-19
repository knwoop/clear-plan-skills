---
name: create-plan
description: >
  Create a structured implementation plan in Plan Mode and copy it to the
  clipboard. The plan follows a five-section format: What (goal/purpose),
  Requirements, TODO (grouped by module/directory), References, and
  Verification (with decision tables). Use this skill when the user asks to
  "plan a feature", "create a plan", "start planning", "break down a task",
  "create TODO", "plan mode output", or wants to structure implementation
  work before coding. After generating the plan, it is automatically copied
  to the clipboard so the user can paste it into their preferred note-taking app.
---

# Create Plan

Generate a structured implementation plan and copy it to the clipboard.

## When to Use

- Starting work on a new feature, bugfix, or refactoring task
- Breaking down a large task into independently executable TODO items
- Before entering the execution loop of clear-command-driven-dev

## Process

### Step 1: Gather Context

Before generating the plan, understand:

- What feature or task is being implemented?
- What is the codebase structure? (modules, layers, directories)
- Are there existing similar implementations to reference?
- What are the edge cases or conditional logic involved?

### Step 2: Generate the Plan

Output the plan following the format in [references/plan-format.md](../../references/plan-format.md).

Key points:
- Start with What — clarify the goal and why it matters before diving into details
- Group TODOs by module/directory
- Order tasks by dependency (upstream tasks first)
- Each TODO must be completable in a single Claude Code session
- Include code examples for non-trivial logic
- Add a decision table when conditional logic is complex
- List all relevant files, PRs, and documents in References

### Step 3: Copy to Clipboard

After generating the plan, copy it to the clipboard using the platform-appropriate command:
- macOS: `pbcopy`
- Linux (X11): `xclip -selection clipboard` or `xsel --clipboard --input`
- Linux (Wayland): `wl-copy`
- WSL: `clip.exe`

Always inform the user that the plan has been copied to their clipboard
so they can paste it into their preferred note-taking app.

## Output Format

See [references/plan-format.md](../../references/plan-format.md) for the complete
format specification with examples.

## Guidelines

- Write TODO items as imperative actions: "Add field X to struct Y", not "Field X should be added"
- Target file paths should be explicit: `src/repository/item_repository.ts`, not "the item repository"
- Code examples in TODOs should be minimal but sufficient to convey the approach
- Decision tables should cover all meaningful combinations, use `-` for "don't care" conditions
- References should include the reason each resource is relevant
