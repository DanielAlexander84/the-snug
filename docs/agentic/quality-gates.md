# Quality Gates

Gates replace code reading. That only works if three things are true:

1. **They run everywhere the same way:** one local command, and CI runs exactly that command.
2. **The agent cannot quietly weaken them.**
3. **When they fail, you understand why without opening the code.**

## The gate set

Concrete tools live in the stack profile. Every project has all of these from day one, regardless of autonomy level:

| Gate | Proves | Blocks merge |
|---|---|---|
| Unit and integration tests | The code does what the slice claims | Yes |
| End-to-end tests on critical paths | A real user can still do the things that matter | Yes (Launch and up) |
| Linter and formatter | Code stays consistent, so agents keep following conventions | Yes |
| Static security scan | No obvious injection, unsafe redirects, mass assignment and similar | Yes |
| Dependency audit | No known-vulnerable libraries | High severity: yes |
| Migration safety | Schema changes won't lock tables or lose data on deploy | Yes |
| Type or schema checks (if the stack has them) | Contracts between frontend and backend hold | Yes |

## One command

The project has a single entry point, for example `bin/check`, that runs every gate in the order above and stops on the first failure. The agent runs it before every push. CI runs the same command. If CI and local disagree, fixing that is the next task.

## Gate integrity rules

The agent must never do any of these without listing them under **Gate changes** in the PR summary, as a decision for you:

- Delete, skip or mark pending any test.
- Change an assertion so a failing test passes, unless the spec changed.
- Add a linter disable comment or a rule exception.
- Add an entry to a security or dependency ignore list.
- Lower a coverage threshold.
- Change the CI configuration or `bin/check`.

A protected-paths check in CI makes this mechanical: if a PR touches CI config, `bin/check`, ignore files or linter config, CI posts a warning on the PR. You then read that part of the diff, every time.

## Failures must explain themselves

When a gate fails, locally or in CI, the agent produces a failure report before trying anything else:

```
## Failing gate
Which gate, which test or rule.

## What it means in plain language
"The witness button no longer notifies the quest owner when the owner is offline."

## Likely cause
What changed that would cause this.

## Is the test right or the code?
Agent's judgement, with reasoning. If the test is wrong, that is a spec question for Daniel.

## Proposed fix
```

Good test names do half of this work. Tests are named after behaviour ("notifies owner when quest is witnessed"), not methods ("test_create"), so a red test reads as a broken promise.

## Flaky tests

A flaky test is treated as a failing test. It is fixed or quarantined in a clearly named file and logged in `docs/STATUS.md`. The quarantine list is reviewed at every `/wrap`. Retrying until green is not allowed.
