#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Common secret-ish markers. Conservative on purpose.
PATTERN='(OPENAI_API_KEY|ANTHROPIC_API_KEY|GEMINI_API_KEY|OPENROUTER_API_KEY|TOKEN=|SECRET=|BEGIN PRIVATE KEY|xoxb-|sk-[A-Za-z0-9]{20,}|sk-ant-)'

# Only scan tracked files, but exclude this script (it contains the pattern).
FILES="$(git ls-files)"

if echo "$FILES" | xargs -r rg -n -S "$PATTERN" --glob '!scripts/secret-scan.sh' ; then
  echo
  echo "❌ Potential secret detected. Remove it before committing."
  exit 1
else
  echo "✅ Secret scan clean."
fi
