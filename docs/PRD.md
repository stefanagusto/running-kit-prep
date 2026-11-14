# Running Prep App - Product Requirements Document

Version 0.2, 14 Nov 2026 (iOS 26 + Liquid Glass + Apple ecosystem decision applied). Status: draft for review. Owner: Stefan (single user).

Sources: `PLAN.md` (sections 1-3), `memory.md`, `tasks/plan.md`. The item rules table in section 6 is copied from `PLAN.md` section 1.

## 1. Summary

Running Prep is a personal iPhone app. It reads my training calendar and, for each run, reminds me what to charge, pack and bring. It sends three reminders per session. It asks where I start (UI campus or home), because kunci motor and STNK only matter at UI. The last reminder opens a checklist that I tick myself.

- One user: me.
- Device: iPhone, with a COROS Pace 3 watch and AirPods.
- No server, no accounts, no sharing. Everything stays on the phone.
- Items, rules, keywords and reminder offsets can be edited in the app.
- Decision 14 Nov 2026: the app targets iOS 26+ with Liquid Glass (Apple HIG) and uses as much of the Apple ecosystem as fits: Siri and Shortcuts, Live Activity, widgets, Control Center, AirPods announcements. See section 16.

## 2. Problem

I forget things before runs. Examples:

- Kunci motor or STNK left at home when I ride to UI.
- Watch or AirPods not charged.
- Banana, gel or electrolyte not packed for a long run.
- Race kit items (bib, magnets, shoes, lenses) missed on race morning.

Runs often start at 05:00, so I pack half asleep. A reminder the day before and a checklist at the door remove the need to remember.

## 3. Goals and non-goals

### Goals
1. Remind me the day before what to charge and pack.
2. Remind me before I leave what to bring.
3. Show only the items that apply: by session type (normal run, long run, race) and by place (UI or home).
4. Ask for the place with one tap, from the notification or in the app.
5. Give me a checklist I tick myself, and say "All set" when it is done.
6. Keep reminders correct when the calendar changes.
7. Let me change items, rules, keywords and times without a new build.
8. Look and feel like a current Apple app: iOS 26, Liquid Glass, system font, SF Symbols.
9. Reach the kit without opening the app: ask Siri, see it on the Lock Screen or Dynamic Island, in a widget, or from Control Center (P1 to P2, section 16).

### Non-goals
- Not a training app. It does not plan, track or analyse runs.
- Not a calendar editor. It only reads the calendar.
- Not for other people in version 1.
- No cloud, no accounts, no analytics.

## 4. User and context

| Topic | Detail |
|---|---|
| User | Me. iPhone user with an iOS development background. |
| Devices | iPhone on current iOS (app needs iOS 26.0 or later), COROS Pace 3, AirPods. |
| Where I run | Depok. Often at the UI campus (I ride the motorbike there). Sometimes I start from home. |
| When I run | About 4 sessions a week. Long runs on Saturday, start 05:00 (from mid-Nov 2026). |
| Calendar | Google Calendar "Stefan's' Training", synced to the iPhone Calendar app. |
| Titles | Start with the session type, for example "Long Run 18 km". |
| Race | Pertamina Eco RunFest HM, Sun 6 Dec 2026, Jakarta. It is in the same calendar. |
| Install | Free Apple ID, installed from Xcode on my Mac. Must be re-installed every 7 days. |

## 5. User stories

### US-01 See my upcoming sessions
As a runner, I want to see my next sessions with their type, so that I can check the app understood my calendar.

- Given the calendar is readable, when I open the app, then I see sessions in the next 14 days, each with title, date, start time, type and place.
- Given a session title is skipped (Strength, Padel), then it does not appear as a run.
- Given there are no sessions, then I see an empty state.

### US-02 Classify sessions from titles
As a runner, I want the app to read the session type from the title, so that I do not enter anything twice.

- Given a title starts with "Long Run", then the type is long run.
- Given a title contains "Race" or "RunFest", then the type is race.
- Given a title contains "Run", "Fartlek", "Interval" or "Tempo" and is neither of the above, then the type is normal run.
- Given any other title, then the session is skipped.

### US-03 Charge and pack reminder (H-24)
As a runner, I want a reminder 24 hours before start, so that I charge the watch and AirPods and pack in time.

- Given a session starts at 05:00 on Saturday, when it is 05:00 on Friday, then I get a notification listing what to charge and pack.
- Given the session is not a race, then the notification has the buttons "Start at UI" and "Start at home".
- Given the session is a race, then there are no place buttons.

### US-04 Pack tonight reminder (H-12)
As a runner, I want a second reminder 12 hours before start, so that I pack before bed.

- Given a session, when it is 12 hours before start, then I get a "pack tonight" notification.
- Given the place is not set (and it is not a race), then the notification asks for the place again with the same two buttons.
- Given the place is already set, then there are no place buttons.

### US-05 Leave reminder
As a runner, I want a reminder before I leave, so that I check my kit at the door.

- Given a session, when it is 30 minutes before start (editable), then I get "Time to go: check your kit."
- When I tap it, then the checklist for that session opens.

### US-06 Choose the place
As a runner, I want to say where I start, so that kunci motor and STNK only show when I go to UI.

- Given a non-race session, when I tap "Start at UI" or "Start at home" on a notification or in the app, then the place is saved for that session.
- Given the place changes, then all reminders are rebuilt.
- Given the session is a race, then the place is never asked.

### US-07 Tick my checklist
As a runner, I want a checklist I tick myself, so that I know I have everything.

- Given I open a checklist, then I see the items grouped Charge, Pack, Bring.
- When I tick an item, then the tick is saved for that session. A half-done list stays half-done after I close the app.
- When every item is ticked, then I see "All set" and the leave reminder is cleared.

### US-08 Race-day kit
As a runner, I want a race kit list without motorbike items, so that race day is simple.

- Given a race session, then the list has no kunci motor and no STNK.
- Given a race session, then it includes the race items in section 6 (bib + magnets, uniform, socks and shoes, sunglasses + contact lenses, and so on).

### US-09 Edit items and rules
As a runner, I want to edit items, so that the app follows my habits.

- I can add, rename, delete and reorder items.
- For each item I can set: applies to normal run, long run, race; only if at UI; group (Charge, Pack, Bring).
- Given I change an item, then reminders are rebuilt and use the new list.

### US-10 Edit keywords and offsets
As a runner, I want to change title keywords and reminder times, so that the app fits my calendar.

- I can edit the keyword lists for long run, race and normal run.
- I can edit the H-24, H-12 and leave offsets.
- Given I change a value, then reminders are rebuilt.

### US-11 Reminders follow the calendar
As a runner, I want reminders to update when the calendar changes, so that I never get a stale reminder.

- Given a session is moved, then the old reminders are removed and new ones are set for the new time.
- Given a session is deleted, then its reminders are removed.
- Given a session is added, then its reminders are set.

### US-12 Nightly refresh
As a runner, I want a nightly refresh without opening the app, so that reminders stay current.

- Given the app has an App Intent "Refresh Run Reminders" and a Shortcuts automation at 21:00, then the reminders are rebuilt each night without a prompt.
- The app also rebuilds on open, on calendar change, and when a notification button is pressed. Background refresh is a bonus only.

### US-13 Re-install warning
As a runner on a free Apple ID, I want to know when the app will expire, so that I re-install in time.

- Settings shows "Re-install by <date>".
- The app sends a notification 1 day before that date.

### US-14 Test reminder
As the builder and user, I want to send a test reminder from Settings, so that I can check notifications work.

- When I tap "Send test reminder", then a notification arrives within a few seconds.

### US-15 Ask Siri what to bring (P1)
As a runner, I want to ask Siri what to bring, so that I get my kit without opening the app.

- Given I say "What do I bring for my run in Run Prep", then Siri answers with the next session's kit (items that apply for its type and place).
- Given there is no upcoming session, then Siri says so.
- Given I say "Start kit check in Run Prep", then the checklist opens.
- The same actions appear in Spotlight and the Shortcuts app.

### US-16 Live Activity on Lock Screen and Dynamic Island (P2)
As a runner, I want a live "Kit check" before I leave, so that I can tick items from the Lock Screen.

- Given I tap the leave reminder, or open the checklist within 2 hours of start, then a Live Activity starts.
- Given it is running, then the Lock Screen shows count, place and leave countdown. The Dynamic Island compact view shows an icon and "7/12"; the expanded view shows count, place, countdown and buttons.
- When I press a button, then the next items are ticked without opening the app.
- Given I reach "All set", or 15 minutes pass after start, then the Live Activity ends.

### US-17 Lock Screen and Home Screen widgets (P2)
As a runner, I want widgets, so that I see my next session at a glance.

- Lock Screen circular: kit count ring. Lock Screen rectangular: next session, leave time, next items.
- Home Screen small: next session time, title, place status.
- Given reminders are rebuilt, then widgets refresh.

### US-18 Control Center control (P2)
As a runner, I want a Control Center control, so that I open the checklist in one tap.

- Given I add the "Kit check" control, when I tap it, then the checklist for the next session opens.

### US-19 Leave reminder on AirPods (P1)
As a runner, I want Siri to announce the leave reminder on my AirPods, so that I hear it while I get ready.

- Given the leave reminder is Time Sensitive and Announce Notifications is on, then Siri can read it on AirPods.
- Given the free Apple ID cannot get the Time Sensitive capability, then the reminder is a normal notification and is not announced.

## 6. Item rules

Copied from `PLAN.md` section 1. This is the seed data. All of it is editable in the app.

| Item | Normal | Long run | Race | Only if at UI | Group |
|---|---|---|---|---|---|
| Soft flask | yes | yes | yes | | Bring |
| Running belt | yes | yes | yes | | Bring |
| Watch | yes | yes | yes | | Charge + Bring |
| AirPods | yes | yes | yes | | Charge + Bring |
| Motorbike key (kunci motor) | yes | yes | no | yes | Bring |
| STNK | yes | yes | no | yes | Bring |
| Energy gel | | yes | yes | | Pack |
| Electrolyte | | yes | | | Pack |
| Running cap | | yes | yes | | Pack |
| Banana | | yes | yes | | Pack |
| Sunglasses + contact lenses | | | yes | | Pack |
| Uniqlo seamless jersey, shorts, underwear | | | yes | | Pack |
| Socks and shoes | | | yes | | Pack |
| Bib + magnets | | | yes | | Pack |

Groups:
- **Charge**: do the day before.
- **Pack**: put in the bag the day before.
- **Bring**: grab on the way out.

Notes:
- Place only matters for kunci motor and STNK.
- Races never get kunci motor or STNK (I do not ride to races) and never ask for a place.
- Banana is for long runs and races.

## 7. Session classification rules

Source: the calendar "Stefan's' Training", next 14 days. Matching is case-insensitive. Keywords are editable in Settings.

Rules run in this order. The first match wins.

| Order | Rule | Result |
|---|---|---|
| 1 | Title contains "Race" or "RunFest" | Race |
| 2 | Title starts with "Long Run" | Long run |
| 3 | Title contains "Run", "Fartlek", "Interval" or "Tempo" | Normal run |
| 4 | Anything else (Strength, Padel) | Skipped |

- Short keywords such as "10K" are not used for races, because training titles use them too.
- Known limit: a training title containing "Race" (for example "Race pace 5 km") is read as a race. Avoid that word in training titles, or keep only the race name ("RunFest") as the race keyword.
- Skipped events (Strength, Padel) are hidden from Upcoming.
- Each session is keyed by calendar event id + start time. A moved or deleted event drops its old reminders.
- The Upcoming screen shows the detected type, so a wrong match is visible.

## 8. Reminder spec

Three reminders per session. Times are relative to the session start.

| Reminder | Trigger time | Title | Body example | Actions | Skipped when |
|---|---|---|---|---|---|
| H-24 | Start minus 24 h (editable) | "Tomorrow 05:00 Long Run 18 km" | "Charge watch + AirPods. Pack: gel, electrolyte, cap, banana." | "Start at UI", "Start at home" (not for races) | Trigger time is already past. Session type is skipped. |
| H-12 | Start minus 12 h (editable) | "Pack tonight" | "Long Run 18 km, 05:00. Pack: gel, electrolyte, cap, banana." | "Start at UI", "Start at home" only if the place is unset (not for races) | Trigger time is already past. Session type is skipped. Normal run with the place already set (nothing to pack). |
| Leave | Start minus 30 min (editable) | "Time to go" | "Check your kit." | Tap opens the checklist | Trigger time is already past. Checklist is already "All set". |

Rules:
- Body text is built from the session type and place. Items that do not apply are not listed.
- For H-12, the "pack tonight" list is the Pack group. Exact wording is a design decision (see section 14).
- A reminder whose time has passed is not scheduled. Example: a session added 10 hours before start gets only the leave reminder.
- Titles say "Today" or "Tomorrow" when that is true, otherwise the weekday ("Sat 05:00 Long Run 18 km").
- Volume: about 4 sessions a week x 3 reminders x 2 weeks = about 24 pending. iOS allows 64 per app. The planner caps session reminders at 60, soonest first, leaving room for the re-install reminder.
- Time Sensitive notifications: the leave reminder uses the Time Sensitive level so Siri can announce it on AirPods (US-19). Try on the Mac (spike at Checkpoint 1). If Xcode refuses the capability on a free team, use normal notifications.

### When reminders are rebuilt
The app clears and reschedules all reminders when:
1. The app opens or comes to the foreground.
2. The calendar changes while the app is running.
3. A notification button is pressed (place chosen).
4. The App Intent "Refresh Run Reminders" runs (nightly Shortcuts automation, 21:00, runs without asking).
5. Background refresh runs, if iOS grants it. Not relied on.

## 9. Checklist behaviour

- Opened by tapping the leave reminder, or from the Upcoming screen.
- If the session is not a race and the place is not set, the first question is "Where do you start?" with UI and Home.
- Then the list shows checkboxes grouped Charge, Pack, Bring.
- Items shown depend on the session type and the place (section 6).
- Items in two groups (Watch, AirPods) appear in both Charge and Bring. They are ticked separately.
- Ticks are saved per session. A half-done list stays half-done.
- When every box is ticked: "All set" is shown and the leave reminder for that session is cleared.
- If the place is still unset, kunci motor and STNK are shown marked "(if at UI)" so they are not forgotten.
- If I untick an item after "All set", the state returns to not done, and the leave reminder is scheduled again if its time is still in the future.
- The checklist works with no network.

## 10. Settings and editing

| Area | What I can do |
|---|---|
| Calendar | Pick the calendar (default "Stefan's' Training"). See permission status. Refresh now. |
| Keywords | Edit keyword lists for long run, race and normal run. |
| Offsets | Edit H-24, H-12 and leave offsets. Defaults: 24 h, 12 h, 30 min. |
| Items | Add, edit, delete and reorder items. Per item: name, types (normal, long run, race), only if at UI, group. |
| Install | Shows "Re-install by <date>". |
| Test | "Send test reminder". |
| Reset | Restore the seed items from section 6 (needs confirmation). |

Rules:
- Any change rebuilds reminders.
- Deleting an item needs confirmation.
- Apple HIG with Liquid Glass (iOS 26), system font, SF Symbols, no emoji. Glass is on navigation and controls only; checklist and item rows stay on solid backgrounds. Empty, loading and permission-denied states are covered on every screen.

## 11. Edge cases

| Case | Expected behaviour |
|---|---|
| Session added late (for example 10 hours before start) | Only reminders with a future time are scheduled. Here that is the leave reminder. The app shows the session in Upcoming. |
| Event moved | Old reminders are removed. New ones are set for the new time. The saved place and ticks stay only if the key still matches; otherwise the session is treated as new. |
| Event deleted | Its reminders are removed. Its saved state is dropped. |
| No place chosen by leave time | The leave reminder still fires. Tapping it opens the checklist, which asks "Where do you start?" first. |
| Notification permission denied | Upcoming shows a banner with a link to Settings. The checklist still works inside the app. |
| Calendar permission denied | Upcoming shows a denied state with a link to Settings. No new reminders are scheduled; reminders already scheduled stay on. |
| App expired after 7 days | The app will not open until I re-install from Xcode. Data stays. Settings shows the date and a reminder is sent 1 day before. Pending notifications may stop after expiry. |
| Calendar not found | Upcoming shows "Calendar not found" and a picker to choose another one. No reminders are changed until a calendar is chosen. |
| Two sessions on the same day | Each gets its own three reminders and its own place and ticks. Reminders show the start time so they can be told apart. |
| Google sync delay on iPhone | Nightly refresh and the manual refresh button catch up. |
| Title matches no keyword | Session is skipped and hidden from Upcoming. |
| Past reminder time | Not scheduled, no error. |

## 12. Success measures

| Measure | Target |
|---|---|
| Forgotten items | Zero forgotten kit items over 4 weeks of real use. |
| Delivery | Reminders delivered for 100% of sessions in a test week (H-24, H-12 and leave). |
| Classification | 100% of sessions in the calendar get the right type in a test week. |
| Calendar changes | In a fake-event test, every moved or deleted event leaves no stale reminder. |
| Effort | Choosing a place takes one tap. Ticking a full list takes under 1 minute. |
| Upkeep | I re-install before expiry every week, helped by the reminder. |

Test script (Phase 4): normal at home, normal at UI, long run at 05:00, race, event moved, event deleted. Every row must pass.

## 13. Out of scope (later)

| Item | Note |
|---|---|
| Apple Watch app | Not planned. I use a COROS Pace 3, not an Apple Watch. |
| Weather | Later. |
| TestFlight sharing | Later. Needs the paid Apple Developer Program (USD 99/year). |
| COROS integration | Later. |
| Other users, accounts, cloud sync (including iCloud sync) | Not planned. |
| Push notifications | Not planned. Needs a capability a free team may not get. |

## 14. Open questions

From `tasks/plan.md` and `PLAN.md` section 5.

1. Leave reminder offset: 30 min for both places, or longer for UI because of the ride (for example 45 min)? Default 30 min, editable.
2. Nightly refresh time: 21:00?
3. Exact race title in the calendar. Seed keywords "Race" and "RunFest"; add more in Settings if needed.
4. Install the Swift toolchain on Windows to compile core logic here before each Mac checkpoint?

Settled in the Opus review (14 Nov 2026), change them if you disagree:

5. H-12 is "Pack tonight" (the Pack group). The bring list belongs to the leave reminder's checklist.
6. Planner cap is 60 (iOS limit is 64; the rest is spare for the re-install reminder).
7. Unticking after "All set" brings the leave reminder back if its time is still ahead.
8. Skipped events (Strength, Padel) are hidden from Upcoming.
9. Normal-run H-12 is sent only while the place is unset (it would have nothing to pack).
10. Place unset at checklist time: kunci motor and STNK shown as "(if at UI)".

Added 14 Nov 2026 (still open):

11. Free-team spike result: can the personal team sign a widget extension, an App Group and Time Sensitive? Answer comes at Checkpoint 1. If not, ship P1 only (section 16).
12. AlarmKit wanted? An optional "loud leave alarm" for 05:00 long runs (P3). Needs user permission. Yes or no?

## 15. Release plan

Docs first. No code until PRD, TDD and design are approved.

| Phase | Content | Exit |
|---|---|---|
| 0 Guides | PRD, TDD, design system, screens (pen.dev) | Checkpoint 0: I approve all three and open questions are answered. |
| 1 Foundation | Project skeleton, `RunPrepCore` (models, seed items, classifier, kit builder, tests). Calendar permission and Upcoming screen. Free-team spike (S0): widget extension + App Group + Time Sensitive with the personal team. | Checkpoint 1 (Mac): `swift test` green, app builds, Upcoming shows real sessions, spike result recorded. |
| 2 Reminders | Reminder planner, notification permission, H-24 / H-12 / leave, place buttons, checklist with ticks and "All set". | Checkpoint 2 (Mac + iPhone): fake events give the right reminders and lists. |
| 3 Control | Items editor, Settings (calendar, keywords, offsets, re-install date, test reminder), App Intents (four intents, Siri phrases) and Shortcuts guide. | Checkpoint 3: code review done, full fake-event script passes on iPhone. |
| 4 Ecosystem (P2) | After Checkpoint 2 and only if the spike passes: Live Activity, widgets, Control Center control. If the spike fails, these wait for the paid program (USD 99/year). | Checkpoint 4: device tests for Live Activity, widgets and control pass. |
| Real use | One real week, then adjust items and timings. Notes go in `memory.md`. | Success measures in section 12 are tracked. |

Constraints:
- Code is written on Windows. Builds and tests happen on the Mac at each checkpoint.
- The Xcode project is generated from `project.yml` (XcodeGen).
- Stack: iOS 26.0+, latest Xcode on the Mac, SwiftUI (Liquid Glass), SwiftData, EventKit, UserNotifications, App Intents. P2 adds ActivityKit and WidgetKit; P3 may add AlarmKit and Foundation Models. No third-party packages, no server.

## 16. Apple ecosystem features

Decision 14 Nov 2026 (owner and lead). Reason: Liquid Glass is native from iOS 26 and my iPhone runs current iOS. P1 = MVP build. P2 = after Checkpoint 2. P3 = later.

| Priority | Feature | What it does | Stories |
|---|---|---|---|
| P1 | App Intents | `RefreshRunRemindersIntent`, `WhatToBringIntent`, `SetStartPlaceIntent` (UI or Home), `OpenChecklistIntent`. Siri phrases: "What do I bring for my run in Run Prep", "Start kit check in Run Prep". Also in Spotlight and Shortcuts. The nightly 21:00 automation uses `RefreshRunRemindersIntent`. | US-12, US-15 |
| P1 | Notifications | Existing three reminders. The leave reminder is Time Sensitive so Siri can announce it on AirPods. Fallback: normal notification if the free team cannot get the capability. | US-05, US-19 |
| P2 | Live Activity "Kit check" | Lock Screen and Dynamic Island. Starts when the leave reminder is tapped or the checklist opens within 2 h of start. Buttons tick the next items. Ends at "All set" or 15 min after start. | US-16 |
| P2 | Widgets | Lock Screen circular and rectangular, Home Screen small. | US-17 |
| P2 | Control Center control | "Kit check" opens the checklist (iOS 18+ control API). | US-18 |
| P3 | AlarmKit (iOS 26) | Optional loud leave alarm for 05:00 long runs. Breaks through Silent and Focus. Needs user permission. | none yet |
| P3 | Foundation Models | Optional on-device fallback to classify titles that match no keyword. Supported iPhones only. Off by default. | none yet |
| Not planned | Apple Watch app, push notifications, iCloud sync | I use a COROS Pace 3. Push and iCloud need capabilities and a server or account I do not want. | |

Limits and risks:
- A Live Activity cannot start at a scheduled time without push, and push is out of scope. That is why it starts on tap or when I open the checklist.
- A free Apple ID may not sign a widget extension, App Groups or Time Sensitive. Checkpoint 1 includes a spike (S0). If it fails, I ship P1 only and P2 waits for the paid program (USD 99/year).
- Widgets need to share data with the app (App Group, or a small JSON snapshot).
