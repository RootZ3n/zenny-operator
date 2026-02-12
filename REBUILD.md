# Rebuild Checklist (ZenPop Forge + Zenny Operator)

Goal: from fresh OS to working Zenny stack with everything on the AI drive.

## Assumptions
- AI drive mounted at: `/media/zen/AI`
- Zenny paths:
  - OpenClaw fork: `/media/zen/AI/zenny/repo`
  - OpenClaw state: `/media/zen/AI/zenny/state/openclaw`
  - Zenny Operator repo: `/media/zen/AI/dobby-operator/repo` (repo name is zenny-operator on GitHub)

## 0) Baseline packages
Install your common tools (as needed):
- git, curl, wget, jq, unzip, zip
- ripgrep, tree
- build essentials if compiling anything

Example:
```bash
sudo apt update
sudo apt install -y git curl wget jq unzip zip ripgrep tree


