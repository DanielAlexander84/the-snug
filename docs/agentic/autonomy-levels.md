# Autonomy Levels

Every project declares one level in its `CLAUDE.md`. The level decides how much you must read, which gates are mandatory, and what monitoring must exist. Move up a level deliberately, with a checklist, never by drift.

The guiding idea: the less code you read, the more the gates and monitoring have to carry. So the levels raise the gates, not the amount of reading.

## Level 1: Hobby

No real users, or only you and friends. Data loss would be annoying, not harmful.

- **You read:** plans and PR summaries. Diffs only for red zones you have marked as such.
- **Gates:** tests, lint, security scan, all in CI. Coverage is tracked, not enforced.
- **Monitoring:** error tracking and the health endpoint.
- **Agent may:** merge its own PRs on green CI for slices with no red zones, if you have said so in `CLAUDE.md`.

## Level 2: Launch

Strangers can sign up. You have shared the link publicly. Personal data is stored.

Everything in Hobby, plus:

- **You read:** every red-zone diff before merge. No self-merging by the agent.
- **Gates:** every critical path in `docs/critical-paths.md` has an end-to-end test. Migration safety checks. Dependency audit blocks on high-severity issues.
- **Monitoring:** uptime check with alerts to your phone, the business heartbeat, deploy markers in the error tracker.
- **Operations:** automated database backups, and a restore you have actually tested once. A written rollback procedure.
- **Legal (Germany):** Impressum, Datenschutzerklärung, data processing agreements (AVV) with every service that sees user data, preferably EU-hosted services.

## Level 3: Business

People pay, or depend on the app.

Everything in Launch, plus:

- **You read:** red zones plus anything touching billing, data export, or deletion.
- **Gates:** coverage floor enforced on red-zone code. Staging environment that mirrors production; deploys go staging first.
- **Monitoring:** alert on heartbeat drop (e.g. no sign-ups in 48 hours), performance budgets on key pages, log retention.
- **Operations:** incident notes in `docs/incidents/` for anything user-visible, each with a "what gate would have caught this" line.
- **Security:** periodic review session with the frontier model over auth, authorization and data handling. Secrets rotation plan.

## Promotion checklist

Before changing the level in `CLAUDE.md`, the agent runs through the next level's list and reports each item as done or missing. You promote only when everything is done, or you have written down in `docs/DECISIONS.md` why an item is deferred.
