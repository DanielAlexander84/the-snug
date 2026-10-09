# Profile: Rails + React

Concrete tools, commands and red zones for a Rails backend with a React frontend and PostgreSQL. Projects copy this into `docs/agentic/` and adjust the command lines in their `CLAUDE.md` to match their setup. When a tool here disagrees with what the project already uses, the project wins and the difference goes in `docs/DECISIONS.md`.

## Gate tools

| Gate | Backend | Frontend |
|---|---|---|
| Tests | Minitest or RSpec, whichever the project uses | Vitest + React Testing Library |
| End-to-end | Rails system tests (Capybara, headless Chrome) | covered by the same system tests |
| Lint and format | RuboCop (`rubocop-rails-omakase` or project config) | ESLint + Prettier |
| Types | n/a | `tsc --noEmit` if TypeScript |
| Security scan | Brakeman | n/a |
| Dependency audit | bundler-audit | `npm audit --audit-level=high` |
| Migration safety | `strong_migrations` gem | n/a |

Rails 8 apps generate Brakeman, RuboCop and a GitHub Actions workflow by default. Check what's there before adding anything.

## bin/check

One script, run locally and in CI, stopping on first failure:

```bash
#!/usr/bin/env bash
set -euo pipefail
echo "== Lint";          bin/rubocop && npx eslint . && npx prettier --check .
echo "== Types";         npx tsc --noEmit            # remove if no TypeScript
echo "== Security";      bin/brakeman --no-pager --quiet && bundle exec bundler-audit check --update
echo "== Dependencies";  npm audit --audit-level=high
echo "== Unit tests";    bin/rails test && npx vitest run
echo "== System tests";  bin/rails test:system
echo "All gates passed."
```

Adjust test commands for RSpec (`bundle exec rspec`). Baselines for brownfield projects: `.rubocop_todo.yml` (via `rubocop --auto-gen-config`) and `config/brakeman.ignore`, both listed as protected paths.

## CI

GitHub Actions, one job running `bin/check` against a Postgres service container. Additions:

- **Protected-paths warning:** a step that comments on the PR if it touches `.github/`, `bin/check`, `.rubocop*`, `config/brakeman.ignore`, `.eslintrc*`, `package.json` scripts, or test helper/config files.
- **Readable failures:** on failure, write which gate failed to the job summary (`$GITHUB_STEP_SUMMARY`) so the reason is visible on the PR page without opening logs.
- Branch protection on `main`: CI must pass, no direct pushes.

## Observability services

Pick one per row, prefer EU hosting, and sign the AVV:

- **Errors (backend and frontend):** AppSignal (EU-based, covers Ruby and JS) or Sentry with the EU data region.
- **Uptime:** Better Stack or similar, hitting `/up`. Rails 8's built-in `/up` does not check the database, so add a `/health` that runs `SELECT 1` and use that.
- **Heartbeat:** a simple admin-only page, or a daily summary mail via a scheduled job (Solid Queue recurring task).
- **Logs:** the host's log stream, with `config.log_tags = [:request_id]` and `filter_parameters` covering tokens, magic-link params and emails.

## Red zones (always read the diff)

- **Authentication:** Devise config, magic-link generation, expiry and consumption, sessions, password or token handling.
- **Authorization:** every query that loads a record by ID from params must be scoped through the current user (`current_user.quests.find(params[:id])`, never `Quest.find(params[:id])`). An unscoped find is an IDOR. This is the most common serious bug agents introduce.
- **ActionCable:** channel `subscribed` methods must verify the user may stream that record. Same IDOR risk, harder to spot.
- **Migrations** that remove or rename columns or tables, change types, or backfill data.
- **Data deletion and export**, account deletion, anything GDPR-relevant.
- **Mailers** that send to addresses taken from user input.
- **Secrets and credentials:** `config/credentials*`, environment variables, anything in `.env*`.
- **Money:** payment integration, prices, webhooks.
- **Gate config:** the protected paths above.

## Conventions agents follow unless the project says otherwise

- Business logic in models or plain Ruby objects in `app/models` or `app/services`, not in controllers.
- Strong parameters on every create and update.
- React talks to Rails through JSON endpoints under a clear namespace (e.g. `/api/`), with request specs covering each endpoint's auth and authorization.
- No new gem or npm package without listing it under "Decisions I made".
