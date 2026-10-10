# The Snug

A cozy co-working tavern for people who struggle to start. You name a task,
take one tiny step in warm company, and a human sees you finish. The lantern
is the only reward.

See [PLANNING.md](PLANNING.md) for the current slice map and design decisions.

## Stack

- Rails 8.1, Postgres-only (Solid Queue / Solid Cable, no Redis)
- React front end, served via [vite_rails](https://vite-ruby.netlify.app/) (no separate JS backend)
- Devise + [devise-passwordless](https://github.com/devise-passwordless/devise-passwordless) for magic-link auth (no passwords, no extra DB columns)
- Server-authoritative throughout: the client renders what the server sends back, no optimistic updates

## Prerequisites

- Ruby 3.4.1 (see `.ruby-version` — install via [rbenv](https://github.com/rbenv/rbenv): `rbenv install 3.4.1`)
- Postgres running locally (`pg_isready` to check)
- Node.js 22 + npm (see `.nvmrc`; with nvm: `nvm use`). npm refuses to install under another version.

## Setup

From this directory (`code/`):

```bash
bundle install
npm install
bin/rails db:create db:migrate db:seed
```

The seed creates the one Room ("The Snug") and a starter User.

## Running it

```bash
bin/dev
```

This starts everything at once via Foreman (see `Procfile.dev`): the Rails server, Tailwind's watcher, and the Vite dev server for the React front end. Visit **http://localhost:3000**.

There's no separate "start the frontend" / "start the backend" step — `bin/dev` runs both. If you only want the Rails server without asset watching, `bin/rails server` works too, since Vite's `autoBuild` will build on demand.

## Signing in

Auth is magic-link only — enter your email on the sign-in page and a login link is generated. In development there's no real mail server configured, so the email is never actually sent; instead it's logged in full to `log/development.log`. After requesting a link, run:

```bash
grep -o 'http://localhost:3000/users/magic_link[^"]*' log/development.log | tail -1 | sed 's/&amp;/\&/g'
```

and open that URL to complete sign-in. The `sed` is required, not optional — the logged link is raw HTML source, where `&` is correctly escaped as `&amp;` inside the `href`. A real email client decodes that automatically when you click the link; pasting the raw text straight into a browser's address bar does not, and it'll split the URL into bogus params (`amp;user[token]=...` instead of `user[token]=...`), which surfaces as a generic "Invalid Email or password" error on sign-in.

## Docker / deployment

The `Dockerfile` is production-only (multi-stage build, precompiled assets and bootsnap cache, runs as a non-root user under [Thruster](https://github.com/basecamp/thruster)) — it's not used for local dev, which is what `bin/dev` above is for.

To build and smoke-test the production image locally:

```bash
docker build -t the_snug .
docker run -d -p 80:80 \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  -e ADULTING_QUEST_LOG_DATABASE_PASSWORD=<password> \
  --name the_snug the_snug
```

It needs a reachable Postgres server: `config/database.yml`'s `production` section connects as user `adulting_quest_log` (password from `ADULTING_QUEST_LOG_DATABASE_PASSWORD`) to four separate databases — `adulting_quest_log_production`, plus `_cache`, `_queue`, and `_cable` for Solid Cache/Queue/Cable. The container's entrypoint (`bin/docker-entrypoint`) runs `db:prepare` on boot, so it'll create/migrate them itself if the role has permission.

Deploys are set up for [Kamal](https://kamal-deploy.org) (`config/deploy.yml`, `.kamal/secrets`), but the config is still the generator's placeholder — it points at `192.168.0.1` and a `localhost:5555` registry. Fill in a real server, registry, and `RAILS_MASTER_KEY`/secrets setup before running `bin/kamal deploy`; nothing has been deployed with it yet.

## Tests / checks

```bash
bin/check           # every gate below, in order, stopping at the first failure. CI runs exactly this.

bin/rubocop         # Ruby style
npm run lint        # JavaScript lint (ESLint)
npm run format:check  # JavaScript formatting (Prettier); `npm run format` fixes it
bin/brakeman        # security static analysis
bin/bundler-audit   # gem vulnerability scan
bin/npm-audit       # npm vulnerability scan (high and critical only)
npm test            # React component tests (Jest), in app/frontend/components/*.test.jsx
bin/rspec           # Rails tests: browser tests (headless Chrome) and request tests
```

`bin/check` also rebuilds the test database from the migrations, so `strong_migrations` checks new ones. Findings that existed when the gates were switched on are in baseline files (`.rubocop_todo.yml`, `.prettierignore`, `config/bundler-audit.yml`, `config/npm-audit.yml`); only new findings fail.

The tests pin today's behaviour on the critical paths in `docs/critical-paths.md`. First run: `RAILS_ENV=test bin/rails db:prepare`. The browser tests need Google Chrome installed; they build the Tailwind stylesheet and the Vite bundle themselves.

Single test: `bin/rspec spec/system/lantern_spec.rb:14` or `npm test -- Quest`.
