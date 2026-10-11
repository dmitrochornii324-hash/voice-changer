---
name: dh-plan
description: Turn a feature request into a PRD and tickets in the .harness workflow. Use when the user invokes /dh-plan or asks to plan a feature, phase, or chunk of work for this project.
disable-model-invocation: true
---

# dh-plan — discover and plan

1. Read `PROJECT_PLAN.md`, `.harness/MEMORY.md`, `.harness/RISKS.md`, and existing
   `.harness/prds/`. Confirm the request fits the current phase (`.harness/project.yaml`);
   if it belongs to a later phase, say so and stop unless the user overrides.
2. Explore the relevant code (spawn an `explore` subagent for broad questions) until scope
   is concrete.
3. Write a PRD to `.harness/prds/PRD-NNN-<slug>.md` using `.harness/templates/PRD.md`.
   Number sequentially. Scope items must be testable; put later-phase temptations in
   "Out of scope".
4. Break the PRD into tickets in `.harness/tickets/T-NNN-<slug>.md` using
   `.harness/templates/TICKET.md`. Tickets are small (a day or less of work), ordered so the
   riskiest unknowns land first, each with observable "Done when".
5. New risks discovered while planning → add rows to `.harness/RISKS.md`.
6. Present the PRD and ticket list to the user for approval before any implementation.
