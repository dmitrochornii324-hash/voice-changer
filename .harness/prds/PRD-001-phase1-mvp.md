# PRD: Phase 1 MVP — realtime RVC voice change for Windows

- **Status**: active
- **Phase**: 1
- **Date**: 2026-10-11

## Problem

Existing voice-changer tooling is too complex for a casual Windows user: manual dependency
setup, cluttered UI with many model families, browser-based audio path. We ship a
one-installer app: pick a model, press on, every app hears the converted voice.

## Scope

- RVC-only server (all other model families removed).
- Server device mode as the only audio path: mic → RVC → VB-Cable Input.
- Minimal UI (model slot, input device, pitch, on/off) in a desktop window.
- Full offline installer: PyInstaller + Inno Setup, pretrained weights bundled,
  VB-Cable installed as part of setup (bundle pending permission; official download fallback).

## Out of scope

- TTS (phase 2), model training (phase 3), localization, client/browser audio mode,
  non-Windows targets, non-RVC models.

## Acceptance

On a clean Windows machine: run installer → launch app → select bundled sample RVC model →
press start → Discord with microphone = "CABLE Output" transmits the converted voice.

## Tickets

| ID | Title | Status |
| --- | --- | --- |
| T-001 | Strip non-RVC model families and their dependencies | done |
| T-002 | Default to server device mode; remove client-mode audio path from UI | open |
| T-003 | Minimal UI + desktop window wrapper | open |
| T-004 | PyInstaller freeze spike on Windows (riskiest — do early) | open |
| T-005 | Inno Setup installer with weights + VB-Cable step | open |
