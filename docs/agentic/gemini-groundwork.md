**Assumptions Flag:** I am assuming the repository will be hosted on GitHub, standard PostgreSQL is the database of choice, and no frontend testing framework is currently configured.

### 1 & 2. Architectural Decision Points

**DP1: Frontend Architecture** (ONE-WAY DOOR)

* **EXISTING:** Rails monolith using Vite to serve React components.


* **Option A: Stick with Rails + Vite React.** Tradeoff: Simple single-server deployment and unified routing, but couples the frontend tightly to Rails. Right choice if you want to keep infrastructure and dev environment overhead as low as possible for a solo dev.
* **Option B: Split to Rails API + standalone Next.js frontend.** Tradeoff: Clean separation of concerns and easier edge caching, but doubles deployment pipelines and local setup complexity. Right choice if you anticipate heavy client-side state or plan to release a standalone mobile app quickly.
* **Option C: Rails API + Vite SPA.** Tradeoff: Lighter than Next.js while keeping the decoupled API, but loses out-of-the-box server-side rendering for SEO. Right choice if you want strict API separation without Next.js framework overhead.

**DP2: Authentication Approach** (ONE-WAY DOOR)

* **EXISTING:** Devise is currently installed, localized, and configured with views.


* **Option A: Keep Devise.** Tradeoff: Proven, secure, and already stubbed out, but can be heavy and difficult to decouple if moving to an API-only architecture. Right choice if you stick with the monolith and want authentication solved immediately.
* **Option B: Rails 8 Native Authentication.** Tradeoff: Extremely lightweight and built into the framework, but lacks the vast ecosystem of Devise extensions (like easy OAuth integration). Right choice if minimizing gem dependencies is a top priority.

**DP3: Test Framework Strategy** (ONE-WAY DOOR)

* **EXISTING:** None explicitly configured in the provided file tree (Rails default Minitest is assumed).
* **Option A: RSpec + Capybara (Backend) & Jest/React Testing Library (Frontend).** Tradeoff: Highly readable and the industry standard for Rails and React, but requires significant boilerplate to configure. Right choice if you want the agent to write highly descriptive, behaviour-driven tests.


* **Option B: Minitest + System Tests (Backend) & Vitest (Frontend).** Tradeoff: Zero setup for the backend and incredibly fast, but less expressive syntax than RSpec. Right choice if you want to stick to Rails defaults and minimize configuration time.

**DP4: Hosting and Infrastructure** (REVERSIBLE)

* **EXISTING:** Kamal configuration is present in the codebase.


* **Option A: Bare Metal/VPS (e.g., Hetzner, DigitalOcean) via Kamal.** Tradeoff: Extremely cost-effective and fully leverages Docker, but requires manual server provisioning and OS updates. Right choice to maximize profit margins on your hobby scale.
* **Option B: Managed PaaS (e.g., Render, Heroku).** Tradeoff: Zero devops and immediate deployments, but scales poorly in cost as background jobs and databases grow. Right choice if server maintenance sounds distracting to your core product focus.

**DP5: CI/CD Provider** (REVERSIBLE)

* **EXISTING:** Undecided (No CI config files present).


* **Option A: GitHub Actions.** Tradeoff: Deeply integrated with code hosting and has a massive marketplace of pre-built actions, but requires writing YAML workflows from scratch. Right choice if your repository lives on GitHub.
* **Option B: GitLab CI.** Tradeoff: Robust pipeline visualization and built-in container registry, but means hosting the repository on GitLab. Right choice if you prefer an all-in-one DevOps platform.

**DP6: Agentic Workflow & Permissions** (REVERSIBLE)

* **EXISTING:** Undecided.
* **Option A: Local-Only Execution.** Claude Code runs on your local machine, commits to feature branches, and you manually open PRs. Tradeoff: High security and perfect visibility, but the agent cannot work asynchronously while you are away. Right choice for maximum human control and zero cloud secret exposure.
* **Option B: Cloud Execution Environment.** Claude runs in a cloud environment (like GitHub Codespaces), iterating and pushing PRs independently. Tradeoff: Allows asynchronous progress, but requires granting the agent live API tokens and repository write access. Right choice if you want the agent acting as a truly independent contributor.

---

### 3. Draft CI/CD Pipeline Outline

* **Stage 1: Preparation & Linting**
* Run Rubocop, ESLint, and Prettier.


* *Gate:* Must pass to proceed.


* **Stage 2: Security Audit**
* Run Brakeman and Bundler-Audit.


* *Gate:* Must pass to proceed.


* **Stage 3: Automated Testing**
* Run Backend tests (models, controllers, jobs).
* Run Frontend tests (components, hooks).
* Run End-to-End System tests.
* *Gate:* 100% pass rate required. No exceptions.


* **Stage 4: Code Review & Merge (Human Gate)**
* *Gate:* Requires manual human review and sign-off on the Pull Request. Merging to `main` triggers the next stage.


* **Stage 5: Staging Deployment**
* Build Docker image and deploy to the staging environment.


* **Stage 6: Production Deployment (Human Gate)**
* *Gate:* Requires manual human trigger (button click) after verifying staging. Deploys Docker image to production.



---

### 4. Draft ADR Template

```markdown
# ADR [Number]: [Short, descriptive title]

**Date:** YYYY-MM-DD
**Status:** [Proposed | Accepted | Rejected | Superseded]

## Context
[What is the specific problem we need to solve? Why is a decision needed now?]

## Options Considered
* Option 1: [Description]
* Option 2: [Description]
* Option 3: [Description]

## Decision
[What option did we choose?]

## Rationale
[Why was this option chosen? What made it the right choice over the others?]

## Consequences
* **Positive:** [What do we gain?]
* **Negative/Risks:** [What are the tradeoffs, technical debt, or operational burdens introduced?]

```

---