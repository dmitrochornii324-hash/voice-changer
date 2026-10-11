# T-001: Strip non-RVC model families and their dependencies

- **PRD**: .harness/prds/PRD-001-phase1-mvp.md
- **Status**: done
- **Date**: 2026-10-11

## Goal

Remove MMVC v13/v15, so-vits-svc 4.0, DDSP-SVC, DiffusionSVC, LLVC, EasyVC, and Beatrice from
the server so the dependency set and maintenance surface shrink to RVC only.

## Steps

- [x] Inventory imports of each family dir under `server/voice_changer/` (entry: `VoiceChangerManager`, `const.py`, REST/sio handlers).
- [x] Remove family dirs + their registrations, one commit per family (revertible).
- [x] Prune now-unused packages from `server/requirements.txt` (verify nothing RVC-side imports them).
- [x] Remove dead UI branches for removed families in `client/demo`.
- [x] Run gate; boot server; verify RVC conversion still works end-to-end.

## Done when

Server boots with only RVC model slots; `rg -i "beatrice|sovits|ddsp|diffusion|llvc|easyvc|mmvc"` in
`server/` returns only historical mentions (e.g. entry filename), gate passes.

## Notes

Beatrice removal also closes license risk R-3 (closed binary, no redistribution).
