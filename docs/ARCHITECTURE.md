# Architecture

Phase 0 map, written 2026-10-09 from the code at commit `9f7b38c`. Read-only pass: nothing in `app/`, `config/`, `db/` or `bin/` was changed. Everything below was checked against the code; where a claim could not be verified by reading alone it says so.

## 1. What the app does today

A signed-in user lands in the one shared room, types a quest title and its steps by hand, and ticks steps off. Every signed-in user sees every quest in the room, with the owner's email next to it. When all steps of a quest are ticked, the browser shows "🏮 lit" on that quest. That is the whole app: about 80 lines of Ruby and 160 lines of JSX.

Not built, although one or more documents describe them: AI task breakdown, XP, lantern events being written, realtime broadcast, the "saw that ✓" witness tap, presence, any test, any CI workflow, any real deploy.

## 2. Stack and versions

| Layer | What | Version (locked) |
|---|---|---|
| Language | Ruby | 3.4.1 (`.ruby-version`, `Dockerfile`) |
| Framework | Rails | 8.1.3, `load_defaults 8.1` |
| Database | PostgreSQL via `pg` | 1.6.3; server version not pinned anywhere |
| Web server | Puma, behind Thruster in the image | 8.0.2 / 0.1.22 |
| Jobs, cache, cable | Solid Queue, Solid Cache, Solid Cable | 1.4.0 / 1.0.10 / 4.0.0, all unused so far |
| Auth | Devise + devise-passwordless | 5.0.4 / 1.1.0 |
| Frontend | React, plain JSX, no TypeScript | 19.2.7 |
| JS build | Vite via `vite_rails` / `vite-plugin-ruby` | Vite 8.1.3, vite_rails 3.11.1 |
| CSS | Tailwind via `tailwindcss-rails` (outside Vite) | 4.6.0 (Tailwind 4.3.1) |
| Static assets | Propshaft | 1.3.2 |
| Deploy tooling | Kamal, Docker | 2.12.0 |
| Lint and security | rubocop-rails-omakase, Brakeman, bundler-audit | 1.1.0 / 8.0.5 / 0.9.3 |
| Node | not pinned (no `.nvmrc`, no `engines`) | 20.18.3 on this machine |

The Rails app module is still `AdultingQuestLog`, and databases, the Kamal service and the DB password variable all carry the `adulting_quest_log` name. The product and the GitHub repo are called The Snug.

## 3. Running it

- **Setup:** `bundle install && npm install && bin/rails db:create db:migrate db:seed` (README). `bin/setup` exists but does not run `npm install` and does not seed on an existing database, and it ends by starting the server unless given `--skip-server`.
- **Run:** `bin/dev` starts Foreman with three processes from `Procfile.dev`: Rails on port 3000, the Tailwind watcher, and the Vite dev server on port 3033.
- **Sign in locally:** mail delivery is `:test` in development, so the magic link is only written to `log/development.log`. The README has the grep to pull it out.
- **Seed:** creates the room "The Snug" and one user. `Room.the_one` is `Room.first!`, so an unseeded database makes every page a 404.
- **Checks that exist:** `bin/rubocop`, `bin/brakeman`, `bin/bundler-audit`, and `bin/ci` which runs setup plus those three (`config/ci.rb`).
- **Checks that do not exist:** `bin/check`, any test command, any JS lint.

## 4. Deployment

Nothing has been deployed. What exists is the untouched Rails 8 generator output:

- `Dockerfile`: multi-stage production image, runs as non-root under Thruster on port 80, entrypoint runs `db:prepare` on boot.
- `config/deploy.yml`: Kamal, with placeholder server `192.168.0.1` and registry `localhost:5555`. No staging destination, no database accessory, no proxy/SSL block. Only `RAILS_MASTER_KEY` is passed as a secret.
- `.kamal/secrets`: reads `config/master.key` from the local disk.

Gaps between this config and a working deploy are in the risk list (R6 to R9).

## 5. Domain model

```
User ──< Quest >── Room
           │
           ├──< Step          (description, done, position)
           └──< LanternEvent  (quest, user, created_at only)   never written
```

- **User** (`email` only, plus `remember_created_at`). Devise modules: `magic_link_authenticatable`, `registerable`, `rememberable`. No password column. Email is normalised to stripped lowercase.
- **Room** (`name`). Exactly one row, fetched by `Room.the_one`.
- **Quest** (`title`, belongs to user and room). `has_many :steps` ordered by position, destroyed with the quest. `completed?` is true when there is at least one step and all are done. Nothing calls `completed?`.
- **Step** (`description`, `done` default false, `position`). Position comes from the client.
- **LanternEvent** (quest, user, `created_at`, deliberately no `updated_at`). The model and table exist; no code creates a row.

All foreign keys are real database constraints. There are no unique constraints beyond `users.email`, no length limits, and no check that step positions are unique within a quest.

## 6. Request flow

| Route | Handler | Returns |
|---|---|---|
| `GET /` and `GET /room` | `RoomsController#show` | HTML with the room data embedded as JSON, React mounts on it |
| `GET /quests` | `QuestsController#index` | JSON list of all quests. No caller in the frontend. |
| `POST /quests` | `QuestsController#create` | JSON quest, 201, or 422 with `errors` |
| `PATCH /steps/:id` | `StepsController#update` | JSON step, 403 if not the owner, 422 with `errors` |
| `/users/*` | Devise, sessions through `devise/passwordless/sessions` | HTML |
| `GET /up` | Rails health check | 200 if the app booted. Does not touch the database. |

The frontend is three components: `Room` (state and both `fetch` calls), `NewQuestForm`, `Quest`. No router, no state library, no shared API helper.

## 7. Conventions the code already follows

These are what an agent will copy, so they are effectively the rules until you change them.

1. **Everything requires sign-in.** `ApplicationController` has `before_action :authenticate_user!` for all non-Devise controllers.
2. **Thin controllers, strong parameters on every write,** JSON rendered inline with `as_json(only: ...)`. No serializers, no jbuilder views (the gem is installed and unused), no service objects, no `app/services`.
3. **Error shape:** `{ errors: [strings] }` with 422 for validation and 403 for authorization.
4. **Server-authoritative UI.** React waits for the response and then updates state from the returned JSON. No optimistic updates.
5. **Initial data is embedded in the HTML** as `<script type="application/json">`, escaped with `json_escape`. Later writes use `fetch` with the CSRF token from the meta tag.
6. **Ownership for writes** is checked in the controller by comparing the record's owner to `current_user`.
7. **Reads are room-wide.** Any signed-in user sees all quests and all owners' emails.
8. **JSON endpoints live at the top level** (`/quests`, `/steps/:id`), not under a namespace.
9. **Styling** is Tailwind utility classes inline in JSX and ERB.

## 8. Inconsistencies inside the code

Places where the code does one thing two ways, or says one thing and does another. Target patterns for I1 to I3 are set in `docs/DECISIONS.md` D13. Convention 7 in the section above (room-wide reads) is replaced by D16: it describes the skeleton, and new code must not copy it.

| # | What | Where |
|---|---|---|
| I1 | The quest JSON shape is written out twice, once in the controller and once in the view. They match today and will drift. | `quests_controller.rb:23`, `rooms/show.html.erb:6` |
| I2 | "Is this quest complete" is computed twice: `Quest#completed?` on the server (unused) and `allDone` in the browser (the one that shows the lantern). The stated principle is that the server owns the lantern. | `quest.rb:12`, `Quest.jsx:2` |
| I3 | Quest creation is scoped through the user (`current_user.quests.build`), step update is an unscoped `Step.find` followed by a manual owner check. The stack profile forbids the second form. It is correctly authorized today; it answers 404 for a missing step and 403 for someone else's, which reveals which step IDs exist. | `quests_controller.rb:8`, `steps_controller.rb:3` |
| I4 | Two routes render the same page (`/` and `/room`), and `GET /quests` has no caller. | `routes.rb` |
| I5 | Two CSS and JS pipelines: Tailwind is built by `tailwindcss-rails` and served by Propshaft, JS is built by Vite. Works, but it is two watchers and two build steps. | `Procfile.dev`, `layouts/application.html.erb` |
| I6 | Two email validators with different rules: Devise's `email_regexp` in the initializer and `URI::MailTo::EMAIL_REGEXP` in the model. Only the model's is active, since `:validatable` is not enabled. | `devise.rb`, `user.rb:6` |
| I7 | Naming: `AdultingQuestLog` in code, databases and deploy config; The Snug everywhere a user looks. | `config/application.rb`, `database.yml`, `deploy.yml` |
| I8 | `vite.config.ts` is TypeScript in an otherwise JSX-only frontend with no TypeScript dependency or `tsconfig`. Vite handles it; `tsc --noEmit` from the profile would not run. | `vite.config.ts` |

## 9. LLM integration: how the AI task breakdown calls an LLM today

**It does not. There is no LLM code in this repository.**

| Question | Finding | Evidence |
|---|---|---|
| Where do the calls live? | Nowhere. | No match for `anthropic`, `openai`, `gemini`, `llm`, `ruby_llm`, `sage` or `api_key` in `app/`, `config/`, `lib/`, `db/`, `bin/` or `.kamal/`. No `app/services`, no `app/jobs` beyond the empty base class, no HTTP client code. |
| Which provider and SDK? | None installed. | `Gemfile.lock` has no LLM or HTTP-client gem beyond Rails' own dependencies. `package.json` has only React and Vite. |
| How is the API key loaded? | No key is referenced. | No `ENV[...]` or `credentials` lookup for a provider key anywhere. `config/credentials.yml.enc` exists; I did not decrypt it, so I cannot say whether a key is stored there, only that nothing reads one. `.kamal/secrets` passes `RAILS_MASTER_KEY` only. |
| What user data is sent? | None. No outbound request to any third party exists in the app. | Same search. |
| Do tests exist for it? | No. There are no tests of any kind. | No `test/` or `spec/` directory. `config/application.rb` does not load `rails/test_unit/railtie`. |

What exists instead: `NewQuestForm.jsx` has three hand-typed step inputs and an "add a step" button. `PLANNING.md` records this as a closed decision ("No AI in skeleton; steps hand-typed") and names the Anthropic API as the intended provider for a later slice.

Consequence for the ADR "LLM access through a single swappable adapter" (D15): its open implementation choice was to be decided "after Phase 0 shows how the feature is wired today". There is no wiring to migrate, so the choice is a clean one and the adapter can be the first LLM code written rather than a refactor.

### Resolution of the open choice (accepted 2026-10-09, D15)

**Own thin adapter, with the provider's official SDK as the single implementation behind it.** Concretely: an `Llm::Client` interface with one method per feature-shaped need (for now, one: task text in, list of steps out), an `Llm::Anthropic` implementation, and an `Llm::Fake` used by all tests and CI. Provider, model and limits come from config.

Reasons:

1. **Everything the ADR requires has to be our code under every option.** Per-user rate limit, a global daily budget cap, a call log with tokens, cost, user and feature, and the fake for tests are all specific to this app's database and users. `ruby_llm` and OpenRouter each replace only the HTTP call, which is the small part.
2. **The surface is one call.** One feature, one prompt, one structured response. A multi-provider gem brings its own chat, tool and model-registry abstractions to wrap a single request, and then our adapter wraps the gem anyway, because the ADR says no SDK is called from anywhere else.
3. **A gateway adds a second company that sees user data.** Task text typed by adults with ADHD is personal and can be sensitive. Launch level requires a signed AVV with every processor and prefers EU hosting. OpenRouter means two processors and two agreements instead of one, plus its margin on every call, to buy provider switching you can already get from the adapter.
4. **It keeps the other two options open.** If a second provider is ever needed, `ruby_llm` or a gateway becomes a second implementation of `Llm::Client`. Going the other way, from a gem's abstractions back to our own, is the expensive direction.
5. **Red-zone review stays small.** Prompt construction, what user data leaves the app and how model output is validated all sit in one directory you can read in full.

Sub-decisions this leaves for the feature spec, not for the ADR: whether the call runs inline in the request or in a Solid Queue job, the output schema and its validation (model output is untrusted input: fixed step count range, length caps, plain text only), the canned fallback when the provider fails or the budget is exhausted, and which provider and region to sign an AVV with. `PLANNING.md` assumes Anthropic; the Services table in `CLAUDE.md` is still blank.

## 10. External services and secrets

| Service | Status in code |
|---|---|
| Hosting | None. Kamal config is placeholder. |
| Email delivery | None. Development uses `:test`. Production sets no delivery method and no SMTP settings. |
| Error tracking | None. |
| Uptime | None. `/up` exists. |
| LLM provider | None. |
| Container registry | Placeholder `localhost:5555`. |

Secrets:

- `config/master.key`: present locally, ignored by git and Docker. Decrypts `config/credentials.yml.enc`, which is committed.
- `RAILS_MASTER_KEY`: the only secret Kamal passes to the container.
- `ADULTING_QUEST_LOG_DATABASE_PASSWORD`: read by `database.yml` in production, not provided by `deploy.yml`.
- Magic-link tokens are signed with the app's `secret_key_base` (no separate `passwordless_secret_key`).
- `.env*` is ignored by git; no `.env` file is used by the app.

## 11. Risk list

Ordered by how much it would hurt at first external user. None of these were fixed; they are in the STATUS backlog.

**Security and privacy**

- **R1. Open sign-up.** `:registerable` is on and the sign-in page links to "Sign up". Anyone who finds the URL can create an account and read everything in the room.
- **R2. Every user's email is shown to every other user,** in the page payload and in the UI.
- **R3. Magic-link tokens are stateless.** A link can be used repeatedly until it expires (20 minutes, the gem default). No rate limit on requesting links, so the sign-in form can be used to send mail to arbitrary addresses once mail is configured.
- **R4. No Content Security Policy** (initializer fully commented out) and **`force_ssl` is off** in production.
- **R5. No sign-out control** in the UI. Account deletion and data export have not been designed; only Devise's generated registration edit page exists, untested.
- **R5a. No input limits.** Quest titles, step descriptions and the number of steps per request are unbounded. The "at least one step" rule is enforced only in the browser; the server accepts a quest with none.
- **R19. Sign-up does not verify the email address** (found in Phase 1, 2026-10-09). Devise's stock registration signs the new account in at once; no mail is sent. Anyone can create and use an account under someone else's address, and the real owner later lands in that same account by magic link. Read from the gem source, not yet exercised.
- **R20. The sign-in form reveals which emails have accounts** ("Could not find a user for that email address"; `config.paranoid` is off).

**Deploy**

- **R6. The production image very likely does not build.** `vite_ruby` hooks `assets:precompile` to run a Vite build, and the `Dockerfile` installs neither Node nor the npm packages. Not verified by building, since Phase 0 is read-only. The README says the image builds and runs.
- **R7. Production mail would not work.** No delivery method, the Devise sender is `please-change-me-at-config-initializers-devise@example.com`, and link host is `example.com`, so magic links would point at the wrong site. Sign-in is email-only, so no mail means no access.
- **R8. No production database is defined.** `deploy.yml` has no database accessory or `DB_HOST`, does not pass the database password, and production expects four databases.
- **R9. The room exists only if seeds have run.** `db:prepare` seeds a database it initialises itself; in any other case every page is a 404 until someone runs `db:seed`. The same seed file also creates a user with a personal email address in production.
- **R10. No backups, no rollback procedure, no staging destination.**

**Quality**

- **R11. No tests at all,** and the app was generated with `--skip-test`, so `bin/rails test` is not available until the test framework is added.
- **R12. No CI.** There is no `.github/` directory. `bin/ci` runs locally only.
- **R13. No JS lint, formatter, type check or dependency audit.** No `strong_migrations`.
- **R14. Silent failures in the UI.** Both `fetch` calls return without telling the user when the response is not OK. A rejected quest also clears the form, so what the user typed is lost. A thrown network error leaves the submit button disabled.
- **R15. `/up` does not check the database.**
- **R16. Dead or unused pieces:** `LanternEvent`, `Quest#completed?`, `GET /quests`, `jbuilder`, `image_processing`, the PWA views, Action Mailbox, Action Text and Active Storage (loaded, unused).
- **R17. Node version unpinned,** and `bin/setup` skips `npm install`.
- **R18. A personal email address is committed** in `db/seeds.rb`.

## 12. Where the planning documents were wrong or outdated

### `PLANNING.md`

| Claim | Reality |
|---|---|
| Slice one includes lantern event row, broadcast, chime and the "saw that ✓" tap | None of these exist. The table exists and is never written. No `app/channels`. |
| "React front end talking to a clean Rails API + ActionCable channel" | JSON endpoints exist; no ActionCable channel. |
| "Server owns ALL state transitions and the lantern policy" | The lantern is decided in the browser (`Quest.jsx`). |
| "type 3–4 steps yourself" | Three inputs by default, any number allowed, minimum one. |
| Lantern events without `updated_at` was "a flagged one-way-door decision in PLANNING.md" (as `tech-overview.md` puts it) | The schema matches, but `PLANNING.md` contains no such decision. |
| Correct | Monolith, Postgres-only, no Redis, Devise magic link, one room, steps as rows, no AI in the skeleton. |

### `tech-overview.md` (dated 2026-07-04, not in git)

| Claim | Reality |
|---|---|
| Vite dev server "on port 3030 (see `config/vite.json`)" | Port 3033. |
| Linters are "wired into `.github/workflows/ci.yml`" | No `.github/` directory exists or ever existed in this repo. A `ci.yml` does sit one folder above the repo root (`../.github/workflows/`, with `working-directory: code`), outside git, so it has never run. It covers Brakeman, bundler-audit and RuboCop only. |
| `bin/dev` is "what `rails new --css=tailwind` sets up", nothing app-specific | The `vite:` line was added by hand. |
| Building and running the image by hand "do work today" | Very likely false, see R6. |
| Correct | Request flow diagram, schema section, gem table, Kamal placeholder status, magic-link mechanics, development mail, script-tag bootstrapping, CSRF handling, ad hoc completion and authorization. It is the most accurate of the three. |

### `docs/agentic/gemini-groundwork.md`

| Claim | Reality |
|---|---|
| DP2: Devise is "localized, and configured with views" | Views and the English locale file exist, but it is passwordless via an extra gem, which the document never mentions and which changes the comparison with Rails 8 native auth. |
| DP3: "Rails default Minitest is assumed" | Minitest was explicitly removed with `--skip-test`. There is no default to fall back on. |
| DP3 presents the test framework as a one-way door | With zero tests it costs nothing to choose either way today. It becomes expensive after Phase 2. |
| DP5: "No CI config files present" | No hosted CI, true. But `bin/ci` and `config/ci.rb` exist and already run three of the gates. |
| Pipeline stage 1: "Run Rubocop, ESLint, and Prettier" | ESLint and Prettier are not installed. |
| Pipeline stages 5 and 6: staging then production deploy | No destination of either kind is configured. |
| Assumption: hosted on GitHub | Correct, `origin` is `github.com:DanielAlexander84/the-snug`. |
| ADR template | Ignored as instructed. `docs/DECISIONS.md` is the only format. |

### `README.md` (not on your list, checked anyway)

Accurate on stack, setup, sign-in and the absence of tests. Its Docker section has the same problem as R6.

## 13. Where `CLAUDE.md` contradicts the code

| `CLAUDE.md` says | Code says |
|---|---|
| A "task manager" where "an AI immediately breaks it into 4–5 steps" | No AI. Steps are typed by hand. `PLANNING.md` plans 3–4 steps, later. |
| "Completing steps earns XP" | No XP anywhere in schema or code. `PLANNING.md` and the README say "The lantern is the only reward". |
| Product framing: a personal productivity tool | Code, README and `PLANNING.md` build a shared co-working room where others see your quests and witness you finish. |
| "Deploy: merge to main, auto-deploys on Render" | Kamal and Docker, no Render config (`render.yaml` absent), no auto-deploy, no CI. `docs/DECISIONS.md` also assumes Kamal. |
| "All gates: `bin/check`" | Does not exist. The nearest thing is `bin/ci`. |
| "Single test: `bin/rails test path/to/test.rb:LINE`" | No test framework is loaded and there is no `test/` directory. |
| "Setup: `bin/setup`" | Runs, but skips `npm install` and then starts the server. README uses a different sequence. |
| "Read `docs/STATUS.md` first", "Architecture: see `docs/ARCHITECTURE.md`" | `STATUS.md` was an unfilled template; `ARCHITECTURE.md` did not exist before this document. |
| Red zones describe how LLM calls are handled | No LLM calls exist. The rules are fine as rules for future work. |
| Services table | All blank, which matches reality: no service is connected. |
| Stack: "Versions and anything that differs from the profile" | Unfilled. Differences from the profile: no `/api/` namespace, no ESLint/Prettier/Vitest, no TypeScript, no `strong_migrations`, no GitHub Actions workflow, an unscoped `find` (I3). |

Also in `docs/DECISIONS.md`, the staging entry's context says "Kamal is already configured for the project". It is installed with placeholder values, not configured.
