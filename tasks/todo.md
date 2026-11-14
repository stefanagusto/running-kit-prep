# Running Prep App - task list

Build with `/agent-skills:build` one task at a time, in order. Code tasks need the Mac for build and test (no Swift on the Windows machine).

## Phase 0: Guides

## Task D1: PRD
**Description:** Product requirements: problem, users, goals, scope, user stories, item rules, reminder behaviour, success measures, out of scope.
**Acceptance criteria:**
- [ ] Every item rule from the seed table is in the PRD
- [ ] Every reminder (H-24, H-12, leave) has trigger, content and actions
- [ ] Out-of-scope and open questions listed
**Verification:** Opus review against memory.md and PLAN.md; my approval
**Dependencies:** None
**Files:** `docs/PRD.md`
**Scope:** S | Model: Sonnet draft, Opus review

## Task D2: TDD (technical design document)
**Description:** Modules, data model, classifier and planner algorithms, sync triggers, notification categories, permissions, project setup, test plan.
**Acceptance criteria:**
- [ ] Each PRD requirement maps to a module
- [ ] Reminder planner algorithm with edge cases (past times, moved/deleted events, 64 cap)
- [ ] Test plan lists unit tests and the device test script
**Verification:** Opus review against PRD; my approval
**Dependencies:** D1 (drafted in parallel from the same facts, reconciled by Opus)
**Files:** `docs/TDD.md`
**Scope:** S | Model: Sonnet draft, Opus review

## Task D3: Design system
**Description:** Tokens (colour light + dark, type, spacing, radius) as variables and reusable components (buttons, list rows, checkbox row, session card, chips, section header, notification banner) in the .pen file; written summary in DESIGN.md.
**Acceptance criteria:**
- [ ] Variables defined for light and dark
- [ ] Components cover every element the screens need
- [ ] Text contrast at least 4.5:1
**Verification:** screenshots of the component sheet; contrast check
**Dependencies:** D1
**Files:** `Design/Running Prep App.pen`, `docs/DESIGN.md`
**Scope:** M | Model: Opus

## Task D4: Screens
**Description:** iPhone screens built from the components: Onboarding (permissions), Upcoming, Session detail / place choice, Checklist (in progress + all set), Items, Item edit, Settings, notification mockups (H-24 with actions, H-12, leave), empty and permission-denied states.
**Acceptance criteria:**
- [ ] Every PRD user story has a screen or state
- [ ] Only design-system components and tokens used
- [ ] No clipped or broken layouts
**Verification:** screenshot review per screen
**Dependencies:** D3
**Files:** `Design/Running Prep App.pen`
**Scope:** M | Model: Opus

Status 14 Nov 2026: D1-D4 done (PRD, TDD drafted by Sonnet and reviewed by Opus; design system and screens in pen.dev by Opus; Liquid Glass + Apple ecosystem added).

## Checkpoint 0
- [ ] I approve PRD, TDD and design

## Phase 1: Foundation

## Task S0: Free-team signing spike
**Description:** Prove what a free Apple ID personal team can sign before building P2 features.
**Acceptance criteria:**
- [ ] Empty iOS 26 app + widget extension builds and runs on my iPhone with the personal team
- [ ] Result recorded for: App Group, Time Sensitive notifications, Live Activity (NSSupportsLiveActivities)
- [ ] Decision written in memory.md: P2 now, or P2 after the paid program
**Verification:** Xcode run on the iPhone; screenshot of Signing & Capabilities
**Dependencies:** Checkpoint 0
**Files:** `spike/` (throwaway), `memory.md`
**Scope:** XS | Model: Sonnet writes project.yml, I run it on the Mac
**Status 14 Nov 2026: DONE.** Ran on iPhone 17 with the free Personal Team. Pass: widget extension, App Group (app + widget), Live Activity, Dynamic Island, notifications. Fail: Time Sensitive (not supported on personal teams). Decision: P2 goes ahead without the paid program; no Time Sensitive entitlement. Details in `spike/RESULTS.md`.

## Task S1: Project skeleton + core seed
**Status 14 Nov 2026: DONE.** Code written (Sonnet), reviewed by Opus, seed checked against PRD by Haiku (0 mismatches). On the Mac (owner report): `swift test` passed with no errors, app built with no errors and ran on the iPhone showing the long-run-at-UI kit (Charge 2, Pack 4, Bring 6).
**Acceptance criteria:**
- [ ] `xcodegen generate` produces a project that builds an empty app
- [ ] Seed items match the PRD table row by row
- [ ] Classifier + kit builder tests: normal home, normal UI, long run UI, long run home, race, strength skipped, place unset
**Verification:** `swift test` (Mac); Haiku check of seed vs table
**Dependencies:** Checkpoint 0
**Files:** `project.yml`, `RunPrepCore/Package.swift`, `RunPrepCore/Sources/...`, `RunPrepCore/Tests/...`, `README.md`
**Scope:** M | Model: Sonnet

## Task S2: See my upcoming runs
**Status 14 Nov 2026:** code written (Sonnet), reviewed by Opus (fixed a compile error in SessionBuilder and a Substring type mismatch in a test). 7 new SessionBuilder tests. First iPhone run (owner): tests pass, calendar access and sessions work. Fixes after that run: minutes shown as "06.0" (now two digits), calendar drop-down replaced by a sheet grouped by account with colour dot, tick and search, chips no longer wrap. Re-test passed (owner, 14 Nov): DONE.
**Acceptance criteria:**
- [ ] Calendar permission flow incl. denied state
- [ ] Calendar picker defaults to "Stefan's' Training" if present
- [ ] Upcoming lists the next 14 days of runs with type and place
**Verification:** build on Mac; check with real calendar
**Dependencies:** S1
**Scope:** M | Model: Sonnet

## Checkpoint 1 (Mac)
- [ ] Tests green, app builds, Upcoming shows real sessions

## Phase 2: Reminders

## Task S3: Get reminders
**Status 14 Nov 2026:** code written (Sonnet), reviewed by Opus. 17 new tests (15 planner, 2 session builder). Includes multiple calendars, calendar-name polish and a DEBUG-only light/dark switch (owner request; remove before release). Review fixes: H-24 asks "Where do you start? Choose in Run Prep." until S4 adds buttons; card timeline says "passed" (not "sent") for past times. Owner test 14 Nov 2026: tests pass, test script passed, light and dark checked, notification permission prompt appears on first launch. DONE.
**Acceptance criteria:**
- [ ] Planner tests: 05:00 long run times, late-added session, moved event, 3 weeks of sessions, cap 60
- [ ] H-24, H-12, leave reminders scheduled with the right text
- [ ] Rebuild on app open and calendar change; stale reminders removed
- [ ] Multiple calendars (owner request 14 Nov 2026): the Training calendar sheet allows ticking several calendars; Upcoming and reminders merge sessions from all ticked calendars (sorted by start, de-duplicated by session key); at least one must stay ticked; existing single choice migrates to a one-item list
- [ ] Polish from the S2 run: calendar names in the sheet use primary text colour (not tint blue)
**Dependencies:** S2 | **Scope:** M | Model: Sonnet

## Task S4: Choose the place
**Status 14 Nov 2026:** code written (Sonnet), reviewed by Opus. New tests: PlaceResolver 9, Countdown 6, SessionBuilder 5. Review fixes: store helper renamed `storePlace` (avoids a module-qualified call), type chips neutral so only the countdown is blue. Owner test 14 Nov 2026: tests pass, place from calendar and picker work. DONE. Follow-up S4b (Opus, same day): Liquid Glass drag picker (press to swell, slide, spring) and a kit line on the card so the place change is visible ("Bring 6, incl. kunci motor and STNK" vs "Bring 4"). Not compiled yet.
**Also in S4 (owner request 14 Nov 2026):** countdown on Upcoming per DESIGN.md (frame 14): pill on the card, countdown as the first line of each row above the title, three tiers, neutral place chips, calendar-day counting, section "Coming up". Pure helper `Countdown.label(from:to:calendar:)` in RunPrepCore with tests (today, tomorrow, 2, 3, 4, 13, 16 days; late-evening and just-after-midnight edges).
**Acceptance criteria:**
- [ ] UI / Home actions on H-24 and H-12 (not for races) save the place
- [ ] Place picker in Upcoming; change triggers rebuild
- [ ] H-12 skips the question once the place is set
- [ ] Place from the event location (owner request 14 Nov 2026): read `EKEvent.location`; a location matching a UI keyword ("Universitas Indonesia", "UI", "Depok"; "UI" as a whole word) gives UI campus, a home keyword ("Home", "Rumah") gives Home, otherwise unset. Order: my own choice for that session (buttons or picker) > event location > unset. Races ignore it. Keywords stored in AppSettings (editable in S7). Pure helper `PlaceResolver.place(location:rules:)` in RunPrepCore with tests (Universitas Indonesia, "Universitas Indonesia Jalan ...", "UI", "Building" must NOT match, Rumah, empty, race)
- [ ] A place that came from the calendar shows on the card as the place (no question in the reminders), and can still be changed with the picker
**Dependencies:** S3 | **Scope:** M (place from location + countdown added) | Model: Sonnet

## Task S5: Tick off my kit
**Status 14 Nov 2026:** code written (Sonnet), reviewed by Opus (moved a helper out so SyncCoordinator stays near 200 lines). 7 new checklist tests. Also in this round: slower place-picker glide (owner request: about 0.55 s spring, lens stays swollen while moving, labels fade across). Owner run 14 Nov 2026: Kit check opens from the card, ticks are saved, place change drops kunci motor and STNK (8 to 6). Fixes after the run: lanes fill from the left, scroll-edge fade under the floating bars (glass showed row text through). Re-run 14 Nov 2026: lanes fill from the left, fade under the bar works, ALL SET with volt lanes, success haptic and Done button confirmed. Still to confirm with test events: leave-reminder tap opens the checklist.
**Acceptance criteria:**
- [ ] Leave reminder tap opens that session's Checklist
- [ ] Place question first when unset; ticks saved per session
- [ ] All ticked shows "All set" and removes the leave reminder
**Dependencies:** S4 | **Scope:** M | Model: Sonnet

## Checkpoint 2 (Mac + iPhone)
- [ ] Fake events give the right reminders and lists

## Phase 3: Control

## Task S6: Edit my items
**Acceptance criteria:**
- [ ] Add, edit, delete, reorder items
- [ ] Per item: session types, UI-only flag, group
- [ ] Changes rebuild reminders
**Dependencies:** S5 | **Scope:** M | Model: Sonnet

## Task S7: Settings
**Acceptance criteria:**
- [ ] Calendar, race / long-run keywords, H-24 / H-12 / leave offsets editable
- [ ] Re-install date shown, expiry reminder 1 day before
- [ ] "Send test reminder" works
**Dependencies:** S5 | **Scope:** S | Model: Sonnet

## Task S8: Nightly refresh
**Acceptance criteria:**
- [ ] App Intent "Refresh Run Reminders" appears in Shortcuts and rebuilds reminders
- [ ] `docs/SHORTCUTS-SETUP.md` step-by-step for the 21:00 automation
**Dependencies:** S3 | **Scope:** M (place from location + countdown added) | Model: Sonnet

## Task S9: Ask Siri (P1)
**Acceptance criteria:**
- [ ] "What do I bring for my run in Run Prep" answers with the next session's kit (spoken + snippet)
- [ ] SetStartPlace and OpenChecklist intents work from Siri, Spotlight and Shortcuts
- [ ] Phrases listed in the Shortcuts app under Run Prep
**Dependencies:** S5 | **Scope:** S | Model: Sonnet

## Phase 4 (P2, only if S0 passes)

## Task S10: Live Activity "Kit check"
**Acceptance criteria:**
- [ ] Starts when the leave reminder is tapped or the checklist opens within 2 h of start
- [ ] Lock Screen and Dynamic Island (compact, expanded) match frames 11-12; tick buttons update the count
- [ ] Ends at "All set" or 15 min after start
**Dependencies:** S5, S0 | **Scope:** M | Model: Sonnet

## Task S11: Widgets + Control Center control
**Acceptance criteria:**
- [ ] Lock Screen circular + rectangular and Home Screen small widgets show the next session and kit count
- [ ] Widgets reload on every reminder rebuild
- [ ] Control "Kit check" opens the checklist
**Dependencies:** S10 | **Scope:** M | Model: Sonnet

## Checkpoint 3: complete
- [ ] Code review findings fixed
- [ ] Fake-event test script passes on iPhone
- [ ] One real week of use
