# Runbook

## Goals
- Install anywhere (Linux/Windows/macOS)
- Point to `DOBBY_STATE_DIR`
- Resume work safely after OS wipes
- Enforce: Propose → Review → Approve → Execute → Log

## Quick start (developer)
1) Clone repo:
   - `git clone <repo-url> dobby-operator`
2) Set state dir (example):
   - `export DOBBY_STATE_DIR=/media/zen/AI/dobby-operator/state`
3) Create state skeleton:
   - `mkdir -p "$DOBBY_STATE_DIR"/{jobs/{inbox,proposed,approved,running,done,failed},artifacts/{reports,patches,bundles},logs/runs,memory,secrets,workspace/{repos,tmp}}`
   - `chmod 700 "$DOBBY_STATE_DIR" "$DOBBY_STATE_DIR/secrets"`
4) Run in Safe mode (default): local-first, no external providers.

## Modes
### Hatch mode (proposal-only)
- Cloud models allowed (Opus/etc)
- Writes: specs, plans, job proposals
- Does **not** execute system changes

### Safe mode (default)
- Providers off unless explicitly enabled
- Execution requires approved job + allowlisted actions

## Governance
- Every execution must reference a job ID.
- Outputs are saved as artifacts with an evidence bundle:
  - what changed
  - why
  - commands run
  - files written (full replacements)
  - checks performed

## No-daemon policy
- Default is manual start/stop.
- Services only after explicit decision and documented runbook steps.
