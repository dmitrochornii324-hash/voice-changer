# MEMORY — durable project knowledge

Append dated entries. Consolidate (merge/prune stale entries) when this file exceeds ~150 lines.

## 2026-10-11

- Fork of w-okada/voice-changer (v1 codebase, MIT). v2 sources are not public; no upstream v2 to track.
- Scope and decisions live in `PROJECT_PLAN.md`; phase 1 = RVC-only realtime voice change, big offline installer.
- Beatrice code in this repo is a closed v1.1.0 binary API: commercial use prohibited, redistribution needs permission — strong reason it gets removed with the other non-RVC models.
- Known-good dev env: Linux, conda `vcclient-dev`, Python 3.10, `pip<24.1`, `setuptools<81`, `fairseq==0.12.2`, `pyworld==0.3.4`; onnxruntime needs `patchelf --clear-execstack` on glibc ≥ 2.41. Full bootstrap: `Linux_instal_history.md`.
- Working Linux audio routing: mic → server RVC → `VC_Out` null-sink → `VC_Mic` remap-source → messenger. Telegram works; Signal voice messages usually capture the real mic.
- VB-Cable: bundling in the installer requires written permission from VB-Audio (even non-commercial). Fallback: installer downloads from official vb-audio.com.
- T-001 (strip non-RVC): RMVPE pitch extractor lived in `DiffusionSVC/` but is used by RVC — moved to `voice_changer/RVC/pitchExtractor/rmvpe/` before deleting the family. Whisper embedder was EasyVC-only, removed with it. Legacy `VoiceChanger` (v1) orchestrator served only removed families; `VoiceChangerV2` is the sole path now.
- Keep in requirements despite looking unused: `websockets` (uvicorn ws backend), `matplotlib` (imported by the VoRAS inferencer). Removed with T-001: gin, gin_config, einops, local_attention, dataclasses_json.
- `POST /update_settings` expects multipart form fields (`curl -F key=... -F val=...`), not JSON. First `/test` conversion call is a warmup that returns zeros while the SOLA buffer fills; judge output from the second call onward.
- `client/demo/dist/` is git-tracked and served by the server — after client/src changes run `npm run build:prod` in `client/demo` and commit the rebuilt dist together with the sources.
