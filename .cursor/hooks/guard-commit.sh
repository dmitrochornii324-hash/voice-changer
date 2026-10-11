#!/bin/bash
# Commit guard (dev-harness style "commit locks"):
#   1. deny AI attributions in commit messages
#   2. block model weights / files >50MB
#   3. require a green gate (.harness/.gate-pass) newer than the staged files
input=$(cat)
command=$(echo "$input" | jq -r '.command // empty')

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || { echo '{ "permission": "allow" }'; exit 0; }

# --- 1. AI attribution in the commit message (deny outright) ---
if echo "$command" | grep -qiE 'co-authored-by:.*(claude|cursor|ai\b|gpt)|generated (with|by).*(claude|cursor|ai\b|gpt)|🤖'; then
  echo '{
    "permission": "deny",
    "user_message": "Commit message contains an AI attribution (Co-Authored-By / Generated with / 🤖). Project convention: plain conventional commits, no AI mentions.",
    "agent_message": "Hook denied: remove AI attribution lines from the commit message and commit again with a plain conventional message."
  }'
  exit 0
fi

# --- 2. model weights / oversized files staged ---
limit=$((50 * 1024 * 1024))
flagged=""
newest_staged=0
while IFS= read -r file; do
  [ -f "$file" ] || continue
  mtime=$(stat -c %Y "$file" 2>/dev/null || echo 0)
  [ "$mtime" -gt "$newest_staged" ] && newest_staged=$mtime
  case "$file" in
    *.pth|*.pt|*.onnx|*.safetensors|*.ckpt) flagged="$flagged $file"; continue ;;
  esac
  size=$(stat -c%s "$file" 2>/dev/null || echo 0)
  [ "$size" -gt "$limit" ] && flagged="$flagged $file"
done < <(git diff --cached --name-only --diff-filter=ACM)

if [ -n "$flagged" ]; then
  jq -n --arg files "$flagged" '{
    permission: "ask",
    user_message: ("Commit includes model weights or files >50MB:" + $files + " — these should normally be gitignored."),
    agent_message: ("Hook: staged files look like model weights or exceed 50MB:" + $files + ". Per AGENTS.md, weights must not be committed. Unstage or gitignore them unless the user explicitly wants them in git.")
  }'
  exit 0
fi

# --- 3. gate freshness (only when code is staged, not for docs/harness-only commits) ---
code_staged=$(git diff --cached --name-only --diff-filter=ACM | grep -cE '^(server|client)/' || true)
if [ "$code_staged" -gt 0 ]; then
  gate_time=0
  [ -f .harness/.gate-pass ] && gate_time=$(cat .harness/.gate-pass 2>/dev/null || echo 0)
  if ! [ "$gate_time" -ge "$newest_staged" ] 2>/dev/null; then
    echo '{
      "permission": "ask",
      "user_message": "Committing code without a green gate (.harness/scripts/gate.sh) run after the last edit.",
      "agent_message": "Hook: no green gate newer than the staged changes. Run .harness/scripts/gate.sh; commit only when it reports GREEN (see dh-gate skill)."
    }'
    exit 0
  fi
fi

echo '{ "permission": "allow" }'
exit 0
