#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Common secret-ish markers. Conservative on purpose.
PATTERN='(OPENAI_API_KEY|ANTHROPIC_API_KEY|GEMINI_API_KEY|OPENROUTER_API_KEY|TOKEN=|SECRET=|BEGIN PRIVATE KEY|xoxb-|sk-[A-Za-z0-9]{20,}|sk-ant-)'

# Scan tracked files by letting rg walk the repo.
# Exclude this scanner and other common noisy paths.
if rg -n -S --hidden --no-ignore-vcs "$PATTERN" \
  --glob '!.git/**' \
  --glob '!node_modules/**' \
  --glob '!.pnpm-store/**' \
  --glob '!pnpm-store/**' \
  --glob '!dist/**' \
  --glob '!build/**' \
  --glob '!scripts/secret-scan.sh' ; then
  echo
  echo "❌ Potential secret detected. Remove it before committing."
  exit 1
else
  echo "✅ Secret scan clean."
fi
