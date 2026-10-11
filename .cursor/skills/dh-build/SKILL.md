---
name: dh-build
description: Execute the next open ticket from the .harness workflow end to end. Use when the user invokes /dh-build or asks to work on, continue, or pick up the next ticket.
disable-model-invocation: true
---

# dh-build — execute a ticket

1. Pick the ticket: the one the user named, else the first `open`/`in-progress` ticket in
   the active PRD's table (`.harness/prds/`). Set its status to `in-progress`.
2. Read `.harness/MEMORY.md` first — it holds environment facts and past decisions that
   prevent rework.
3. Implement the ticket's steps, checking them off in the ticket file as you go.
   Respect AGENTS.md conventions (RVC-only scope, frozen deps, Windows target).
4. Validate: run `.harness/scripts/gate.sh`; it must be GREEN. For server changes also
   verify boot per the `run-voice-server` skill. Fix and re-run until green — never leave
   the gate red.
5. Close out: set ticket status `done`, update the PRD ticket table, move durable learnings
   from the ticket's Notes into `.harness/MEMORY.md`, update `.harness/RISKS.md` if a risk
   changed state.
6. Commit with a conventional message (English, no AI attributions — the commit hook
   enforces this). One ticket may span several commits; keep each revertible.
