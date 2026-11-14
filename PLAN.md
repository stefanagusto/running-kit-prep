# Running Prep App - status

Last updated: 14 Nov 2026. Status: **guides approved 14 Nov 2026. S0 signing spike written in `spike/`; waiting for the Mac run and `spike/RESULTS.md`.**

This file is the progress hub. Details live in:

| Doc | What it holds |
|---|---|
| `docs/PRD.md` | What and why: user stories, item rules, reminder spec, edge cases, success measures |
| `docs/TDD.md` | How: modules, data model, algorithms, notifications, intents, Live Activity, tests |
| `docs/DESIGN.md` | Design system: Liquid Glass rules, tokens, type, components, screen list |
| `Design/Running Prep App.pen` | The design itself (pen.dev): design system board + 12 screens/surfaces |
| `tasks/plan.md` | Implementation plan: phases, slices, routing, risks |
| `tasks/todo.md` | Task list with acceptance criteria (used by `/agent-skills:build`) |
| `memory.md` | Facts and decisions with dates |

## Progress

| # | Step | Status |
|---|---|---|
| 1 | Needs, item rules, option research (A-E) | done 14 Nov |
| 2 | Option E chosen: native SwiftUI app | done 14 Nov |
| 3 | Plan redone docs-first (`tasks/plan.md`, `tasks/todo.md`) | done 14 Nov |
| 4 | D1 PRD | drafted 14 Nov (Sonnet), reviewed by Opus; Liquid Glass + ecosystem update in progress |
| 5 | D2 TDD | drafted 14 Nov (Sonnet), reviewed by Opus; Liquid Glass + ecosystem update in progress |
| 6 | D3 Design system (Liquid Glass, Start Line tokens) | done 14 Nov (Opus, pen.dev) |
| 7 | D4 Screens + ecosystem surfaces | done 14 Nov (Opus, pen.dev) |
| 8 | Checkpoint 0: my review of PRD, TDD, design | approved 14 Nov |
| 9 | Phase 1: S0 free-team signing spike | code written 14 Nov, **waiting for Mac run** |
| 9b | Phase 1: S1 skeleton + core, S2 Upcoming | not started |
| 10 | Phase 2: reminders, place, checklist, Siri intents | not started |
| 11 | Phase 3: items, settings, nightly refresh | not started |
| 12 | Phase 4 (P2): Live Activity, widgets, Control Center control | not started |

## Key decisions so far
- Native SwiftUI app, iOS 26+, Liquid Glass, Apple HIG, SF Pro, SF Symbols.
- Apple ecosystem: P1 notifications (Time Sensitive, AirPods announce) and App Intents (Siri, Spotlight, Shortcuts); P2 Live Activity, widgets, Control Center control; P3 AlarmKit, Foundation Models. No Apple Watch app (COROS watch).
- Three reminders per session: H-24, H-12, leave (30 min). Place asked each time. Checklist ticked by hand.
- Code written on Windows, built on my Mac with a free Apple ID. Widget extension / App Group signing must be tested first (S0).
