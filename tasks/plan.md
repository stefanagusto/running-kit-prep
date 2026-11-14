# Implementation Plan: Running Prep App

Last updated: 14 Nov 2026. Docs come first: PRD, then TDD (technical design document), then Design (design system + screens in pen.dev). No code until all three are approved.

## Overview
A personal iPhone app (SwiftUI) that reads the "Stefan's' Training" calendar and reminds me what to charge, pack and bring for each run. Three reminders per session (H-24, H-12, 30 min before start). It asks where each session starts (UI campus or home) because kunci motor and STNK depend on it. The last reminder opens a checklist I tick off as I collect the items. Items and rules are editable in the app.

## Architecture decisions (details in docs/TDD.md)
- Native SwiftUI, **iOS 26+ with Liquid Glass** (Apple HIG, SF Pro, SF Symbols), SwiftData, EventKit, UserNotifications, App Intents. No server, no third-party packages. Reason: personal use, local notifications are enough, iOS background is my strength, and I want the most out of the Apple ecosystem (decided 14 Nov 2026).
- Apple ecosystem by priority: P1 Siri / Spotlight / Shortcuts intents and Time Sensitive notifications (AirPods announce); P2 Live Activity + Dynamic Island, Lock/Home Screen widgets, Control Center control (widget extension); P3 AlarmKit loud leave alarm, Foundation Models title fallback. No Apple Watch app.
- Pure logic in a Swift package `RunPrepCore` (classifier, kit builder, reminder planner) so it is unit-testable without the simulator.
- Xcode project generated from `project.yml` (XcodeGen), because code is written on Windows and built on a Mac.
- Reminders are rebuilt (clear + reschedule, next 14 days) on app open, calendar change, place choice, nightly App Intent via Shortcuts, and background refresh if granted.
- Free Apple ID: no App Groups or push, re-install every 7 days, in-app reminder before expiry.
- Design in pen.dev (`Design/Running Prep App.pen`), using the pencil MCP. Design system first (tokens + components), then screens built from those components.

## Model routing (agent-orchestration)
- Opus (main session): this plan, design system and screens, review of every doc and diff, final decisions.
- Sonnet subagents: draft PRD and TDD from the facts in this plan; later, build each slice from the TDD and design.
- Haiku subagents: searches, mechanical checks (seed data vs table, link checks), summarising test output.

## Dependency graph
```
PRD (what and why)
 ├── TDD (how: modules, data model, reminder algorithm, test plan)
 └── Design system (tokens, components)
        └── Screens (Upcoming, Checklist, Items, Item edit, Settings, Onboarding, notifications)
TDD + Screens
 └── Build slices S1..S8 (each: core logic + service + screen for one user path)
```

## Task list

### Phase 0: Guides (current)
- [x] D1. PRD - `docs/PRD.md` (drafted, reviewed 14 Nov)
- [x] D2. TDD - `docs/TDD.md` (drafted, reviewed 14 Nov)
- [x] D3. Design system - Liquid Glass tokens and components in the .pen file + `docs/DESIGN.md`
- [x] D4. Screens - 10 app screens + Lock Screen / Dynamic Island / Control / Siri / widget surfaces

### Checkpoint 0: guides approved
- [ ] I review PRD, TDD and the design, and say OK or list changes
- [ ] Open questions in PRD resolved

### Phase 1: Foundation
- [x] S0 (done 14 Nov 2026: all pass except Time Sensitive; P2 confirmed without the paid program). Free-team signing spike: empty app + widget extension + App Group + Time Sensitive, signed with my personal team on the Mac. Result decides whether P2 is possible without the paid program.
- [ ] S1. Project skeleton + core seed: repo, `project.yml`, `RunPrepCore` with models, seed items, title classifier, kit builder + tests
- [ ] S2. See my upcoming runs: calendar permission, pick calendar, Upcoming screen lists classified sessions (14 days)

### Checkpoint 1 (Mac)
- [ ] `swift test` green in RunPrepCore; app builds; Upcoming shows real sessions

### Phase 2: Reminders
- [ ] S3. Get reminders: reminder planner + tests, notification permission, schedule H-24 / H-12 / leave, rebuild on app open and calendar change
- [ ] S4. Choose the place: UI / Home buttons on notifications and in Upcoming, saved per session, triggers rebuild
- [ ] S5. Tick off my kit: Checklist screen opened by the leave reminder, ticks saved, "All set" clears the leave reminder

### Checkpoint 2 (Mac + iPhone)
- [ ] Fake events (normal at home, normal at UI, long run 05:00, race) give the right reminders and lists

### Phase 3: Control
- [ ] S6. Edit my items: Items list + item edit (types, UI only, group, reorder, add, delete)
- [ ] S7. Settings: calendar, title keywords, offsets, re-install date + expiry reminder, test reminder
- [ ] S8. Nightly refresh: App Intent "Refresh Run Reminders" + Shortcuts setup guide
- [ ] S9. Ask Siri: WhatToBring, SetStartPlace, OpenChecklist intents + App Shortcuts phrases (Spotlight, Shortcuts)

### Phase 4 (P2, only if S0 passes)
- [ ] S10. Live Activity "Kit check" on Lock Screen + Dynamic Island with tick buttons
- [ ] S11. Lock / Home Screen widgets + Control Center control

### Checkpoint 3: complete
- [ ] Code review (code-reviewer agent + Opus), findings fixed
- [ ] Full fake-event test script passes on iPhone
- [ ] One real week of use, notes in memory.md

Full task details with acceptance criteria: `tasks/todo.md`.

## Risks and mitigations
| Risk | Impact | Mitigation |
|---|---|---|
| Code written on Windows has compile errors | Med | Small slices, Mac checkpoint after each phase, I paste errors back |
| Background refresh not run by iOS | Med | Rebuild on open + calendar change + nightly Shortcuts intent; reminders scheduled 14 days ahead |
| Calendar titles don't match keywords | Med | Keywords editable; Upcoming shows the type so mistakes are visible |
| Free Apple ID expiry after 7 days | Low | Settings shows the date; expiry reminder 1 day before |
| 64 pending notification limit | Low | About 24 used; planner caps at 60 |
| Google calendar sync delay on iPhone | Low | Nightly refresh; manual refresh button |

## Open questions
- Leave reminder offset: 30 min for both places, or longer for UI? (default 30, editable)
- Nightly refresh time: 21:00?
- Exact race event title in the calendar?
- Install the Swift toolchain on Windows to compile core logic here?
