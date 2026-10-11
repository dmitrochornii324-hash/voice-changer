---
name: windows-packaging
description: Package the voice-changer app into a Windows installer with PyInstaller and Inno Setup, including VB-Cable handling and size/licensing constraints. Use when working on the installer, PyInstaller spec, Inno Setup script, VB-Cable integration, or Windows distribution of the app.
---

# Windows packaging

## Target

One full offline installer (accepted size: 2–4 GB with CUDA runtime). Toolchain:
**PyInstaller** (freeze the Python server + deps) → **Inno Setup** (installer UX, VB-Cable step).
There are no packaging scripts in the upstream repo — everything here is built by us.

## PyInstaller guidance

- Freeze from a **Windows machine or Windows CI** — PyInstaller does not cross-compile.
- Entry point: `server/MMVCServerSIO.py`. The server uses `multiprocessing` →
  call `multiprocessing.freeze_support()` first thing under `if __name__ == "__main__"`.
- Known hidden-import troublemakers in this stack: `fairseq`, `torchaudio`, `onnxruntime`
  provider DLLs, `librosa` (lazy loaders), `scipy`. Add them to `hiddenimports` /
  `collect_all` in the spec as failures appear; test the frozen exe after each fix.
- Bundle data: `client/demo` build output (static UI), `model_dir_static/`. Pretrained weights
  (hubert, rmvpe, crepe) should ship inside the installer, not download at first run.
- Prefer ONNX inference paths: dropping CUDA-torch in favor of `onnxruntime-gpu`/DirectML
  massively cuts size. Evaluate before accepting the multi-GB torch payload.

## Inno Setup guidance

- Install to `{autopf}\<AppName>`; weights into `{app}\pretrain`.
- Add a `[Run]` step for VB-Cable (see below) and a firewall note: the server listens on
  localhost:18888 — keep `--host 127.0.0.1` so no firewall prompt is triggered.

## VB-Cable rules (licensing — do not violate)

- VB-Cable is donationware; **redistribution requires written permission from VB-Audio**,
  even for non-commercial projects.
- Preferred (pending permission): bundle `VBCABLE_Setup_x64.exe` in the installer and run it
  with a user-visible step.
- Fallback (no permission yet): the installer downloads VB-Cable **from the official
  vb-audio.com URL only** (never a mirror) and launches its own installer.
- Driver install requires admin rights and a reboot prompt — surface both in the installer UX.
- Detection: VB-Cable present if a render device named `CABLE Input (VB-Audio Virtual Cable)`
  exists.

## Frozen-stack constraint

The dependency set is legacy (Python 3.10, `pip<24.1`, `fairseq==0.12.2`). Build the freeze
environment with exactly the pinned versions from `server/requirements.txt` plus the extra
packages documented in `Linux_instal_history.md`. Do not upgrade packages to "fix" PyInstaller
issues without testing the full RVC pipeline afterwards.
