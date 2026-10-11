# RISKS — risk register

| ID | Risk | Impact | Status | Mitigation |
| --- | --- | --- | --- | --- |
| R-1 | Legacy deps (fairseq, old torch) fail to freeze with PyInstaller on Windows | Blocks phase 1 packaging | Open | Validate a minimal frozen build early (phase 1, step 4 spike); prefer ONNX paths |
| R-2 | VB-Audio denies/ignores bundling permission for VB-Cable | Installer must download at install time | Open | Email VB-Audio early; fallback flow already designed |
| R-3 | Beatrice binary API license (no commercial use, no redistribution) | Legal exposure if shipped | Closed | Beatrice fully removed in T-001 (code, assets, UI); nothing to ship |
| R-4 | Installer size 2–4 GB deters users | Adoption | Accepted | Evaluate ONNX-only build to cut size |
| R-5 | Dev on Linux, target Windows: audio/device code diverges untested | Late-stage breakage | Open | Test server device mode on a Windows machine before UI work |
