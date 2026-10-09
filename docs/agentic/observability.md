# Observability

Tests tell you the code did what you specified. Monitoring tells you whether what you specified works for real people. Since you aren't reading the code, production is where you find out what you missed, so monitoring is part of every project from the first deploy, not a later add-on.

## The four signals

Every app emits these. Concrete services are in the stack profile.

### 1. Errors
Every unhandled exception, backend and frontend, goes to an error tracker with the release version and (pseudonymous) user ID attached.
Rule: a new error class after a deploy is a bug in the last slice, and fixing it is the next task.

### 2. Liveness
A health endpoint that checks the app *and* its database. An external uptime monitor hits it every few minutes and alerts your phone after two consecutive failures.

### 3. The business heartbeat
One to three numbers that say whether the product is alive in the way that matters, for example "quests created today" or "witness taps in the last 24 hours". A simple admin-only page or a daily summary email is enough. At Business level, a drop below a threshold alerts you.

This is the signal tests can't give you: everything green, zero errors, and nobody completing the core action means something is wrong.

### 4. Logs you can query
Structured logs with a request ID, retained long enough to investigate a report from a user (at least 7 days at Launch, 30 at Business). Never log passwords, tokens, magic-link URLs or full personal data.

## What every slice adds

The agent's plan for each slice answers: **"How would we notice in production if this slice broke?"** Usually the answer is "the error tracker", but for core actions it may mean adding a heartbeat metric or a log line. If the honest answer is "we wouldn't", the plan says so and you decide.

## Alert hygiene

- Alerts go to your phone only for things that need action today: site down, error spike, heartbeat zero.
- Everything else is a daily or weekly digest.
- An alert that fires and needs no action gets tuned or deleted the same week. Noisy alerts get ignored, and an ignored alert is worse than none.

## Data protection

Prefer EU-hosted monitoring services, sign their data processing agreement, and scrub personal data before it leaves the app. List every service in `CLAUDE.md` under Services.
