#!/bin/bash
# Guard: pip install of new packages must respect the frozen legacy dependency stack.
# Allows reinstalling from requirements.txt; asks for anything else.
input=$(cat)
command=$(echo "$input" | jq -r '.command // empty')

# Installing from the pinned requirements file is always fine.
if [[ "$command" == *"-r requirements.txt"* || "$command" == *"-r server/requirements.txt"* ]]; then
  echo '{ "permission": "allow" }'
  exit 0
fi

echo '{
  "permission": "ask",
  "user_message": "pip install outside requirements.txt: this project runs a frozen legacy stack (Python 3.10, pip<24.1, fairseq 0.12.2). New deps must be pinned in server/requirements.txt and be Windows/PyInstaller-compatible.",
  "agent_message": "Hook: installing a package not from requirements.txt. If this dependency is being adopted, pin the exact version in server/requirements.txt and confirm Windows + PyInstaller compatibility (see AGENTS.md conventions)."
}'
exit 0
