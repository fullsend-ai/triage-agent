---
name: agent-scaffolding
description: >-
  Use when diagnosing why agents underperform or ideating improvements to
  agent infrastructure — skills, agent definitions, harness configs,
  AGENTS.md files, hooks, CI gates, or context files. Provides
  research-backed principles for what makes agent scaffolding effective.
---

# Agent Scaffolding

This skill teaches the principles behind effective agent infrastructure
so you can diagnose scaffolding problems and propose grounded
improvements. It is not a setup checklist — it is a lens for evaluating
and improving what already exists.

## Core principles

These are ordered by impact. When diagnosing or proposing changes,
evaluate against the higher-impact principles first.

### 1. Verification > documentation

Giving agents a way to verify their work is the single highest-leverage
scaffolding investment. A runnable test suite, a fast linter, a
type-checker — these create tight feedback loops that let agents
self-correct. Documentation without verification is the agent equivalent
of "trust me, bro."

**Diagnostic questions:**
- Can the agent run tests with a single command, without external
  dependencies?
- Can the agent lint or type-check a single file in under 2 seconds?
- Does CI surface failures clearly, or are they buried in noise?

### 2. Deterministic enforcement > advisory instructions

Prose instructions in context files are advisory — the agent may follow
them, may not. Hooks and lint rules are deterministic — they always
execute. When a convention matters, enforce it mechanically.

**Diagnostic questions:**
- Is a recurring agent mistake caused by an advisory instruction that
  should be a hook or lint rule?
- Are there hooks that auto-format, block destructive operations, or
  validate outputs?
- Could a lint rule catch this class of error before review?

### 3. Minimal, hand-written context

Auto-generated context files (e.g., shipping `/init` output unedited)
reduce agent success rates by ~3% and increase costs by 20-23% (ETH
Zurich, Feb 2026). Human-written context helps only marginally (+4%).
Agents are good at discovering repo structure on their own — only tell
them things they cannot figure out by reading the code.

**Diagnostic questions:**
- Is the context file under 150 lines? Over 300 is a red flag.
- Does every line pass the litmus test: "Would removing this cause the
  agent to make a mistake it wouldn't otherwise make?"
- Does the context file duplicate information the agent can discover
  from the code, directory structure, or existing docs?

### 4. Progressive disclosure

Root context routes the agent to the right area. Skills and
component-level files provide depth on demand. Loading everything
upfront dilutes the context that matters.

**Diagnostic questions:**
- Is the root context file trying to do too much? Should some of it be
  a skill that loads only when needed?
- Are there path-scoped rules for modules with non-obvious conventions?
- Could on-demand skills replace sections of a bloated context file?

### 5. Pattern references > narratives

"Follow the pattern in `src/api/handlers/users.ts`" is more reliable
than a paragraph explaining the pattern. Agents handle copy-modify
changes far better than novel changes from prose descriptions.

**Diagnostic questions:**
- Are the 3-5 most common change types documented as pattern
  references?
- Could a failing agent task succeed if pointed to an existing example?

### 6. Design intent for what code can't say

Agents discover *what* code does by reading it, but not *why* it was
designed that way. When invariants, preconditions, and design rationale
are undocumented, agents make changes that pass tests but violate design
contracts.

**Diagnostic questions:**
- Did the agent violate an undocumented invariant or precondition?
- Is there a design rationale that should be captured so agents don't
  repeat this class of mistake?

## Applying principles to agent infrastructure

### Skills

A good skill is narrow, self-contained, and loads only when needed.

- **Trigger description matters.** A vague trigger means the skill
  loads when irrelevant (noise) or fails to load when needed (miss).
  Be specific about when to use it and when not to.
- **Procedure vs. reference.** Rigid skills (TDD, debugging) should be
  step-by-step procedures the agent follows exactly. Flexible skills
  (patterns, conventions) should teach principles the agent applies
  with judgment. Know which kind you're writing.
- **Don't restate the agent definition.** The agent prompt is the
  authority on prohibitions and identity. Skills teach procedures and
  domain knowledge.

### Agent definitions

The agent prompt defines identity, permissions, and constraints. It
should be short and stable — changes here affect every run.

- Prohibitions belong in the agent definition, not scattered across
  skills.
- If the agent keeps doing something wrong, ask whether the fix is a
  constraint (agent definition), a procedure (skill), or an
  enforcement mechanism (hook/lint rule).

### Harness configs

The harness (environment, tool permissions, sandbox policy) determines
what the agent *can* do. Skills and agent definitions determine what it
*should* do.

- A sandbox policy that's too tight causes tool failures the agent
  can't diagnose. Too loose creates security risk.
- Environment variables and pre/post scripts set up the world the
  agent operates in. If the agent is missing context it needs at
  runtime, the fix might be in the harness, not the prompt.

### AGENTS.md / context files

- Under 150 lines. Hard cap at 300.
- Build commands, test commands, key conventions, PR rules.
- For repos over 100K lines, the root file is a routing layer — not
  an encyclopedia.
- Treat review comments on agent PRs as update signals. Every
  recurring review comment is a missing line in the context file or a
  missing lint rule.

### Hooks

- Start with auto-format on edit and blocking destructive operations.
- Store shared hooks in committed settings so they apply to every
  agent.
- A hook that blocks a bad action is worth more than a context file
  line that asks the agent not to do it.

## Anti-patterns

| Anti-pattern | Why it fails | Better approach |
|---|---|---|
| Auto-generated context shipped as-is | -3% success, +20% cost | Hand-write, keep minimal |
| Exhaustive architecture narratives | Agents discover structure themselves | Document only non-obvious decisions |
| Context file > 300 lines | Adherence drops, context diluted | Split into skills and path-scoped rules |
| No verification mechanism | Agent can't self-correct | Provide runnable tests and lint |
| Advisory-only conventions | Agent may ignore them | Enforce with hooks and lint rules |
| Static context, never updated | Context rot as codebase evolves | Treat review comments as update signals |
| Fixing everything in the prompt | Prompt changes affect all runs | Prefer skills, hooks, or lint rules for targeted fixes |

## Key numbers

| Metric | Value | Source |
|---|---|---|
| Auto-generated context impact | -3% success, +20% cost | ETH Zurich (Feb 2026) |
| Human-written context impact | +4% success | ETH Zurich (Feb 2026) |
| Same model, better scaffolding | +26% accuracy | LangChain Terminal-Bench |
| Recommended context file length | Under 150 lines | Anthropic, ETH Zurich |
| AI-coauthored PR issue rate | 1.7x higher than human | CodeRabbit (Dec 2025) |
