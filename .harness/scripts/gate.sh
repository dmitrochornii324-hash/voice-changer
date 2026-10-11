#!/bin/bash
# Validation gate. Green gate writes .harness/.gate-pass (checked by the commit hook).
# Usage: .harness/scripts/gate.sh   (exit 0 = green, 1 = red)
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fail=0

PY="$HOME/miniconda3/envs/vcclient-dev/bin/python"
[ -x "$PY" ] || PY=$(command -v python3)

echo "gate:"

# 1. Python syntax across the server tree (fast, catches broken edits)
if "$PY" -m compileall -q server 2>&1 | head -20 | grep -q .; then
  echo "  FAIL server python syntax (compileall)"
  "$PY" -m compileall -q server 2>&1 | head -20
  fail=1
else
  echo "  OK   server python syntax"
fi

# 2. Server entry module parses with its real interpreter (import-level sanity)
if [ -x "$HOME/miniconda3/envs/vcclient-dev/bin/python" ]; then
  if (cd server && "$PY" -c "import ast; ast.parse(open('MMVCServerSIO.py').read())" 2>/dev/null); then
    echo "  OK   MMVCServerSIO.py parses"
  else
    echo "  FAIL MMVCServerSIO.py does not parse"
    fail=1
  fi
fi

# 3. No merge-conflict markers / whitespace damage in the diff
if git diff --check 2>/dev/null | grep -q .; then
  echo "  FAIL git diff --check (conflict markers or whitespace errors)"
  fail=1
else
  echo "  OK   git diff --check"
fi

if [ $fail -eq 0 ]; then
  date +%s > .harness/.gate-pass
  echo "gate: GREEN (.harness/.gate-pass updated)"
else
  rm -f .harness/.gate-pass
  echo "gate: RED"
fi
exit $fail
