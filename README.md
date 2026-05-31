# claude-skills

Reusable Claude Code slash command skills. Install once on any machine and use them across all projects.

## Install

```bash
git clone https://github.com/jagannathbalachandran/claude-skills
cd claude-skills
bash install.sh
```

Restart Claude Code after installing. Skills are placed in `~/.claude/commands/` and become available globally in every project.

## Update

```bash
cd claude-skills
git pull
bash install.sh
```

## Skills

### `/coverage-analysis <app-path> <test-path>`

Performs a four-phase test coverage gap analysis between an application codebase and its test suite.

**Usage:**
```
/coverage-analysis ./my-app ./my-tests
/coverage-analysis ../nopCommerce ../nopcommerce-playwright
```

**What it does:**
1. **App Inventory** — Reads controllers, services, models, views and plugins to build a complete feature + capability list
2. **Test Inventory** — Reads all spec files and page objects; flags every untested helper method as a quick win
3. **Scenario Generation** — Produces all testable scenarios using happy path / negative / state-dependent structure with a "one of each type" rule (no combinatorial explosion)
4. **Gap Analysis** — Calculates coverage % per feature, produces a P0–P3 prioritised backlog, writes `TEST-COVERAGE-REPORT.md` to the test repo root

**Output:** `TEST-COVERAGE-REPORT.md` written to the test codebase root, plus a summary in the Claude Code session.

Works with any stack — ASP.NET, Spring Boot, Django, Express, Rails on the app side; Playwright, Cypress, Jest, pytest, JUnit on the test side.

---

## Adding a New Skill

1. Create `commands/my-skill-name.md` — the filename becomes the slash command (`/my-skill-name`)
2. Write the skill prompt in the file (see existing skills for structure)
3. Run `bash install.sh` to apply locally
4. Commit and push — other machines update with `git pull && bash install.sh`
