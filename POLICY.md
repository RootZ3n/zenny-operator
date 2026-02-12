# Zenny Operator Policy

This repo defines the portable operator (“Dobby” codename) that will later become Zenny (Worm identity).
The repo contains code + policy only. Runtime state is always external.

## Core principles
- **Propose → Review → Approve → Execute → Log**
- **No marketplace installs.** Browsing for ideas is fine; installing third-party skills/extensions is not.
- **State is external.** Nothing under DOBBY_STATE_DIR is ever committed.
- **No daemons by default.** Manual start/stop unless explicitly approved and documented.
- **Local-first by default.** Cloud models are opt-in for Hatch mode only.

## Roles (conceptual)
- **Operator (Zenny/Dobby):** proposes plans, generates artifacts, prepares commands.
- **Human (Zen):** approves execution. Always.
- **QC model (Codex/GPT/etc):** reviews diffs/scripts before execution when enabled.

## Execution gating
Execution is only allowed when all are true:
1) A job exists in `jobs/inbox/` with a unique ID.
2) The job has moved to `jobs/approved/` (human-approved).
3) The run writes an evidence bundle to `artifacts/`:
   - what changed
   - why
   - commands run
   - files written (full replacements)
   - verification steps and outputs
4) Secrets are never printed or stored in artifacts.

## Mode definitions
### Hatch mode (proposal-only)
- Cloud providers allowed (e.g., Opus) for architecture/design/specs.
- No system modifications.
- Output: docs, plans, job drafts, suggested diffs.

### Safe mode (default)
- Providers off unless explicitly enabled.
- Channels disabled unless explicitly enabled.
- Emphasis: repeatability, minimal risk, deterministic changes.

## Anti-patterns (meltdown lessons)
- “Just run this” without review
- Mixing state into repos
- Hidden services/daemons spawning unexpectedly
- Debugging by random config edits
- Treating an agent suggestion as truth without verification

