# Status

<!-- The single place to pick up from. Updated by /wrap at the end of every session. Keep it under one screen. -->

**Last updated:** 2026-10-10
**Autonomy level:** Hobby

## Current focus
Brownfield onboarding (`docs/agentic/brownfield-onboarding.md`). Phases 0, 1 and 2 are merged. Phase 3 (gates and CI) is in review. Phase 4 (observability) is next.

## In progress
- Phase 3 PR from branch `onboarding/phase-3-gates-and-ci`: `bin/check`, GitHub Actions, baselines, Node 22 pin, `bin/rspec`.

## Next up
1. After the Phase 3 PR is merged: one small PR that updates the baselined gems and npm packages and empties both ignore lists (Daniel, 2026-10-10: baseline first, update next).
2. Phase 4 in a new chat (`/onboard Phase 4`), starting with the hosting decision (D6).

## Blocked / waiting on Daniel
- Read and merge the Phase 3 PR. Every file in it is gate configuration, so the whole diff is a red zone.
- Hosting (D6) is decided at the start of Phase 4.
- If the HTML source of the mockups still exists, add it to `docs/design/`: exact colours, spacing and fonts instead of estimates from screenshots.

## Backlog
<!-- Things noticed outside the current slice. Not worked on without a spec. IDs refer to docs/ARCHITECTURE.md section 11. -->
- [ ] **PRIVACY, before anyone else gets the URL (D16):** per-quest "say it plainly / keep it vague", display names in place of emails (R2). Needs a spec. Sign-up stays open (D4), so this must ship first. Phase 2 tests will pin today's room-wide behaviour and mark it as wrong.
- [ ] **SECURITY, before anyone else gets the URL (R19):** sign-up signs the visitor in without checking they own the email address, so anyone can take an account under someone else's address. Red zone, needs a spec. Phase 2 pins it and marks it as wrong.
- [ ] R20 Sign-in form reveals which emails have accounts
- [ ] Dependabot (Daniel, 2026-10-10: not now). The stray `../.github/dependabot.yml` asked for weekly PRs for gems and GitHub Actions, up to 10 open each. Revisit after Phase 4, with npm added and updates grouped.
- [ ] Burn down the lint baselines: 30 RuboCop offences (all auto-correctable layout, 5 files) and 4 files not Prettier-formatted. Formatting only, no behaviour change.
- [ ] `strong_migrations` runs with its defaults. Its generator also suggests a lock timeout and a statement timeout for migrations; decide when there is a production database (R8).
- [ ] 2 moderate npm advisories do not block and are not baselined (`sprintf-js` under Jest, development only; `postcss` under Vite, fixed by the same update as the high one). `bin/npm-audit` prints the count.
- [ ] CI runs Postgres 14 because that is what runs locally. Align both with the host's version when D6 is decided.
- [ ] Apply D13 to existing code: quest presenter (I1), server-side `completed` (I2), scoped step lookup (I3)
- [ ] Personal quest log page (in `PLANNING.md` under "Later, maybe"; not built)
- [ ] R3 Magic links reusable until expiry, no rate limit on requests
- [ ] R4 No CSP, `force_ssl` off; R5 no sign-out, no account deletion design; R5a no input limits
- [ ] R6 Production image likely does not build (no Node in `Dockerfile`), unverified
- [ ] R7 Production mail unconfigured, placeholder sender and host
- [ ] R8 No production database in deploy config; R9 room depends on seeds; R10 no backups or rollback
- [ ] R15 `/up` skips the database (Phase 4)
- [ ] The test environment has CSRF protection off, so the page carries no token and every write from React crashes there. Browser tests switch it on in `spec/support/capybara.rb`. Decide whether to turn it on for the whole test environment.
- [ ] "What are you starting?" and "Steps" are not connected to their input boxes (no `for`/`id`), so screen readers do not announce them. Fix with the restyle (D18); the tests then switch from hint text to labels.
- [ ] Email is normalised twice (the `normalizes` line in `User` and Devise's `case_insensitive_keys`/`strip_whitespace_keys`). Removing the model line changes nothing the tests can see.
- [ ] Not covered by a test: a network error leaves "Start quest" disabled (R14), an unseeded database gives 404 on every page (R9), the Devise "edit account" page (R5).
- [ ] R14 UI fails silently and clears the form on a rejected quest
- [ ] R16 Dead code and unused gems; R17 `bin/setup` skips `npm install`; R18 personal email in seeds
- [ ] App is still named `AdultingQuestLog` in code, databases and deploy config (I7)
- [ ] `tech-overview.md`, `PLANNING.md` and `gemini-groundwork.md` are partly wrong (ARCHITECTURE section 12): correct or retire

## Quarantined tests
- None

## Known baselines
<!-- Measured 2026-10-10 when the gates were switched on. A number here may only go down. -->
- RuboCop todo (`.rubocop_todo.yml`): 30 offences, 3 cops, 5 files
- ESLint suppressions: 0 (no file). `react/prop-types` is switched off as a rule, see `eslint.config.js`
- Prettier (`.prettierignore`): 4 files
- Brakeman ignores: 0 (no ignore file)
- bundler-audit ignores (`config/bundler-audit.yml`): 7 advisories in 5 gems
- npm audit ignores (`config/npm-audit.yml`): 4 high advisories in 3 packages, all under Vite
- `strong_migrations`: the 5 migrations up to `20260703195042` are exempt
