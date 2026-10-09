# Decisions

One entry per one-way door or notable choice. Short is fine.

## How a decision gets made

1. **The agent proposes.** It adds an entry under *Proposed* with the next free ID.
2. **Daniel decides, in chat.** Short is enough: "accept D1–D3. D7: use RSpec instead. D6: leave open."
3. **The agent updates this file** (and `STATUS.md` or `ARCHITECTURE.md` if the decision affects them): moves the entry to the right section, sets the status line, and shows the diff.
4. **It is binding once that diff is committed.**

Daniel can also edit this file by hand. Then tell the agent, so it re-reads the file.

Rules:

- The agent never marks an entry Accepted unless Daniel said so explicitly in chat. Silence, or approving a plan that mentions the decision, does not count.
- An accepted entry is never rewritten. A change of mind is a new entry; the old one moves to *Superseded* with "Superseded by Dn".
- IDs are permanent and never reused. Entries keep their ID when they move between sections.
- Agents treat *Accepted* as rules, *Proposed* and *Open* as not decided: ask before building on them.

Statuses and where they live:

| Status | Meaning | Section |
|---|---|---|
| Proposed | Waiting for Daniel | 1 |
| Open | Deliberately deferred, with the trigger that forces it | 2 |
| Accepted | In force | 3 |
| Rejected | Considered and turned down, kept so it is not proposed again | 4 |
| Superseded | Was accepted, replaced by a later entry | 5 |

Entry template:

```
### Dn: Title
**Status:** Proposed (YYYY-MM-DD)
**Context:** What forced the decision.
**Options:** The real alternatives.
**Decision:** What we chose, or what is proposed.
**Why:** The reason that would still convince you in a year.
**Revisit if:** The condition that would make this wrong.
```

"Retroactive" in a status line means the entry records what the code already did when the repo was onboarded (2026-10-09). Evidence is in `docs/ARCHITECTURE.md`.

---

## 1. Proposed (waiting for Daniel)

None.

---

## 2. Open (deliberately deferred)

### D6: Hosting and deploy tooling
**Status:** Open (Daniel, 2026-10-09). Decide when Phase 4 needs a deployed app; pick the cheapest and easiest option then.
**Context:** The Rails 8 generator added Kamal, a production `Dockerfile` and Thruster. All are still placeholder; nothing has been deployed. `CLAUDE.md` says Render.
**Options:**
- Kamal to one small EU VPS: cheapest, staging and production on one box, you maintain the server.
- Managed platform such as Render (Frankfurt): almost no upkeep, a paid web service and database per environment.
**Decision:** None yet.
**Why:** No phase before Phase 4 needs a server.
**Revisit if:** Phase 4 starts, or you want to show the app to someone.

---

## 3. Accepted (in force)

### D1: Rails monolith serving React through Vite
**Status:** Accepted (Daniel, 2026-10-09). Retroactive.
**Context:** The app needs a React UI and a Rails backend, built by one person.
**Options:**
- One Rails app that renders the page and mounts React into it (`vite_rails`).
- Rails API plus a separate SPA or Next.js frontend.
**Decision:** One Rails app. React is mounted into a server-rendered page; Vite builds the JS. No client-side router, no separate frontend deploy.
**Why:** One process, one deploy, one session cookie for both HTML and JSON (and later ActionCable).
**Revisit if:** A native mobile client or a second frontend needs the same backend.

### D2: Frontend gets data from embedded JSON and plain fetch, server-authoritative
**Status:** Accepted (Daniel, 2026-10-09). Retroactive.
**Context:** React needs initial data and a way to write.
**Options:**
- Embed initial data in the HTML, write through JSON endpoints with `fetch`, update state only from the server's response.
- Fetch everything on load; optimistic updates; a data library (React Query, Inertia).
**Decision:** The first option. Endpoints sit at the top level (`/quests`, `/steps/:id`), JSON is built inline with `as_json`, errors are `{ errors: [...] }`.
**Why:** No loading state on first paint, and the server stays the single owner of state.
**Revisit if:** Realtime broadcasts arrive (the client then needs a second source of truth), or the endpoint count grows enough to want an `/api/` namespace as the stack profile suggests. This differs from the profile today.

### D3: Devise with magic-link sign-in, no passwords
**Status:** Accepted (Daniel, 2026-10-09). Retroactive. Red zone.
**Context:** Users must be identified; passwords are friction for the target audience.
**Options:**
- Devise + `devise-passwordless`.
- Rails 8 built-in authentication with hand-written magic links.
**Decision:** Devise + `devise-passwordless`, modules `magic_link_authenticatable`, `registerable`, `rememberable`. Tokens are stateless signed GlobalIDs valid for 20 minutes. No password column.
**Why:** Less custom auth code to maintain.
**Revisit if:** Stateless tokens (reusable until expiry, cannot be revoked) are not acceptable at Launch level, or the gem falls behind Devise releases.

### D4: Sign-up is open to anyone
**Status:** Accepted (Daniel, 2026-10-09). Red zone.
**Context:** `:registerable` is enabled and the sign-in page links to sign-up.
**Options:**
- Open sign-up.
- Invite-only or an allowlist for the alpha.
**Decision:** Sign-up stays open to anyone, including once the link is shared.
**Why:** Daniel's choice. What others can see is controlled per quest (D16), not by limiting who may join.
**Revisit if:** Spam or abusive accounts appear, or strangers drive up LLM cost beyond what the per-user limit and daily cap in D15 absorb. Do not share the link before D16 is built: until then every quest and email is visible to every account.

### D5: PostgreSQL only, Solid Queue, Solid Cache and Solid Cable, no Redis
**Status:** Accepted (Daniel, 2026-10-09). Retroactive.
**Context:** Jobs, cache and websockets each need a backing store.
**Options:**
- Solid trio on Postgres.
- Redis with Sidekiq and the Redis cable adapter.
**Decision:** Postgres for everything. Production expects four databases (primary, cache, queue, cable); Solid Queue runs inside Puma.
**Why:** One service to host, back up and pay for.
**Revisit if:** Cable polling latency hurts the realtime feel, or job volume outgrows in-Puma workers.

### D7: Test framework
**Status:** Accepted (Daniel, 2026-10-09). Daniel chose RSpec + Jest over the agent's proposal of Minitest + Vitest.
**Context:** Phase 2 needs a test framework and the workflow requires test-first.
**Options:**
- Minitest with Rails system tests (Capybara, headless Chrome), Vitest + React Testing Library for components.
- RSpec with Capybara, Jest for components.
**Decision:** RSpec with Capybara system specs (headless Chrome) for Rails; Jest with React Testing Library for components.
**Why:** Daniel's preference: more readable, behaviour-style tests, which matter when tests are read instead of code. Costs more setup than the Rails defaults, and Jest needs its own transform config because it does not use the Vite build.
**Revisit if:** Jest's separate build config drifts from Vite's and causes false failures; Vitest is then the drop-in alternative.

### D8: Lint and security tooling, and where CI runs
**Status:** Accepted (Daniel, 2026-10-09). Retroactive for the Ruby tools.
**Context:** The generator installed RuboCop (omakase), Brakeman and bundler-audit, run by `bin/ci`. There is no JS lint, no hosted CI and no `bin/check`. A `ci.yml` sits one folder above the repo root, outside git, and has never run.
**Options:**
- Keep the three Ruby tools, add ESLint, Prettier and `npm audit`, run everything from `bin/check` on GitHub Actions.
- Keep `bin/ci` as the single entry point instead of `bin/check`.
**Decision:** Keep the three Ruby tools. `bin/check` as the one command (as the framework specifies), GitHub Actions as CI since the repo is on GitHub, JS tools added in Phase 3.
**Why:** One name across all projects using the framework.
**Revisit if:** n/a.

### D9: Plain JSX, no TypeScript; Tailwind built outside Vite
**Status:** Accepted (Daniel, 2026-10-09). Retroactive.
**Context:** Frontend language and CSS pipeline.
**Options:**
- JSX, with Tailwind compiled by `tailwindcss-rails` and served by Propshaft.
- TypeScript; Tailwind through Vite.
**Decision:** JSX without type checking. Tailwind 4 through the Rails gem, separate from the Vite build.
**Why:** Generator defaults plus the smallest React setup.
**Revisit if:** The frontend grows past a handful of components (types), or the two build pipelines cause deploy trouble.

### D10: Data model shape
**Status:** Accepted (Daniel, 2026-10-09). Retroactive. Schema is a one-way door once real data exists.
**Context:** How quests, steps, the room and lantern lightings are stored.
**Options:** Steps as rows or as a JSON column; one room or many; lantern as a flag on the quest or as an event log.
**Decision:** Steps are rows with an integer `position`. Exactly one `Room`, fetched by `Room.the_one`. `lantern_events` is an append-only table with `created_at` and no `updated_at`. Quest completion is computed, not stored.
**Why:** Rows are queryable and Rails-native. One room removes scheduling. An event log keeps lighting history.
**Revisit if:** Multiple rooms are needed.

### D11: Product definition
**Status:** Accepted (Daniel, 2026-10-09)
**Context:** `CLAUDE.md` described a personal task manager with AI breakdown and XP; the code and `PLANNING.md` a shared co-working room with a lantern.
**Options:** Either one, or both.
**Decision:** Both, without XP. The Snug is a shared co-working room whose core feature is AI task breakdown for getting past task paralysis. The lantern and the community are the heart; achievement is celebrated without points, streaks or anything that can be lost. Working title stays The Snug.
**Why:** XP invites the guilt spiral the product exists to break.
**Revisit if:** Alpha users ask for a sense of progress the lantern and a personal quest log do not give.

### D13: Target code conventions for the three duplicated patterns
**Status:** Accepted (Daniel, 2026-10-09). Applies to new code now; existing code is fixed by backlog items after Phase 3, not during onboarding.
**Context:** Phase 0 found three things done two ways (ARCHITECTURE section 8: I1, I2, I3).
**Options:** For each, keep either of the two existing forms.
**Decision:**
- **One place builds the JSON a user sees.** A plain Ruby presenter that takes the record and the viewer (`QuestPresenter.new(quest, viewer: current_user)`), used by both the controller and the page bootstrap. This is also the single place D16 is enforced.
- **The server decides state; the browser renders it.** Quest JSON carries a `completed` flag from `Quest#completed?`. The browser never recomputes it.
- **Records are loaded through the current user.** `current_user.steps.find(params[:id])` (via `has_many :steps, through: :quests`), never `Step.find` plus a manual check. Someone else's record is a 404, not a 403.
**Why:** Each rule removes a place where privacy or state can drift between two copies. The third is the stack profile's rule against IDOR.
**Revisit if:** Witnessing needs users to act on records they do not own; that gets its own explicit scope, not an unscoped find.

### D14: Staging environment
**Status:** Accepted (Daniel, 2026-10-09). Written by Daniel before onboarding.
**Context:** Kamal is already configured for the project. *(Phase 0 note: Kamal is installed with placeholder values, not configured. Hosting itself is open, see D6.)*
**Options:**
- Deploy directly to production
- Deploy to a staging environment and then to production
**Decision:** Deploy to a staging environment and then to production at hobby level
**Why:** Staging provides a safe place to test new features before they go live, reducing the risk of breaking the production site. I want this to be there the whole development process so I have a testing ground for agentic work and can observe how the model behaves in a live environment.
**Revisit if:** The staging environment becomes a bottleneck or if the extra deployment step slows down development.

### D15: LLM access through a single swappable adapter
**Status:** Accepted (Daniel, 2026-10-09), including the adapter implementation.
**Context:** The AI task breakdown feature calls an LLM. Cost will be a major running expense and needs tuning, and the provider or model may change for price or quality reasons. Provider calls scattered through the code would make a swap a codebase-wide refactor.
**Options:**
- Own thin adapter (`Llm::Client` interface, one provider implementation).
- Multi-provider gem such as `ruby_llm`.
- Gateway such as OpenRouter.
**Decision:** All LLM calls go through one adapter interface; no provider SDK is called from anywhere else. Provider and model come from config, not code. Every call is logged with tokens, cost, user and feature. Per-user rate limit and a global daily budget cap. Tests and CI use a fake adapter; a contract test against the real provider runs manually or nightly only.
**Phase 0 finding (2026-10-09):** No LLM code exists in the repo: no calls, no SDK, no key lookup, no tests. Nothing to migrate.
**Adapter implementation:** Own thin adapter (`Llm::Client` interface, one implementation on the provider's official SDK, `Llm::Fake` for tests). Reasons in `docs/ARCHITECTURE.md` section 9.
**Why:** Swapping or downgrading a model should be a config change. Costs you cannot see cannot be tuned, and a bug or abusive user must not be able to run up an unbounded bill.
**Revisit if:** A second provider is never needed after a year, or the gateway's cost and data handling would beat maintaining our own adapter.

### D16: Quest visibility is the user's choice per quest; emails are never shown
**Status:** Accepted (Daniel, 2026-10-09). Supersedes D12. Not yet implemented: the skeleton shows every quest and every email to every signed-in user.
**Context:** D12 made every quest owner-only. The design mockups (`docs/design/`) show a choice when naming a quest.
**Options:** Always owner-only (D12); per-quest choice; always visible to the room.
**Decision:** When creating a quest the user picks "say it plainly" (the room sees the task and can witness it) or "keep it vague" (the room sees only "a quiet quest"). Steps and Sage's breakdown follow the same choice. No user's email is ever shown to another user; people appear by a chosen name.
**Why:** Being witnessed is the heart of the product, and it only works if people can choose to be seen. Shame-heavy tasks still need a way to stay private.
**Open for the spec:** which option is the default, whether the choice can be changed later, and where the display name comes from (users have only an email today).
**Revisit if:** Almost nobody picks one of the two options.

---

## 4. Rejected

### D17: "Give & get" balance bar and "Your standing"
**Status:** Rejected (Daniel, 2026-10-09)
**Context:** The mockups show a give-and-get balance ("helped 5 · helped back 4") and a "Your standing · through service" page.
**Options:** Keep as drawn; drop.
**Decision:** Dropped. No visible tally of help given or received, and no standing.
**Why:** It is a score. D11 removed XP because anything countable can become a debt.
**Revisit if:** Witnessing turns out one-sided in the alpha and a gentle, non-numeric nudge is wanted.

---

## 5. Superseded

### D12: Quests are private to their owner; emails are never shown to other users
**Status:** Superseded by D16 (Daniel, 2026-10-09). Was accepted earlier the same day, before the design mockups were reviewed.
**Context:** The skeleton was built room-wide for speed. Task text from people with ADHD is personal.
**Options:** Room-wide visibility; owner-only; owner-only with a reduced public view.
**Decision:** A quest's title and steps are visible only to its owner. No user's email is shown to anyone else.
**Why:** People will not type the task they are ashamed of if strangers can read it.
**Revisit if:** Users ask to share a quest deliberately.
