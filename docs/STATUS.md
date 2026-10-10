# Status

<!-- The single place to pick up from. Updated by /wrap at the end of every session. Keep it under one screen. -->

**Last updated:** 2026-10-09
**Autonomy level:** Hobby

## Current focus
Brownfield onboarding (`docs/agentic/brownfield-onboarding.md`). Phases 0 and 1 are merged. Phase 2 (characterisation tests) is in a PR from `onboarding/phase-2-characterisation-tests`. Phase 3 (gates and CI) is next.

## In progress
- Phase 2 PR, waiting for Daniel: 53 Rails tests (`bundle exec rspec`) and 19 component tests (`npm test`) pin the eight critical paths and the sign-out address. No app code changed.

## Next up
1. Phase 3 in a new chat (`/onboard Phase 3`), starting with a plan: `bin/check`, GitHub Actions, baselines for the existing findings (below), ESLint, Prettier, `npm audit`, `strong_migrations`.
2. Phase 3 must pin Node to 20.19 or newer (`.nvmrc`, CI). See "Things that have bitten us" in `CLAUDE.md`.
3. CI needs Google Chrome and a Postgres service. `bundle exec rspec` builds Tailwind and the Vite bundle by itself.

## Blocked / waiting on Daniel
- Review and merge the Phase 2 PR.
- Hosting (D6) is decided at the start of Phase 4.
- If the HTML source of the mockups still exists, add it to `docs/design/`: exact colours, spacing and fonts instead of estimates from screenshots.

## Backlog
<!-- Things noticed outside the current slice. Not worked on without a spec. IDs refer to docs/ARCHITECTURE.md section 11. -->
- [ ] **PRIVACY, before anyone else gets the URL (D16):** per-quest "say it plainly / keep it vague", display names in place of emails (R2). Needs a spec. Sign-up stays open (D4), so this must ship first. Phase 2 tests will pin today's room-wide behaviour and mark it as wrong.
- [ ] **SECURITY, before anyone else gets the URL (R19):** sign-up signs the visitor in without checking they own the email address, so anyone can take an account under someone else's address. Red zone, needs a spec. Phase 2 pins it and marks it as wrong.
- [ ] R20 Sign-in form reveals which emails have accounts
- [ ] A `ci.yml` sits outside the repo at `../.github/workflows/` and has never run. Use it as the starting point in Phase 3, then delete the stray copy.
- [ ] Apply D13 to existing code: quest presenter (I1), server-side `completed` (I2), scoped step lookup (I3)
- [ ] Personal quest log page (in `PLANNING.md` under "Later, maybe"; not built)
- [ ] R3 Magic links reusable until expiry, no rate limit on requests
- [ ] R4 No CSP, `force_ssl` off; R5 no sign-out, no account deletion design; R5a no input limits
- [ ] R6 Production image likely does not build (no Node in `Dockerfile`), unverified
- [ ] R7 Production mail unconfigured, placeholder sender and host
- [ ] R8 No production database in deploy config; R9 room depends on seeds; R10 no backups or rollback
- [ ] R12 no CI, R13 no JS gates or `strong_migrations` (Phase 3); R15 `/up` skips the database (Phase 4)
- [ ] Found in Phase 2, for the Phase 3 baselines: `bundler-audit` reports 7 advisories (activestorage, json, loofah x3, rack-proxy, rails-html-sanitizer), `npm audit` reports 3 high (nanoid, postcss, source-map-js, all under Vite) and 19 moderate (one cause, `sprintf-js` under Jest), RuboCop reports 30 offences in `app/` and `config/`. All but the 19 moderate were there before Phase 2.
- [ ] The test environment has CSRF protection off, so the page carries no token and every write from React crashes there. Browser tests switch it on in `spec/support/capybara.rb`. Decide whether to turn it on for the whole test environment.
- [ ] "What are you starting?" and "Steps" are not connected to their input boxes (no `for`/`id`), so screen readers do not announce them. Fix with the restyle (D18); the tests then switch from hint text to labels.
- [ ] Email is normalised twice (the `normalizes` line in `User` and Devise's `case_insensitive_keys`/`strip_whitespace_keys`). Removing the model line changes nothing the tests can see.
- [ ] Not covered by a test: a network error leaves "Start quest" disabled (R14), an unseeded database gives 404 on every page (R9), the Devise "edit account" page (R5).
- [ ] R14 UI fails silently and clears the form on a rejected quest
- [ ] R16 Dead code and unused gems; R17 Node unpinned, `bin/setup` skips `npm install`; R18 personal email in seeds
- [ ] App is still named `AdultingQuestLog` in code, databases and deploy config (I7)
- [ ] `tech-overview.md`, `PLANNING.md` and `gemini-groundwork.md` are partly wrong (ARCHITECTURE section 12): correct or retire

## Quarantined tests
- None

## Known baselines
- RuboCop todo: not measured yet (Phase 3)
- Brakeman ignores: 0 (no ignore file)
