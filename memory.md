# Running Prep App - memory

Durable facts and decisions. Add new lines at the bottom of each section with the date.

## About me (relevant to this app)
- iPhone user, has an iOS development background (14 Nov 2026).
- Watch: COROS Pace 3. Earbuds: AirPods. Both need charging the day before.
- Training sessions live in the Google Calendar "Stefan's' Training" (synced to iPhone Calendar). Titles start with the session type, e.g. "Long Run 18 km"; races are in that calendar too (14 Nov 2026).
- Both normal runs and long runs can be at UI campus (ride the motorbike there, so kunci motor + STNK) (14 Nov 2026).
- Long runs Saturday, start 05:00 from mid-Nov 2026. Race: Pertamina Eco RunFest HM, Sun 6 Dec 2026, Jakarta.
- Source of running context: `../Running Coach/` (CLAUDE.md, memory/running-memory.md). Read only; do not edit that folder from this project.

## Decisions
- 14 Nov 2026: reminders as iPhone notifications (not Telegram, not email).
- 14 Nov 2026: reminder times H-24 (charge + pack) and H-12 (bring list). Exact scope still open (see PLAN.md section 5).
- 14 Nov 2026: banana for long runs and races.
- 14 Nov 2026: options B (Telegram), C (PWA), D (Claude task as core) dropped. Choice is between A (Reminders + Shortcuts) and E (native SwiftUI app); E recommended.
- 14 Nov 2026: **E chosen** (native SwiftUI app). A survives only as the nightly Shortcuts automation that runs the app's refresh intent.
- 14 Nov 2026: place is asked each time (UI or home) via buttons on the H-24 / H-12 notifications or in the app. Races never ask and never include kunci motor / STNK (I don't ride to races).
- 14 Nov 2026: three reminders per session: H-24, H-12, and a "leave" reminder 30 min before start. Tapping it opens a checklist I tick off myself.
- 14 Nov 2026: I have a Mac with Xcode and a free Apple ID (app must be re-installed every 7 days). Code is written on Windows, pushed to my GitHub, pulled and built on the Mac. Personal use only for now; TestFlight later would need the paid program (USD 99/year).
- 14 Nov 2026: no Swift toolchain on the Windows machine, so builds and tests run on the Mac at each checkpoint.
- 14 Nov 2026: no code before the guides: PRD (`docs/PRD.md`), TDD (`docs/TDD.md`), design (`Design/Running Prep App.pen` + `docs/DESIGN.md`). Build later with `/agent-skills:build` from `tasks/todo.md`.
- 14 Nov 2026: design in pen.dev through the pencil MCP. Design system "Start Line, in Liquid Glass": Running Coach palette A (cobalt tint, volt only for "all set"), SF Pro + SF Symbols in the app (Inter + Lucide stand in on the canvas).
- 14 Nov 2026: iOS 26+ target with Liquid Glass and Apple HIG; maximise the Apple ecosystem. P1 Siri/Spotlight/Shortcuts intents + Time Sensitive leave reminder (AirPods announce). P2 Live Activity, widgets, Control Center control (need the widget extension; test free-team signing first in S0). P3 AlarmKit, Foundation Models. No Apple Watch app.
- 14 Nov 2026 (review settled, change if needed): H-12 = pack tonight; normal-run H-12 only while the place is unset; cap 60 pending; untick after All set brings the leave reminder back; skipped events hidden; unset place shows kunci motor/STNK as "(if at UI)"; calendar missing or denied keeps existing reminders.

- 14 Nov 2026: guides approved (Checkpoint 0). S0 spike in `spike/` (throwaway). This folder is now its own git repo (branch main, no commits yet, no remote).

- 14 Nov 2026, S0 result 1: free Personal Team ("Stefan Hutapea") cannot sign the Time Sensitive Notifications capability (Xcode: "Personal development teams ... do not support the Time Sensitive Notifications capability"). Leave reminder ships as a normal (.active) notification; for AirPods, turn on Announce Notifications for the app. Time Sensitive returns with the paid program. App Group, widget extension and Live Activity results still pending.
- 14 Nov 2026, S0 done: on the free Personal Team, widget extension, App Group (app and widget), Live Activity (Lock Screen + Dynamic Island on iPhone 17) and normal notifications all work. Only Time Sensitive fails. Decision: P2 features stay in the plan without the paid program; no Time Sensitive entitlement in the real app. Check on 21 Nov 2026 that the 7-day expiry behaves as expected. Results in `spike/RESULTS.md`.

## Item list (source of truth until the app holds it)
See the table in PLAN.md section 1.
