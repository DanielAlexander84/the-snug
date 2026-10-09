# Decisions

<!-- One entry per one-way door or notable choice. Newest at the top. Short is fine. -->

## [YYYY-MM-DD] [Decision title]
**Context:** [What forced the decision.]
**Options:** [The real alternatives.]
**Decision:** [What we chose.]
**Why:** [The reason that would still convince you in a year.]
**Revisit if:** [The condition that would make this wrong.]

## 2026-10-09 Staging environment
**Context:** Kamal is already configured for the project.
**Options:**
- Deploy directly to production
- Deploy to a staging environment and then to production
**Decision:** Deploy to a staging environment and then to production at hobby level
**Why:** Staging provides a safe place to test new features before they go live, reducing the risk of breaking the production site. I want this to be there the whole development process so I have a testing ground for agentic work and can observe how the model behaves in a live environment.
**Revisit if:** The staging environment becomes a bottleneck or if the extra deployment step slows down development.

## 2026-10-09 LLM access through a single swappable adapter
**Status:** Proposed. Needs Daniel's sign-off before any AI-related work.
**Context:** The AI task breakdown feature calls an LLM. Cost will be a major
running expense and needs tuning, and the provider or model may change for
price or quality reasons. Provider calls scattered through the code would
make a swap a codebase-wide refactor.
**Options:**
- Own thin adapter (`Llm::Client` interface, one provider implementation).
- Multi-provider gem such as `ruby_llm`.
- Gateway such as OpenRouter.
**Decision:** All LLM calls go through one adapter interface; no provider SDK
is called from anywhere else. Provider and model come from config, not code.
Every call is logged with tokens, cost, user and feature. Per-user rate limit
and a global daily budget cap. Tests and CI use a fake adapter; a contract
test against the real provider runs manually or nightly only.
Adapter implementation: OPEN, decided after Phase 0 shows how the feature is
wired today.
**Why:** Swapping or downgrading a model should be a config change. Costs you
cannot see cannot be tuned, and a bug or abusive user must not be able to run
up an unbounded bill.
**Revisit if:** A second provider is never needed after a year, or the
gateway's cost and data handling would beat maintaining our own adapter.