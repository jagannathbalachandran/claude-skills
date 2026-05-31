# Test Coverage Gap Analysis

Perform a four-phase test coverage analysis between an application codebase and its test suite. Produce a structured gap report with coverage percentages, covered/missing scenarios, and a prioritised backlog.

## Arguments

Usage: `/coverage-analysis <app-path> <test-path>`

- `$ARGUMENTS` contains the two paths separated by a space, e.g. `./src ../my-tests`
- If no arguments are given, ask the user for the app codebase path and the test codebase path before proceeding.

---

## Phase 1 — Application Feature Inventory

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

**Counting rule:** Count each distinct *type* of option once — not every combination. Three payment methods × four shipping methods = 3 payment scenarios + 4 shipping scenarios (7 total), not 12.

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

For each feature area from Phase 1, generate the complete list of independently testable scenarios using this structure:

```
Happy paths
├── Primary success flow (most common user journey)
└── Each significant variant (one per option type, not every combination)

Negative / error paths
├── Missing required input → validation error
├── Invalid input format → format error  
├── Input passes format but fails business rule → business error
└── Unauthorised access (action requires login; guest attempts it)

State-dependent paths
├── Action on empty state (empty cart, no addresses, no orders)
├── Action on populated/existing state
└── Persistence (data survives navigation, logout/re-login)
```

Apply the "one of each type" rule throughout — do not generate combinatorial scenarios unless the *interaction* between two options is specifically what is under test.

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
Overall coverage: X%

## Coverage Summary
[table: Feature Area | Scenarios | Covered | Missing | Coverage %]

## Detailed Coverage by Feature
[For each area:]
### N. Feature Name — X% (covered/total)
**Covered** — bulleted list with ✓
**Missing** — bulleted list

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
