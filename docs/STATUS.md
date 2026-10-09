# Status

<!-- The single place to pick up from. Updated by /wrap at the end of every session. Keep it under one screen. -->

**Last updated:** 2026-10-09
**Autonomy level:** Hobby

## Current focus
Brownfield onboarding (`docs/agentic/brownfield-onboarding.md`). Phase 0 (map) and Phase 1 (critical paths, `docs/critical-paths.md`) are merged. Phase 2 (characterisation tests) is next.

## In progress
- Nothing. A small wrap-up PR from branch `wrap/phase-1` (this file and one line in `CLAUDE.md`) is open.

## Next up
1. Phase 2 in a new chat (`/onboard Phase 2`): set up RSpec + Capybara and Jest (D7), then one end-to-end test per critical path, pinning today's behaviour. Each "WRONG TODAY" in the paths gets a comment in its test. Also pin that the sign-out address ends the session (no UI control exists yet).
2. Phase 2 starts with a plan for Daniel to approve: it adds gems and npm packages and is the first change outside `docs/`.
3. Phase 2 note: end-to-end tests find elements by label and role, not CSS classes, so the later restyle (D18) does not break them. R19 and the "invalid link" message were read from gem source only; the tests are the first real check.

## Blocked / waiting on Daniel
- Merge the wrap-up PR.
- D18 (when to restyle the UI) is Proposed in `docs/DECISIONS.md`. Hosting (D6) is open until Phase 4.
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
- [ ] R11 No tests (Phase 2); R12 no CI, R13 no JS gates or `strong_migrations` (Phase 3); R15 `/up` skips the database (Phase 4)
- [ ] R14 UI fails silently and clears the form on a rejected quest
- [ ] R16 Dead code and unused gems; R17 Node unpinned, `bin/setup` skips `npm install`; R18 personal email in seeds
- [ ] App is still named `AdultingQuestLog` in code, databases and deploy config (I7)
- [ ] `tech-overview.md`, `PLANNING.md` and `gemini-groundwork.md` are partly wrong (ARCHITECTURE section 12): correct or retire

## Quarantined tests
- None (there are no tests)

## Known baselines
- RuboCop todo: not measured yet (Phase 3)
- Brakeman ignores: 0 (no ignore file)
