#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

PATTERN='(OPENAI_API_KEY|ANTHROPIC_API_KEY|GEMINI_API_KEY|OPENROUTER_API_KEY|TOKEN=|SECRET=|BEGIN PRIVATE KEY|xoxb-|sk-[A-Za-z0-9]|sk-ant-)'

FILES="$(git ls-files)"
if echo "$FILES" | xargs -r rg -n -S "$PATTERN" ; then
  echo
  echo "❌ Potential secret detected. Remove it before committing."
  exit 1
else
  echo "✅ Secret scan clean."
fi
