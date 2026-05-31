# Test Coverage Gap Analysis

Perform a four-phase test coverage analysis between an application codebase and its test suite. Produce a structured gap report with coverage percentages, covered/missing scenarios, and a prioritised backlog.

## Arguments

Usage: `/coverage-analysis <app-path> <test-path>`

- `$ARGUMENTS` contains the two paths separated by a space, e.g. `./src ../my-tests`
- If no arguments are given, ask the user for the app codebase path and the test codebase path before proceeding.

---

## Phase 1 — Application Feature Inventory

**Complete this phase fully before moving to Phase 2. Do not begin scenario generation or combination analysis until every feature area has been identified.**

Explore the application source at the first path provided. Read from:
- Controllers / route handlers (every URL and user action the app exposes)
- Service / use-case layer (business logic variations and edge cases)
- Models / DTOs / schemas (all fields, required vs optional, validation rules)
- View templates / UI components (what users see and interact with)
- Plugin / module directories (optional or configurable capabilities)
- API spec files if present (swagger.json, openapi.yaml — all endpoints and response codes)

For each functional area identified, record:
1. Feature name
2. Every user-facing capability (actions a customer or admin can perform)
3. Key variants — who can do it (guest vs. registered vs. admin), what distinct option types exist
4. Expected success states and explicit failure/error states
5. Source code paths — the controller or route file, the service/use-case layer directory, and the domain/model directory that implement this feature (relative to the app root). For plugin-based features record the plugin directory. These paths are carried into the report so readers can trace any gap directly to the implementing code.

**Completeness check before proceeding:** Re-scan the source for areas not yet listed. Each distinct sub-system should appear as its own feature area even if it surfaces inside a larger flow. Plugin and module directories, secondary user roles, and admin-only workflows are commonly missed in a first pass — verify each has been captured.


---

## Phase 2 — Test Suite Inventory

Explore the test codebase at the second path provided. Read from:
- All spec / test files (every `describe` block and `test` / `it` within it)
- Page objects / helpers / support files (all public methods — note which are never called by any test)
- Fixture / setup files (shared preconditions that affect what scenarios are implicitly covered)
- Test data files (factories, JSON fixtures — scope of data variations)

For each test record:
- Exact test name (including tags like @smoke, @regression)
- Steps performed
- What is actually **asserted** (not just navigated)

Also audit every page object / helper: list methods that are defined but never called by any test. These are "quick win" gaps — automation support exists but no test exercises it.

---

## Phase 3 — Scenario Generation

**Work through every feature area recorded in Phase 1 in turn. Do not skip any area. Generate all scenarios for one area before moving to the next.**

For each feature area, generate the complete list of independently testable scenarios using this structure:

```
Happy paths
├── Primary success flow (most common user journey)
└── Each significant variant

Negative / error paths
├── Missing required input → validation error
├── Invalid input format → format error  
├── Input passes format but fails business rule → business error
└── Unauthorised access (action requires login; guest attempts it)

State-dependent paths
├── Action on empty state
├── Action on populated/existing state
└── Persistence (data survives navigation, logout/re-login)
```

**Applying all-pairs testing within each feature area:** For features that have two or more independent parameters (each with two or more values), use the all-pairs rule — https://en.wikipedia.org/wiki/All-pairs_testing — to identify the minimum set of combinations that covers every value of every parameter paired with every value of every other parameter at least once. This replaces exhaustive combinatorial testing, not single-parameter scenarios. For features with only one parameter axis, list each distinct value as its own scenario.

Assign each scenario a priority:

| | High Business Impact | Low Business Impact |
|---|---|---|
| **High Defect Risk** | P0 | P2 |
| **Low Defect Risk** | P1 | P3 |

High business impact = on checkout/payment critical path, or core CRUD that blocks other features.
High defect risk = recently changed, complex logic (tax/pricing/discounts), or known fragile area.

---

## Phase 4 — Gap Analysis & Report

Compare Phase 2 (what is tested) against Phase 3 (what should be tested).

For each feature area calculate:
- **Total scenarios** (from Phase 3)
- **Covered** (a test exists AND asserts the correct outcome — navigation alone does not count)
- **Missing** = Total − Covered
- **Coverage %** = Covered ÷ Total × 100

Then produce the output below.

---

## Output Format

Write the results to a file called `TEST-COVERAGE-REPORT.md` in the test codebase root. Structure:

```markdown
# Test Coverage Report — [App Name]

Generated: [date]
App: [app path]
Tests: [test path]
Total tests: N
Overall coverage: X% (covered / total across ALL feature areas)

## Coverage Summary
[table: # | Feature Area | Scenarios | Covered | Missing | Coverage % | Source Code]

Every feature area identified in Phase 1 must appear as a row in this table — including those with zero tests.
Do not omit any area.

The **Source Code** column is a single column containing all relevant paths for that feature, labelled by layer and separated by `<br>`. Include only the layers that exist for each feature. Use paths relative to the app root.

Example cell value: `**Controller:** src/controllers/CheckoutController.cs<br>**Service:** src/services/Orders/<br>**Domain:** src/core/Domain/Orders/`

Use whichever layer labels best match the technology of the application being analysed: `Controller`, `Route`, `UI`, `API`, `Service`, `Domain`, `Model`, `Plugin`. Every row must have at least one path — never leave the Source Code column empty.

## Detailed Coverage by Feature
[For each area from Phase 1:]
### N. Feature Name — X% (covered/total)
**Source:** `<labelled paths, same format as Coverage Summary column>`
**Covered** — bulleted list with ✓  (omit section if nothing covered)
**Missing** — bulleted list of independently testable scenarios not yet covered

For areas with no existing tests write at minimum 3–5 of the most important missing scenarios.
Do not skip any area. Every feature area from Phase 1 must have its own sub-section here.

## Top Priority Scenarios
### P0 — Critical
[table: # | Scenario | Area | Why Critical]

### P1 — High Impact, Low Effort (POM/helper already exists)
[table: # | Scenario | Area | Existing support]

### P2 — Core Gaps, New Automation Work Required
### P3 — Lower Frequency

## Untested Helper / Page Object Methods
[table: Class | Method | Relevant Scenario]
```

After writing the file, summarise the results to the user:
- Overall coverage %
- Top 3 feature areas by coverage (best covered)
- Top 3 feature areas with biggest gaps
- Count of P0 items
- Count of quick-win P1 items (existing POM/helper support)
