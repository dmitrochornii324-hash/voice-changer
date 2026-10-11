# AGENTS.md — orchestration guide

## What this project is

A fork of [w-okada/voice-changer](https://github.com/w-okada/voice-changer) being turned into a
simplified Windows desktop voice-changer app (RVC-only, realtime mic conversion into a virtual
microphone, later TTS and model training).

**Source of truth for scope and decisions: `PROJECT_PLAN.md`.** Read it before planning any
non-trivial work. `Linux_instal_history.md` documents the known-good Linux dev environment setup.

## Phase discipline

We are in **Phase 1 (MVP: realtime voice change)**. Do not implement Phase 2 (TTS) or Phase 3
(training) features unless the user explicitly asks. Do not design abstractions "for later phases".

Phase 1 scope, in order:
1. Strip non-RVC model support (MMVC, so-vits-svc, DDSP-SVC, DiffusionSVC, LLVC, EasyVC, Beatrice).
2. Server device mode as the default audio path.
3. Minimal UI (model slot, input device, pitch, on/off) wrapped in a desktop window.
4. PyInstaller + Inno Setup packaging.

## Architecture map

| Path | What it is |
| --- | --- |
| `server/MMVCServerSIO.py` | Entry point: uvicorn + REST + Socket.IO, port 18888 |
| `server/restapi/` | REST API (config, model upload, settings) |
| `server/sio/` | Socket.IO audio streaming (client device mode) |
| `server/voice_changer/RVC/` | RVC pipeline: embedder → pitch extractor → inferencer |
| `server/voice_changer/Local/ServerDevice.py` | Server device mode (`sounddevice`, our default path) |
| `server/voice_changer/VoiceChangerManager.py` | Orchestration, model slots |
| `client/demo/` | React/TS web UI, served as static files by the server |
| Other dirs under `server/voice_changer/` | Non-RVC models — scheduled for removal, do not extend |

## Environment facts (do not rediscover these)

- Dev machine is **Linux**; the product target is **Windows**. Anything platform-specific must
  work on Windows (audio devices, paths, packaging).
- Python env: conda env `vcclient-dev`, **Python 3.10** (newer Python breaks the legacy deps).
- Fragile legacy dependency stack: requires `pip<24.1`, `setuptools<81`, `fairseq==0.12.2`,
  `pyworld==0.3.4`; onnxruntime needs `patchelf --clear-execstack` on new glibc. Details and
  fixes: `Linux_instal_history.md`.
- Running/stopping the dev server, virtual audio routing, troubleshooting: use the
  `run-voice-server` skill.
- Packaging questions (PyInstaller, Inno Setup, VB-Cable licensing): use the `windows-packaging`
  skill.

## Conventions

- **Talk to the user in Ukrainian.** Write code, comments, commit messages, and docs in English.
- Keep upstream `LICENSE` (MIT, Wataru Okada) intact in any distribution.
- Never commit model weights or large binaries (`*.pth`, `*.onnx`, `*.pt`, `pretrain/`,
  `model_dir/`). A hook guards commits, but do not rely on it.
- Removal of non-RVC models must be done in dedicated, revertible commits
  (e.g. one commit per model family or one "remove non-RVC models" commit).
- New Python dependencies: pin exact versions, verify they install on Windows and are
  PyInstaller-friendly before adopting. Prefer ONNX-based paths over new PyTorch deps.

## Harness workflow (dev-harness style)

Work is driven by documents in `.harness/` (manifest: `.harness/project.yaml`):

- **PRDs** (`.harness/prds/`) define scoped deliverables; **tickets** (`.harness/tickets/`)
  are their small, ordered work items. Templates in `.harness/templates/` (PRD, TICKET, ADR).
- **MEMORY** (`.harness/MEMORY.md`): read it before non-trivial work; append durable
  learnings when closing tickets. **RISKS** (`.harness/RISKS.md`): keep the register current.
- **Gate** (`.harness/scripts/gate.sh`): must be GREEN before committing code — the commit
  hook checks for a fresh `.harness/.gate-pass`. **Doctor** (`.harness/scripts/doctor.sh`):
  environment diagnostics.
- Command skills: `dh-plan` (feature → PRD + tickets), `dh-build` (execute next ticket),
  `dh-gate`, `dh-doctor`. Significant architectural choices get an ADR in `.harness/adrs/`.

## Orchestration

- Broad "how does X work in this codebase" questions → spawn an `explore` subagent instead of
  grepping manually across the whole tree.
- After substantive edits, check linters (ReadLints) and run the gate; for server changes also
  verify the server still boots: see `run-voice-server` skill for the exact commands.
- Definition of done for any server change: gate GREEN and
  `python MMVCServerSIO.py -p 18888 --https false` starts cleanly with the RVC path working.
- Commit messages: conventional, English, no AI attributions (hook-enforced).
- When the user asks for a code review, use the Bugbot subagent.
