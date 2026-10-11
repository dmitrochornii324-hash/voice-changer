#!/bin/bash
# Environment diagnostics for the voice-changer harness. Mechanical, no AI needed.
# Usage: .harness/scripts/doctor.sh   (exit 0 = healthy, 1 = problems found)
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fail=0
ok()   { echo "  OK   $1"; }
bad()  { echo "  FAIL $1"; fail=1; }
warn() { echo "  WARN $1"; }

echo "harness doctor:"

# tooling
for bin in git jq rg; do
  command -v "$bin" >/dev/null && ok "$bin available" || bad "$bin missing"
done

# conda env with python 3.10
if [ -x "$HOME/miniconda3/envs/vcclient-dev/bin/python" ]; then
  pyver=$("$HOME/miniconda3/envs/vcclient-dev/bin/python" -c 'import sys; print("%d.%d" % sys.version_info[:2])')
  [ "$pyver" = "3.10" ] && ok "conda env vcclient-dev (python $pyver)" || bad "vcclient-dev python is $pyver, expected 3.10"
else
  bad "conda env vcclient-dev not found (see Linux_instal_history.md)"
fi

# critical imports inside the env
if [ -x "$HOME/miniconda3/envs/vcclient-dev/bin/python" ]; then
  if "$HOME/miniconda3/envs/vcclient-dev/bin/python" -c "import torch, onnxruntime, sounddevice" 2>/dev/null; then
    ok "torch/onnxruntime/sounddevice import"
  else
    bad "core imports failed in vcclient-dev (torch/onnxruntime/sounddevice)"
  fi
fi

# port 18888
if command -v fuser >/dev/null && fuser 18888/tcp >/dev/null 2>&1; then
  warn "port 18888 busy (server already running?)"
else
  ok "port 18888 free"
fi

# harness files
for f in PROJECT_PLAN.md AGENTS.md .harness/MEMORY.md .harness/RISKS.md; do
  [ -f "$f" ] && ok "$f present" || bad "$f missing"
done

[ $fail -eq 0 ] && echo "doctor: healthy" || echo "doctor: problems found"
exit $fail
