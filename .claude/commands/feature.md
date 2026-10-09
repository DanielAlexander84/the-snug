---
description: Plan and build one slice of a spec, through the full workflow.
---
Work on the spec: $ARGUMENTS

Follow `docs/agentic/workflow.md`.

**Planning (stop after this and wait for my approval):**
1. Read the spec, `docs/ARCHITECTURE.md`, `docs/critical-paths.md` and the relevant code.
2. If acceptance criteria are ambiguous or untestable, ask before planning.
3. Propose the slices in order. For each: what changes, which test covers each acceptance criterion, red zones touched, and how we'd notice it breaking in production.
4. List one-way doors separately, with options and your recommendation.

**Building (after approval, one slice at a time):**
1. Branch from `main`.
2. Write failing tests for the slice's acceptance criteria first, then implement.
3. Run `bin/check`. If anything fails, write the failure report from `docs/agentic/quality-gates.md` before fixing.
4. Open a PR with the change summary from the workflow. Under "Red zones touched", point me at exact files and line ranges to read.
5. Stop after the slice. Don't start the next one unasked.
