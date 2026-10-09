# Status

<!-- The single place to pick up from. Updated by /wrap at the end of every session. Keep it under one screen. -->

**Last updated:** 2026-10-09
**Autonomy level:** Hobby

## Current focus
Brownfield onboarding (`docs/agentic/brownfield-onboarding.md`). Phase 0 (map) is done: `docs/ARCHITECTURE.md`. Decisions from it are recorded in `docs/DECISIONS.md`.

## In progress
- Phase 0 docs committed on branch `onboarding/phase-0-map`, not pushed. No code changed.
- `CLAUDE.md` corrections drafted in the working tree, uncommitted, for Daniel to review.

## Next up
1. Daniel reviews the `CLAUDE.md` draft and approves Phase 0.
2. Phase 1: write `docs/critical-paths.md` together.

## Blocked / waiting on Daniel
- Review the `CLAUDE.md` draft (`git diff CLAUDE.md`).
- Approval to start Phase 1.
- No decisions are waiting. Hosting (D6) is open until Phase 4.

## Backlog
<!-- Things noticed outside the current slice. Not worked on without a spec. IDs refer to docs/ARCHITECTURE.md section 11. -->
- [ ] **PRIVACY, before anyone else gets the URL (D16):** per-quest "say it plainly / keep it vague", display names in place of emails (R2). Needs a spec. Sign-up stays open (D4), so this must ship first. Phase 2 tests will pin today's room-wide behaviour and mark it as wrong.
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
