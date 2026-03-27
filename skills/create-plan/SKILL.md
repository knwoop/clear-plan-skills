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

## IMPORTANT: Enter Plan Mode first

Before doing anything else, enter Plan Mode. Do not write or modify any code.
Plan Mode allows you to explore the codebase read-only and design the plan
without making changes.

## Phase 1: Receive Task

The user's request: $ARGUMENTS

If `$ARGUMENTS` is provided, use it as the initial task description.
If empty, ask the user what feature or task to plan.
Do not proceed to Phase 2 until you have a clear task description.

## Phase 2: Clarify Requirements

Use `AskUserQuestion` to interactively clarify the following:

- **Goal**: What is the desired outcome? What does "done" look like?
- **Scope**: Which modules, directories, or layers are involved?
- **Constraints**: Are there performance, compatibility, or deadline constraints?
- **Edge cases**: Are there known edge cases or conditional logic to handle?
- **References**: Are there related PRs, docs, or existing implementations to reference?

Ask one or two questions at a time. Do not overwhelm the user with all questions at once.
Continue until you have enough information to generate a solid plan.

## Phase 3: Research (Parallel Subagents)

Based on the task and requirements clarified in Phase 1-2, design and launch
subagents tailored to the specific research needs. Do not use a fixed set of agents —
decide what research is needed for this particular task.

### How to design agents

1. Identify the distinct areas of research needed (codebase, external docs, dependencies, etc.)
2. Create one agent per area, each with a focused responsibility
3. Choose the appropriate subagent_type for each:
   - `Explore` — for codebase exploration (file structure, existing code, patterns)
   - `Plan` — for analysis (dependencies, impact, implementation order)
   - Use `WebSearch` / `WebFetch` in agents that need to research external documentation
4. Launch all agents in parallel using the Agent tool
5. Pass each agent a summary of the task and clarified requirements

### Examples

**Example: Adding a new domain to CDN via GCS**
- Agent 1 (Explore): Search Terraform codebase for existing domain/bucket configurations
- Agent 2 (Explore + WebSearch): Research Fastly CDN configuration and official docs
- Agent 3 (Explore): Investigate GCS bucket setup patterns in the codebase
- Agent 4 (Plan): Analyze DNS, SSL, and deployment dependencies

**Example: Adding a REST API endpoint**
- Agent 1 (Explore): Find existing API endpoint patterns and conventions
- Agent 2 (Explore): Investigate DB schema and repository layer
- Agent 3 (Explore): Search for related test patterns and fixtures

**Example: Refactoring authentication middleware**
- Agent 1 (Explore): Map all usage of current auth middleware across the codebase
- Agent 2 (Plan): Analyze breaking changes and migration path
- Agent 3 (Explore + WebSearch): Research the target auth library's official docs

Wait for all agents to complete before proceeding to Phase 4.

## Phase 4: Present Draft Plan

Synthesize the results from all subagents and the clarified requirements
to generate a draft plan following the format in [references/plan-format.md](../../references/plan-format.md).

Key points:
- Start with What — clarify the goal and why it matters before diving into details
- Group TODOs by module/directory
- Order tasks by dependency (upstream tasks first)
- Each TODO must be completable in a single Claude Code session
- Include code examples for non-trivial logic
- Add a decision table when conditional logic is complex
- List all relevant files, PRs, and documents in References

Present the draft to the user and ask for confirmation or changes.

## Output Format

See [references/plan-format.md](../../references/plan-format.md) for the complete
format specification with examples.

## Phase 5: Finalize and Copy to Clipboard

After the user confirms the plan, copy it to the clipboard using the platform-appropriate command:
- macOS: `pbcopy`
- Linux (X11): `xclip -selection clipboard` or `xsel --clipboard --input`
- Linux (Wayland): `wl-copy`
- WSL: `clip.exe`

Inform the user that the plan has been copied to their clipboard
so they can paste it into their preferred note-taking app.

## Guidelines

- Write TODO items as imperative actions: "Add field X to struct Y", not "Field X should be added"
- Target file paths should be explicit: `src/repository/item_repository.ts`, not "the item repository"
- Code examples in TODOs should be minimal but sufficient to convey the approach
- Decision tables should cover all meaningful combinations, use `-` for "don't care" conditions
- References should include the reason each resource is relevant
