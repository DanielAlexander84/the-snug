# Workflow

Every piece of work, from a bug fix to a new feature, goes through the same loop. Small work moves through it in minutes; it is never skipped, only shortened.

```
Frame → Plan → Slice → Build → Verify → Report → Ship → Observe → Record
```

## Who does what

| Role | Responsibility |
|---|---|
| **Daniel** | Frames the problem, approves plans, decides one-way doors, reviews red-zone diffs, decides when to ship. |
| **Planning model** (frontier, e.g. Fable) | Hard thinking: architecture, walking skeletons, one-way-door options, reviewing a plan that feels off. |
| **Execution agent** (Claude Code) | Plans small work, builds, tests, reports, keeps docs current. |

Use the frontier model when the decision is expensive to reverse. Do not use it for construction.

## 1. Frame (Daniel)

Write a spec in `docs/specs/` using the template. It must contain:

- The problem, in one or two sentences, from the user's point of view.
- **Acceptance criteria** written as observable behaviour ("When a user taps Witness, the quest owner sees the badge within 2 seconds"). These are what you check instead of code.
- Out of scope, explicitly.
- Which red zones it touches, if you know.

A bug report is a spec too: what happened, what should happen, how to reproduce.

## 2. Plan (agent, approved by Daniel)

The agent reads the spec, the relevant code and `docs/ARCHITECTURE.md`, then proposes:

- The slices, in order, each independently shippable.
- For each slice: what changes, which tests prove it, which red zones it touches.
- Any decision that is hard to reverse (schema shape, auth model, third-party service, data deletion). These are flagged as **one-way doors** and need your explicit decision.
- Open questions.

You approve the plan, not the code. Reading a plan takes five minutes; this is where your review time goes.

## 3. Slice

- First slice of a new feature is a **walking skeleton**: the thinnest end-to-end path that works in production.
- One slice per branch, one branch per PR. A slice should be reviewable from its summary alone.
- One working session should finish at least one slice. If it can't, the slice is too big.

## 4. Build (agent)

- **Test first.** Each acceptance criterion becomes at least one failing test before implementation.
- Follow the conventions in `docs/ARCHITECTURE.md` and the stack profile. Do not introduce a new pattern, library or service without flagging it in the report.
- Stay inside the slice. Anything else noticed goes into `docs/STATUS.md` under Backlog, not into the diff.

## 5. Verify (agent, then CI)

- Run the full local gate set (see `quality-gates.md`) before pushing.
- CI must be green. A red CI is never "probably fine".
- The agent never weakens a gate to get green: no deleting or skipping tests, loosening assertions, disabling cops or adding scanner ignores without listing it in the report as a decision for Daniel.

## 6. Report (agent)

Every PR carries a change summary in this shape, so you can review without reading the diff:

```
## What changed
Plain-language description of the behaviour change.

## Acceptance criteria → tests
- [criterion] → [test file and test name]

## Red zones touched
None / list, with the diff sections you must read.

## Decisions I made
Anything you didn't explicitly specify: naming, libraries, data shape.

## Gate changes
Any test skipped, rule disabled, ignore added. Should almost always be "None".

## Risks and follow-ups
What could go wrong in production and how we'd notice.
```

## 7. Ship (Daniel decides)

- Merge on green CI plus an approved summary.
- Red-zone diffs are read before merge. No exceptions at Launch level and above.
- Deploys happen from main only.

## 8. Observe

After each deploy: check the error tracker and the business heartbeat (see `observability.md`) once, shortly after. A new error class after a deploy is a bug in that slice.

## 9. Record (agent, via /wrap)

- `docs/STATUS.md`: what's done, what's in progress, what's next. This is how the next session, or you after two weeks away, picks up without rereading anything else.
- `docs/DECISIONS.md`: one short entry per one-way door or notable choice. The agent proposes, Daniel accepts or rejects in chat, the agent updates the file. The exact loop and the status sections are at the top of that file. The agent never marks a decision Accepted on its own.
- Framework retro: one line on whether anything in this session should become a framework rule.
