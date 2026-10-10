# The Snug

<!-- Fill in every [bracket]. Keep this file short: it's read at the start of every session. -->

## What this is
The Snug is a shared co-working room for adults, many with ADHD, who struggle to start. The core feature: the user names a vague, anxiety-inducing task, and an AI guide ("Sage") breaks it into a few steps so small that the first one is almost too easy. They do it alongside others, and someone sees them finish: a lantern lights and another person taps "saw that". The lantern and the community are the heart. There is no XP, no points, no streaks, no score of any kind, no punishment for absence, and a guilt-free welcome back.

**Built today:** magic-link sign-in, one room, hand-typed quests and steps, ticking steps off, tests that pin all of that (`docs/critical-paths.md`). **Not built:** the AI breakdown, lantern events, realtime, witnessing, deploy. See `docs/ARCHITECTURE.md`.

Design references and the five vows every screen is checked against: `docs/design/`.

## Autonomy level
**Hobby** (promote to Launch before the first external user)
Self-merge on green CI for non-red-zone slices: no

## How we work
Follow `docs/agentic/workflow.md`. In short:
- Read `docs/STATUS.md` first, every session.
- No code without an approved plan. Plans list slices, tests per acceptance criterion, red zones touched and one-way doors.
- Test first. Run `bin/check` before every push. Never weaken a gate without reporting it (`docs/agentic/quality-gates.md`).
- Every PR uses the change summary format from the workflow.
- Stay inside the slice. Put anything else in the STATUS backlog.
- Ask instead of guessing when the spec is ambiguous.
- Decisions: propose in `docs/DECISIONS.md`, Daniel accepts in chat, never mark one Accepted yourself. Accepted entries are rules; Proposed and Open are not.

## Commands
- Setup: `bundle install && npm install && bin/rails db:prepare` (`bin/setup` skips `npm install`)
- Run locally: `bin/dev` (Rails on 3000, Vite on 3033, Tailwind watcher)
- Sign in locally: the magic link is only in `log/development.log`; the README has the grep
- All gates: `bin/check` (lint, format, security scan, dependency audits, migration safety, Jest, RSpec; stops at the first failure). CI runs the same command. It needs Node 22 active: in an agent shell run `source ~/.nvm/nvm.sh && nvm use` first.
- Single gates: `bin/rubocop`, `npm run lint`, `npm run format:check`, `bin/brakeman`, `bin/bundler-audit`, `bin/npm-audit`
- Baselines (existing findings, only new ones fail): `.rubocop_todo.yml`, `.prettierignore`, `config/bundler-audit.yml`, `config/npm-audit.yml`, `start_after` in `config/initializers/strong_migrations.rb`. Adding to any of them is a gate change.
- Tests: `bin/rspec` (browser and request tests) and `npm test` (Jest component tests, each beside its component as `Name.test.jsx`). First run needs `RAILS_ENV=test bin/rails db:prepare` and Google Chrome.
- Single test: `bin/rspec path/to/file_spec.rb:LINE` or `npm test -- NameOfFile`
- Deploy: not decided and nothing is deployed (D6). Kamal files in the repo are placeholders.

## Stack
Profile: `docs/agentic/rails-react.md`
Ruby 3.4.1, Rails 8.1, PostgreSQL, React 19 (plain JSX, no TypeScript), Vite 8 via `vite_rails`, Tailwind 4 via `tailwindcss-rails`, Devise with `devise-passwordless`. Full table in `docs/ARCHITECTURE.md`.

Differs from the profile:
- Tests: RSpec + Capybara, Jest + React Testing Library (D7), not Vitest.
- JSON endpoints are top-level (`/quests`, `/steps/:id`), not under `/api/` (D2).
- No TypeScript, so no `tsc` gate (D9).

## Architecture
See `docs/ARCHITECTURE.md`.

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
- The git repo root is this `code/` folder. Anything one level up (`../not-code/`, `../.github/`) is invisible to git, CI and other sessions. Before saying something "does not exist", check there; anything agents or CI need gets copied into the repo.
- Look at `docs/design/` before proposing or recording a product decision. D12 was accepted and superseded the same day because the mockups were read afterwards.
- Sign-in and sign-up behaviour lives in the Devise gems, not in `app/`. Before describing or reviewing an auth flow, read the gem's controller (`bundle info devise --path`). Phase 0 read only the app code and missed that sign-up signs you in without checking the email (R19).
- Run `npm install` only with Node 22 (`.nvmrc`). Since Phase 3 npm refuses any other version (`engine-strict` in `.npmrc`) and `bin/check` stops at its first gate. Before that, under an older Node, npm printed `EBADENGINE` warnings and silently removed Vite's native build package (`@rolldown/binding-*`): the Vite build failed and every browser test went red with "can't find entrypoints/application.jsx". It happened twice on 2026-10-09/10. Daniel's nvm default is 22 since then, but terminals opened earlier and agent shells can still be on 20.18.3. Repair: `npm install` again under Node 22.
- Never chain `git commit` behind a test command whose output is filtered (`rspec | grep ... && git commit`): the filter succeeds even when tests fail. In Phase 2 two commits were made on a red run this way. Run the tests, read the result line, then commit in a separate step.
- Do not use `git stash -u` or switch branches with uncommitted files in this repo. It lives under `~/Documents`, and files that vanish and reappear come back as duplicates named `.rspec 2`, `spec/system 2` and so on (they are untracked, and `spec/**/* 2/` would be picked up by RSpec). To compare with `main`, use `git show main:path` or `git diff main`.
- The test environment has CSRF protection off, so pages carry no CSRF token and every write from React throws in the browser. A browser test that writes must run with it on (`with_csrf_protection`, already applied to all system specs in `spec/support/capybara.rb`).
