---
name: run-voice-server
description: Start, stop, and troubleshoot the voice-changer dev server and virtual audio routing on the Linux dev machine. Use when running MMVCServerSIO.py, testing the RVC pipeline, setting up VC_Mic/VC_Out virtual audio devices, or debugging server startup/dependency errors.
---

# Run the voice-changer dev server

## Start (daily workflow)

```bash
source "$HOME/miniconda3/etc/profile.d/conda.sh"
conda activate vcclient-dev

# kill stale instances first
pkill -f MMVCServerSIO.py || true
fuser -k 18888/tcp || true

cd /home/dmitro-chornii/Projects/changer/voice-changer/server
python MMVCServerSIO.py -p 18888 --https false
```

UI: http://localhost:18888/ . First boot downloads pretrained weights (hubert, rmvpe, crepe).
To capture a startup log: append `2>&1 | tee ~/vc-crash.log`.

When started by an agent, run it in the background and verify boot by polling
`curl -s http://localhost:18888/api/hello` (REST hello endpoint) instead of waiting on stdout.

## Stop / cleanup

```bash
pkill -f MMVCServerSIO.py || true
fuser -k 18888/tcp || true
# remove virtual audio devices:
pactl list short modules | awk '/sink_name=VC_Out|source_name=VC_Mic/{print $1}' | xargs -r -n1 pactl unload-module
```

## Virtual audio routing (Linux, PipeWire/PulseAudio)

Mic → server (RVC) → `VC_Out` sink → `VC_Mic` remap source → messenger picks `VC_Mic` as its mic.

```bash
pactl load-module module-null-sink sink_name=VC_Out sink_properties=device.description=VC_Out
pactl load-module module-remap-source master=VC_Out.monitor source_name=VC_Mic source_properties=device.description=VC_Mic
pactl set-default-source VC_Mic
```

Modules disappear after reboot — re-run the commands. In the UI set AUDIO=server,
input = real mic (not VC_Mic), output = VC_Out, F0 = `rmvpe_onnx`.

## Known failure modes

| Symptom | Fix |
| --- | --- |
| `Address already in use` | `pkill -f MMVCServerSIO.py; fuser -k 18888/tcp` |
| `No module named 'torch'` | deps went outside conda env; `conda activate vcclient-dev` |
| onnxruntime "executable stack" error | `find "$CONDA_PREFIX/lib/python3.10/site-packages/onnxruntime" -name '*.so' -exec patchelf --clear-execstack {} \;` (repeat after any onnxruntime reinstall) |
| `No module named 'pkg_resources'` | `pip install "setuptools<81"` |
| fairseq/omegaconf conflict | `pip install "pip<24.1"` then `pip install fairseq==0.12.2` |
| `No module named 'pyworld'` | `pip install pyworld==0.3.4` (or add `--no-build-isolation`) |
| `vol: 0` in UI | input device is `none`, start not pressed, or system mute |
| `Can't initialize NVML` | NVIDIA driver issue; CPU mode still works |

Full environment bootstrap from scratch: see `Linux_instal_history.md` in the repo root.
