# Brownfield Onboarding

How to bring an existing repo under the framework. Run with `/onboard`. The goal is a safety net *before* any new features: you can't trust an agent's changes to code that has no gates around it.

Do the phases in order. Each phase ends with a PR and a short report, and you approve before the next starts. No feature work until phase 4 is merged.

## Phase 0: Map (read only, no code changes)

The agent reads the codebase and writes `docs/ARCHITECTURE.md`:

- What the app does, in one paragraph.
- Stack and versions, how to run it, how it deploys.
- Main domain models and how they relate.
- The conventions the code *already follows* (where business logic lives, how controllers are shaped, how the frontend talks to the backend). Agents copy what they see, so these become the rules.
- Inconsistencies, where the code follows two patterns for the same thing. You pick one; it's recorded in `docs/DECISIONS.md`.
- External services and where secrets come from.
- A risk list: anything that looks fragile, insecure or untested.

You read this document properly. It's the one long read in the whole process, and it replaces reading the code.

## Phase 1: Critical paths

Together you write `docs/critical-paths.md`: the five to ten things that must never break. For example sign-up, sign-in by magic link, creating a quest, witnessing a quest. Each one is described as user steps, not code.

## Phase 2: Characterisation tests

For each critical path, the agent writes end-to-end tests that pin down **current behaviour**, even where it's arguably wrong. Wrong behaviour gets a note in the test and a backlog entry, not a fix. The point is to detect change, not to judge.

## Phase 3: Gates and CI

Set up `bin/check` and CI with the full gate set from the stack profile. Existing linter and security findings are not fixed now: they are recorded in a baseline file so CI fails only on *new* findings. Burning down the baseline becomes backlog work.

## Phase 4: Observability

Error tracking, health endpoint, uptime check, and a first heartbeat number, as described in `observability.md`.

## Phase 5: Normal work

Fill in `CLAUDE.md` and `docs/STATUS.md`, then work proceeds through the normal workflow. Fixes for the risk list and the baselines are scheduled like any other work, prioritised by you.
