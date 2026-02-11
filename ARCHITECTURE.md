# Report 001 — Dobby Portable Operator Architecture (Hatch Spec)

## Purpose
Design a portable, OS-wipe-proof operator (“Dobby”, later renamed to “Zenny the Worm”) that can be installed on any machine and resume work by pointing to an external state directory. Zenny-openclaw is temporary scaffolding; dobby-operator is the long-term clean-room implementation.

## Non-negotiables
- **Propose → Review → Approve → Execute → Log** governance.
- **Code and state separated** (repo contains code only; state lives outside repo).
- **No marketplace installs**; third-party skills/extensions are never installed.
- **No daemons by default** (manual run; services only after explicit decision).
- **Local-first** default mode; cloud models are opt-in “Hatch mode”.

---

## 1) Repository layout (future `dobby-operator`)

dobby-operator/
README.md
ARCHITECTURE.md
SECURITY_MODEL.md
RUNBOOK.md
CHANGELOG.md

src/
core/
job.ts # job schema + lifecycle transitions
approvals.ts # approval gate enforcement
planner.ts # proposal generation orchestration (no tools)
executor.ts # execute approved steps via adapters (guarded)
redaction.ts # secret/PII scrubbers for logs/artifacts
evidence.ts # evidence bundle builder (what/why/outputs)
policies/
  tool_allowlist.ts      # allowed tools/actions, bounded + typed
  command_allowlist.ts   # shell command templates / denylist
  network_policy.ts      # outbound allowlist, “no marketplace” enforcement
  budgets.ts             # token/tool/time budgets per mode

adapters/
  fs.ts                  # read/write within state/workspace boundaries
  git.ts                 # clone, branch, commit, PR prep (no push without approval)
  shell.ts               # guarded command runner (explicit allowlist)
  http.ts                # optional: restricted outbound fetcher
  notify.ts              # telegram/email/webhook (optional later)

cli/
  dobby.ts               # CLI entry: propose/review/approve/execute/status
  commands/
    propose.ts
    review.ts
    approve.ts
    execute.ts
    status.ts
    bundle.ts

ui/                      # optional web/TUI later (display-only by default)

prompts/
system/
hatch.md # creative design mode (no exec)
safe.md # execution-safe mode (local-first)
templates/
job.md # job template
review_checklist.md
pr_template.md

config/
defaults/
dobby.json # safe defaults, no secrets
examples/
dobby.example.json
schema/
dobby.schema.json

scripts/
install/
linux.sh # idempotent installer
windows.ps1
audit/
secret-scan.sh
lint.sh

.gitignore
LICENSE


**Repo rule:** no state, no secrets, no DB dumps, no tokens.

---

## 2) External State layout (the “portable brain”)
Root: `DOBBY_STATE_DIR=/mnt/ai/dobby/state` (or `/media/zen/AI/...`)

state/
secrets/ # env files, tokens, credentials (chmod 700)
providers.env # optional; not required for safe mode
channels.env # optional
memory/
MEMORY.md # durable facts/decisions/lessons
CONTEXT.md # active projects snapshot
compactions/ # older compactions archived
jobs/
inbox/ # proposed jobs (human or planner)
proposed/ # Zenny/Dobby proposals (draft)
approved/ # approved for execution
running/
done/
failed/
logs/
audit.log # append-only governance log
runs/ # per-run logs
artifacts/
reports/ # markdown/html/pdf reports
patches/ # full replacement files + diffs
bundles/ # zipped “evidence packs”
workspace/
repos/ # working checkouts
tmp/ # throwaway temp


### Retention / pruning
- `audit.log`: keep forever (rotate yearly if desired).
- `logs/runs`: keep 30–90 days, then bundle + prune.
- `jobs/done`: keep 30–90 days, then archive to `artifacts/bundles`.
- `workspace/tmp`: wipe daily.
- `memory`: compact weekly or at “session end”.

---

## 3) Git repo strategy (3 repos)
### A) `zen-lab-spine` (Pop-Tart)
- zrouter, ZenOps, dashboards, firewall docs/runbooks, service compose files.
- Branching:
  - `main` = stable
  - `staging` = tested changes
  - `exp/*` = short-lived experiments

### B) `zenny-openclaw` (ZenPop Forge scaffold)
- Your fork of OpenClaw + hardening + integration notes.
- Branching:
  - `main` tracks upstream (rebases/merges)
  - `zen/hardening-*` for your changes
- Policy: no secrets; state stays on AI drive.

### C) `dobby-operator` (Long-term portable operator)
- Clean-room operator code, governance, adapters.
- Branching:
  - `main`, `dev`, feature branches via PR
- CI:
  - lint, tests, secret scan, “no state files committed” enforcement.

---

## 4) Minimal rebuild checklists

### ZenPop Forge rebuild
1. Install baseline tools: `git curl jq rg fd tree ncdu python3-venv nodejs`
2. Mount AI drive `/media/zen/AI`
3. Clone `zenny-openclaw` into `/media/zen/AI/zenny/repo`
4. `pnpm config set store-dir /media/zen/AI/zenny/pnpm-store`
5. `pnpm install`
6. Create `forge.env` with:
   - `OPENCLAW_STATE_DIR=/media/zen/AI/zenny/state/openclaw`
   - `OPENCLAW_CONFIG_PATH=/media/zen/AI/zenny/state/openclaw/openclaw.json`
   - `OPENCLAW_HOME=/media/zen/AI/zenny/state/openclaw/home`
   - `OPENCLAW_SKIP_CHANNELS=1`
   - `OPENCLAW_SKIP_PROVIDERS=1` (safe mode)
7. Start gateway manually: `node scripts/run-node.mjs gateway`
8. Start TUI: `pnpm tui`
9. Verify: no `~/.openclaw*`, gateway only on `127.0.0.1:7337`

### Pop-Tart Spine rebuild
1. Restore network spine and firewall rules from documented runbook
2. Bring up zrouter + ZenOps
3. Validate core endpoints and auth tokens
4. Pull `zen-lab-spine` and apply only approved changes
5. Confirm “tickets before tools” and approval gates

---

## 5) Model profile switch (Hatch vs Safe)
### Hatch mode (Opus)
- Goal: architecture/design/spec writing only.
- Providers allowed; keys required (optional).
- Tooling restricted to “write artifacts/jobs”, no execution adapters.

### Safe mode (Local-first)
- Default.
- Providers blocked: `OPENCLAW_SKIP_PROVIDERS=1`
- Channels blocked: `OPENCLAW_SKIP_CHANNELS=1`
- Used for running checklists, validations, and approved execution tasks.

### Enforcement
- Two launch scripts (already created in `/media/zen/AI/zenny/`).
- Job types:
  - `proposal/*` may use Hatch mode.
  - `execute/*` must run Safe mode and require explicit approval.

---

## 6) Anti-patterns (“don’t do this” list)
- Running “doctor --fix” or dev launchers without reading what they change (services, home dirs).
- Letting an agent both propose and execute without a human gate.
- Letting UI/avatar layer have tool authority.
- Allowing marketplace installs or dynamic extensions.
- Storing state under `~` (breaks portability, splits history).
- Mixing “spine” services and “forge” experiments on the same stability tier.

---

## Next steps (recommended order)
1. Keep OpenClaw running in **Safe mode** (no providers, no channels).
2. Create Job 002: “Repo separation + GitHub remotes + ignore rules”.
3. Create Job 003: “Approval gate wrapper (propose/review/approve/execute) as filesystem workflow”.
4. Start `dobby-operator` repo as clean-room and use Zenny-openclaw only as scaffolding/reference.
