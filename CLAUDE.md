# [Project name]

<!-- Fill in every [bracket]. Keep this file short: it's read at the start of every session. -->

## What this is
[One paragraph: what the app does, for whom, and the one core action that matters most.]

## Autonomy level
**[Hobby | Launch | Business]** (see `docs/agentic/autonomy-levels.md`)
Self-merge on green CI for non-red-zone slices: [yes | no]

## How we work
Follow `docs/agentic/workflow.md`. In short:
- Read `docs/STATUS.md` first, every session.
- No code without an approved plan. Plans list slices, tests per acceptance criterion, red zones touched and one-way doors.
- Test first. Run `bin/check` before every push. Never weaken a gate without reporting it (`docs/agentic/quality-gates.md`).
- Every PR uses the change summary format from the workflow.
- Stay inside the slice. Put anything else in the STATUS backlog.
- Ask instead of guessing when the spec is ambiguous.

## Commands
- Setup: `[bin/setup]`
- Run locally: `[bin/dev]`
- All gates: `bin/check`
- Single test: `[bin/rails test path/to/test.rb:LINE]`
- Deploy: `[merge to main, auto-deploys on Render]`

## Stack
Profile: `docs/agentic/rails-react.md`
[Versions and anything that differs from the profile.]

## Architecture
See `docs/ARCHITECTURE.md`. [One or two lines on the most important conventions.]

## Red zones for this project
Everything in the profile's red zone list, plus:
- LLM integration: API keys, what user data is sent to the provider,
  prompt construction, and handling of model output (treat it as untrusted input).
- All LLM calls go through a single adapter. Tests and CI never call a real
  LLM: use the fake adapter or recorded responses. The contract test against
  the real provider runs manually or nightly only.

## Services
| Purpose | Service | EU / AVV signed |
|---|---|---|
| Hosting | [ ] | [ ] |
| Errors | [ ] | [ ] |
| Uptime | [ ] | [ ] |
| Email | [ ] | [ ] |
| LLM provider | [ ] | [ ] |

## Things that have bitten us
<!-- Added by /wrap. Short, concrete rules learned from real mistakes in this project. -->
