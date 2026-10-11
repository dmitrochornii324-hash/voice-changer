---
name: dh-doctor
description: Diagnose the development environment (conda env, Python version, core imports, port, harness files). Use when the user invokes /dh-doctor, when the server fails to start for environment reasons, or when setting up on a new machine.
---

# dh-doctor — environment diagnostics

Run:

```bash
.harness/scripts/doctor.sh
```

Interpreting failures:

- `conda env vcclient-dev not found` / wrong Python → bootstrap per `Linux_instal_history.md`
  (Miniconda, Python 3.10, pinned pip/setuptools).
- `core imports failed` → dependency stack broken; fixes table in the `run-voice-server`
  skill (fairseq/pip pins, onnxruntime patchelf, pyworld).
- `port 18888 busy` → a server instance is running; stop via `run-voice-server` skill
  before starting another.
- Missing harness files → restore from git; `PROJECT_PLAN.md` and `.harness/` are the
  project's source of truth and must exist.
