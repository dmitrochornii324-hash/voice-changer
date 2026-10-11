---
name: dh-gate
description: Run the project validation gate (syntax, entry parse, diff hygiene) and interpret failures. Use when the user invokes /dh-gate, before committing changes, or when the commit hook reports a stale or missing gate.
---

# dh-gate — validation gate

Run:

```bash
.harness/scripts/gate.sh
```

- GREEN writes `.harness/.gate-pass`; the commit hook accepts commits only while that
  marker is newer than the staged files.
- RED: fix every reported failure and re-run. Do not bypass by touching `.gate-pass`
  manually.
- The gate is intentionally fast (no server boot, no weight downloads). For server
  changes, full verification = gate + server boot check from the `run-voice-server` skill.
- When phase 1 adds tooling (lint, tests, client build), extend `gate.sh` — the gate is
  the single place "is this change OK" lives.
