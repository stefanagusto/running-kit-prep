# Running Prep App - Technical Design Document (TDD)

Draft 2, 14 Nov 2026 (iOS 26 + Liquid Glass + Apple ecosystem decision applied; sections 16 and 17 are new). Source facts: `PLAN.md`, `memory.md`, `tasks/plan.md`, `tasks/todo.md`, `CLAUDE.md`. Visual design lives in `docs/DESIGN.md`. Nothing here is compiled yet: no Swift toolchain on Windows, so every type below is a sketch until the Mac checkpoint.

Items marked **[Decision]** are choices made in this document that the sources do not state. They are listed again in section 15.

## 1. Overview and goals

A personal iPhone app. It reads the "Stefan's' Training" calendar (next 14 days), classifies each event as normal run, long run or race, and sends three local notifications per session: H-24, H-12 and "leave". The last one opens a checklist the user ticks off.

Goals:
- Right list for the right session: type and place (UI or home) decide the items.
- Reminders stay correct when events move, are deleted or are added late.
- All pure logic is testable with `swift test`, without a simulator.
- No server, no third-party packages. P1 uses no capability a free Apple ID cannot sign (Time Sensitive has a fallback). P2 features need a widget extension and an App Group, which depend on the spike in S0 (section 14).
- Deployment target iOS 26.0, built with the latest Xcode on the Mac. Reason: Liquid Glass is native from iOS 26 and the owner's iPhone runs current iOS.
- Design language: Apple HIG + Liquid Glass (section 16). Use the Apple ecosystem where it fits: App Intents and Siri (P1), Live Activity, widgets, Control Center (P2), AlarmKit and Foundation Models (P3, optional) (sections 11 and 17).

Non-goals: Apple Watch app (owner uses a COROS Pace 3), push notifications, iCloud sync, sync across devices, other users, TestFlight (see PRD for scope).

## 2. Architecture and modules

```
+-------------------------------------------------------------+
|  RunningPrep (app target, SwiftUI)                          |
|                                                             |
|  Views -> ViewModels (@MainActor, @Observable)              |
|                |                     |                      |
|                v                     v                      |
|        SyncCoordinator <------ NotificationDelegate         |
|        (@MainActor)            (UNUserNotificationCenter)   |
|          |       |       |                ^                 |
|          v       v       v                |                 |
|   CalendarService  Store(SwiftData)  NotificationService    |
|   (EventKit)       ItemRecord        (UserNotifications)    |
|                    SessionStateRecord                       |
|                    AppSettings        Intents (App Intents) |
|                                       -> Coordinator        |
|                                       LiveActivityManager   |
+------------|-----------------------------|------------------+
             | Shared/ (ActivityAttributes,| imports (value types only)
             |  intents, snapshot)         |
+------------v-----------------------------v------------------+
|  RunningPrepWidgets (widget extension, P2)                  |
|  Live Activity | Widgets | Control                          |
+-------------------------------------------------------------+
+------------------------------v------------------------------+
|  RunPrepCore (local Swift package, no SwiftUI / EventKit)   |
|  Models | TitleClassifier | KitBuilder | ReminderPlanner    |
+-------------------------------------------------------------+
```

The widget extension is a second target that shares code with the app through `Shared/`. It imports `RunPrepCore` for the kit logic. It is built only if the S0 spike passes.

| Module | Responsibility | Imports |
|---|---|---|
| `RunPrepCore.Models` | Value types: `SessionType`, `Place`, `ItemGroup`, `ItemRule`, `Session`, `Kit`, `PlannedReminder`, `PlannerConfig`, seed items | Foundation |
| `RunPrepCore.TitleClassifier` | Title -> `SessionType?` using editable keyword lists | Foundation |
| `RunPrepCore.KitBuilder` | Session type + place + items -> `Kit` (per reminder kind and checklist) | Foundation |
| `RunPrepCore.ReminderPlanner` | Sessions + state + config + `now` -> sorted, capped `[PlannedReminder]` | Foundation |
| `CalendarService` | Permission, list calendars, fetch events for a window, map `EKEvent` to `CalendarEvent`, observe `EKEventStoreChanged` | EventKit |
| `NotificationService` | Permission, register categories, replace all pending app requests, remove delivered, send test reminder | UserNotifications |
| `NotificationDelegate` | Handle action buttons and default tap, set deep link | UserNotifications |
| `Store` | SwiftData container, seeding, queries, mappers record <-> core types | SwiftData |
| `SyncCoordinator` | The only place that runs a rebuild: fetch, classify, plan, schedule | all services |
| `Intents` (module, P1) | `RefreshRunRemindersIntent`, `WhatToBringIntent`, `SetStartPlaceIntent`, `OpenChecklistIntent`, `AppShortcutsProvider` (section 11) | AppIntents |
| `Shared/` (P2) | Code compiled into both targets: `KitCheckAttributes` (`ActivityAttributes`), the `LiveActivityIntent` tick intent, `OpenChecklistIntent`, the snapshot type for widgets | Foundation, AppIntents, ActivityKit |
| `LiveActivityManager` (P2) | Start, update and end the "Kit check" Live Activity from the app (section 17) | ActivityKit |
| `RunningPrepWidgets` (widget extension, P2) | Live Activity UI (`ActivityConfiguration`, `DynamicIsland`), widgets, Control Center control | WidgetKit, ActivityKit, AppIntents, SwiftUI |
| `BackgroundRefresh` | Optional `BGAppRefreshTask` that calls the coordinator | BackgroundTasks |
| `Router` | Holds the deep-link target (`sessionKey`) for navigation | SwiftUI |
| ViewModels + Views | Screens in section 12 | SwiftUI |

Rule: `RunPrepCore` never sees `EKEvent`, `UNNotificationRequest` or SwiftData classes. Services map to and from its value types.

## 3. Project layout and project.yml

```
Running Prep App/
  project.yml
  README.md                      (Mac steps)
  .gitignore                     (*.xcodeproj, .build, xcuserdata, DerivedData)
  docs/  PRD.md TDD.md DESIGN.md SHORTCUTS-SETUP.md
  Shared/                        (P2: used by both app and widget targets)
    KitCheckAttributes.swift TickNextItemsIntent.swift OpenChecklistIntent.swift
    KitSnapshot.swift
  RunningPrepWidgets/            (P2: widget extension target)
    RunningPrepWidgetsBundle.swift KitCheckLiveActivity.swift
    LockScreenWidgets.swift HomeWidget.swift KitCheckControl.swift
  RunPrepCore/
    Package.swift
    Sources/RunPrepCore/
      Models/ SessionType.swift Place.swift ItemGroup.swift ItemRule.swift
              Session.swift Kit.swift PlannedReminder.swift PlannerConfig.swift
      SeedItems.swift
      TitleClassifier.swift
      KitBuilder.swift
      ReminderPlanner.swift
    Tests/RunPrepCoreTests/
      SeedItemsTests.swift TitleClassifierTests.swift KitBuilderTests.swift
      ReminderPlannerTests.swift
  RunningPrep/
    App/        RunningPrepApp.swift AppEnvironment.swift Router.swift
    Services/   CalendarService.swift NotificationService.swift
                NotificationDelegate.swift SyncCoordinator.swift BackgroundRefresh.swift
    Store/      ItemRecord.swift SessionStateRecord.swift AppSettings.swift
                Store.swift Mappers.swift
    Intents/    RefreshRunRemindersIntent.swift WhatToBringIntent.swift
                SetStartPlaceIntent.swift RunPrepShortcuts.swift
                (OpenChecklistIntent lives in Shared/ once P2 starts; until then here)
    LiveActivity/ LiveActivityManager.swift   (P2)
    Features/   Onboarding/ Upcoming/ SessionDetail/ Checklist/ Items/ ItemEdit/ Settings/
    Resources/  Assets.xcassets
  RunningPrepTests/              (optional app-level tests, e.g. mappers; not required)
```

`project.yml` outline (XcodeGen):

```yaml
name: RunningPrep
options:
  bundleIdPrefix: com.stefan          # placeholder, change to own prefix
  deploymentTarget: { iOS: "26.0" }   # was 17.0; Liquid Glass needs the iOS 26 SDK
packages:
  RunPrepCore: { path: RunPrepCore }
targets:
  RunningPrep:
    type: application
    platform: iOS
    sources: [RunningPrep, Shared]
    dependencies:
      - package: RunPrepCore
      - target: RunningPrepWidgets      # only if the S0 spike passes
        embed: true
    info:
      path: RunningPrep/Info.plist
      properties:
        NSCalendarsFullAccessUsageDescription: "Reads your training calendar to plan kit reminders."
        UIBackgroundModes: [fetch]
        BGTaskSchedulerPermittedIdentifiers: [com.stefan.runningprep.refresh]
        UILaunchScreen: {}
        NSSupportsLiveActivities: true   # P2
        # NSAlarmKitUsageDescription: "..."   # P3 only, if AlarmKit is wanted
    settings:
      base:
        SWIFT_VERSION: "5.9"             # check on the Mac; use the version the latest Xcode defaults to
        TARGETED_DEVICE_FAMILY: "1"      # iPhone only
        CODE_SIGN_STYLE: Automatic
        DEVELOPMENT_TEAM: ""             # set on the Mac (free personal team)
    entitlements:
      path: RunningPrep/RunningPrep.entitlements
      properties: {}                     # P1: none, no push. Only if the S0 spike passes, add:
        # com.apple.security.application-groups: [group.com.stefan.runningprep]
        # com.apple.developer.usernotifications.time-sensitive: true
  RunningPrepWidgets:                    # P2, only if the S0 spike passes
    type: app-extension                  # WidgetKit extension; check the exact XcodeGen type on the Mac
    platform: iOS
    sources: [RunningPrepWidgets, Shared]
    dependencies: [{ package: RunPrepCore }]
    entitlements:
      path: RunningPrepWidgets/RunningPrepWidgets.entitlements
      properties:
        com.apple.security.application-groups: [group.com.stefan.runningprep]
schemes:
  RunningPrep: { build: { targets: { RunningPrep: all } } }
```

The bundle id prefix and team are placeholders: set them on the Mac. The App Group id is `group.<bundle-prefix>.runningprep` (shown above with the placeholder prefix). The App Group, the widget target and the Time Sensitive entitlement are left out until the S0 spike at Checkpoint 1 confirms the free personal team accepts them (sections 8 and 14). If it does not, the project stays a single app target with no entitlements and ships P1 only. The Live Activity needs no App Group (its content state carries the kit); widgets and the Control Center control do.

## 4. Data model

### 4.1 RunPrepCore value types

```swift
public enum SessionType: String, Codable, CaseIterable, Sendable { case normal, long, race }
public enum Place: String, Codable, Sendable { case ui, home }          // nil = not chosen
public enum ItemGroup: String, Codable, CaseIterable, Sendable { case charge, pack, bring }

public struct ItemRule: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var groups: Set<ItemGroup>          // non-empty
    public var appliesTo: Set<SessionType>
    public var uiOnly: Bool                    // only when Place == .ui
    public var sortOrder: Int
}

public struct Session: Equatable, Sendable {
    public var key: String                     // "<calendarItemIdentifier>|<start ISO8601 UTC>"
    public var title: String
    public var type: SessionType
    public var start: Date
    public var place: Place?                   // always nil for races
}

public struct KitItem: Equatable, Sendable {
    public var id: UUID; public var name: String
    public var group: ItemGroup                // the group this row is shown under
    public var conditional: Bool               // uiOnly item while place is unset
}
public struct Kit: Equatable, Sendable {
    public var items: [KitItem]                // all groups, ordered by group then sortOrder
    public func items(in groups: Set<ItemGroup>) -> [KitItem]
}

public enum ReminderKind: String, Sendable { case h24, h12, leave }
public struct PlannedReminder: Equatable, Sendable {
    public var identifier: String              // "session:<key>:<kind>"
    public var sessionKey: String
    public var kind: ReminderKind
    public var fireDate: Date
    public var title: String
    public var body: String
    public var category: ReminderCategory      // none, h24, h24Race, h12Ask, h12, leave
}
public enum ReminderCategory: String, Sendable { case h24, h24Race, h12Ask, h12, leave }

public struct PlannerConfig: Equatable, Sendable {
    public var h24Minutes = 1440, h12Minutes = 720, leaveMinutes = 30
    public var windowDays = 14, cap = 60
}
public struct CalendarEvent: Equatable, Sendable {   // output of CalendarService
    public var id: String; public var title: String; public var start: Date
}
```

A `Session` whose type is `.race` is built with `place = nil` regardless of stored state.

### 4.2 SwiftData models

| Model | Field | Type | Notes |
|---|---|---|---|
| `ItemRecord` | `id` | `UUID` | `@Attribute(.unique)` |
| | `name` | `String` | |
| | `groupsRaw` | `[String]` | `ItemGroup` raw values; mapper to `Set` |
| | `normal`, `long`, `race` | `Bool` x3 | which session types apply |
| | `uiOnly` | `Bool` | |
| | `sortOrder` | `Int` | user reorder |
| `SessionStateRecord` | `sessionKey` | `String` | `@Attribute(.unique)` |
| | `placeRaw` | `String?` | `"ui"`, `"home"`, nil |
| | `checkedItemIds` | `[String]` | tick keys `"<itemId>:<group>"` (see section 12) |
| | `completedAt` | `Date?` | set when all boxes ticked |
| | `startDate` | `Date` | for cleanup of old records |
| `AppSettings` | `calendarId` | `String?` | EKCalendar identifier |
| | `longRunPrefixes` | `[String]` | default `["Long Run"]` |
| | `raceKeywords` | `[String]` | default `["Race","RunFest"]` |
| | `runKeywords` | `[String]` | default `["Run","Fartlek","Interval","Tempo"]` |
| | `h24Minutes`, `h12Minutes`, `leaveMinutes` | `Int` | defaults 1440, 720, 30 |
| | `installDate` | `Date?` | see section 7.6 |
| | `seedVersion` | `Int` | guards one-time seeding |

`AppSettings` is a singleton row (fetch first, create if missing). Cleanup: delete `SessionStateRecord` rows whose `startDate` is older than 30 days, during rebuild.

### 4.3 Seed data mapping

`SeedItems.all` must equal PLAN.md section 1 row by row. Group column: C = charge, P = pack, B = bring. N/L/R = normal, long, race.

| Item | N | L | R | uiOnly | Groups |
|---|---|---|---|---|---|
| Soft flask | y | y | y | no | B |
| Running belt | y | y | y | no | B |
| Watch | y | y | y | no | C, B |
| AirPods | y | y | y | no | C, B |
| Motorbike key (kunci motor) | y | y | no | yes | B |
| STNK | y | y | no | yes | B |
| Energy gel | no | y | y | no | P |
| Electrolyte | no | y | no | no | P |
| Running cap | no | y | y | no | P |
| Banana | no | y | y | no | P |
| Sunglasses + contact lenses | no | no | y | no | P |
| Uniqlo seamless jersey, shorts, underwear | no | no | y | no | P |
| Socks and shoes | no | no | y | no | P |
| Bib + magnets | no | no | y | no | P |

Seeding: on first launch (`seedVersion == 0`) insert these 14 rows with `sortOrder` 0...13 and set `seedVersion = 1`. After that the database is the source of truth. Changing the seed later needs a new `seedVersion` and an explicit migration; it must never overwrite user edits.

## 5. Title classifier

`func classify(title: String, rules: KeywordRules) -> SessionType?`, where `KeywordRules` holds `longRunPrefixes`, `raceKeywords`, `runKeywords`. `nil` means skip.

Algorithm (all comparisons on trimmed, case-insensitive, diacritic-insensitive text):
1. If any race keyword is contained in the title: `.race`.
2. Else if the title starts with any long-run prefix: `.long`.
3. Else if any run keyword is contained in the title: `.normal`.
4. Else `nil`.

Order matters: "Race" beats "Long Run" (a race titled "Long Run Race" is a race), and "Long Run" beats "Run".

Matching is by substring, not whole word. **[Decision]** A keyword inside a longer word still matches ("Runway" would match "Run"). The Upcoming screen shows the type so mistakes are visible, and keywords are editable. Empty keywords (blank strings) are ignored, otherwise they would match everything.

| Title | Result | Why |
|---|---|---|
| `Long Run 18 km` | long | prefix |
| `long run 18km` | long | case-insensitive |
| `Race - Pertamina Eco RunFest HM` | race | "Race" (also "RunFest") |
| `Pertamina Eco RunFest HM` | race | "RunFest" |
| `Easy Run 8 km` | normal | "Run" |
| `Tempo 6 km` | normal | "Tempo" |
| `Interval 6 x 800` | normal | "Interval" |
| `Fartlek` | normal | "Fartlek" |
| `Morning Long Run` | normal | "Long Run" is not a prefix, "Run" matches |
| `10K tempo` | normal | "Tempo"; "10K" is not a keyword |
| `10K` | nil | no keyword (short words avoided) |
| `Strength` | nil | skipped |
| `Padel` | nil | skipped |
| `  RACE day  ` | race | trim + case |
| `Race pace 5 km` | race | known limit: "Race" matches. Avoid "Race" in training titles, or remove "Race" from the race keywords and keep only the race name ("RunFest") |
| `` (empty) | nil | |

## 6. Kit builder

`func kit(for type: SessionType, place: Place?, items: [ItemRule]) -> Kit`

Rules:
1. Keep items where `appliesTo` contains `type`.
2. If `type == .race`, drop every `uiOnly` item (races never include them, even if a rule's `appliesTo` includes race).
3. If the item is `uiOnly`:
   - `place == .ui`: keep.
   - `place == .home`: drop.
   - `place == nil` (non-race): keep with `conditional = true`. **[Decision]** Better to over-remind than to forget the key. The text marks it "(if at UI)".
4. An item with several groups yields one `KitItem` per group.
5. Order: group order charge, pack, bring, then `sortOrder`.

Per-reminder views of the kit:

| Use | Groups |
|---|---|
| H-24 reminder | charge + pack |
| H-12 reminder | pack |
| Checklist | charge + pack + bring |
| Leave reminder body | no list; "Time to go: check your kit." |

Examples (names shortened):

| Type | Place | H-24 lists | H-12 lists | Checklist adds |
|---|---|---|---|---|
| Normal | home | Charge: watch, AirPods. Pack: none | Pack: none | Bring: flask, belt, watch, AirPods |
| Normal | UI | same as above | none | Bring also: kunci motor, STNK |
| Normal | unset | same as above | none | Bring also: kunci motor (if at UI), STNK (if at UI) |
| Long | home | Charge: watch, AirPods. Pack: gel, electrolyte, cap, banana | Pack: same 4 | Bring: flask, belt, watch, AirPods |
| Long | UI | as Long/home | as Long/home | Bring also: kunci motor, STNK |
| Race | nil | Charge: watch, AirPods. Pack: gel, cap, banana, sunglasses + lenses, kit, socks + shoes, bib + magnets | Pack: same 7 | Bring: flask, belt, watch, AirPods (no key, no STNK) |
| Strength | - | no session | | |

A normal run has no pack items. Its H-12 is sent only while the place is unset, as the place question ("Where do you start tomorrow 06:00?"). Once the place is set, the normal-run H-12 is skipped, so there is no empty "nothing to pack" ping. **[Decision, Opus review 14 Nov 2026]**

## 7. Reminder planner

`func plan(sessions: [Session], states: [String: SessionState], items: [ItemRule], config: PlannerConfig, now: Date, reinstallDate: Date?) -> [PlannedReminder]`

`SessionState` (core copy of the record) = `{ completed: Bool }`. Place is already inside `Session`.

### 7.1 Pseudocode

```
function plan(...):
  window_end = now + config.windowDays days
  out = []
  for s in sessions where now < s.start <= window_end:      // started sessions ignored
    if states[s.key].completed: continue                    // all set: no reminders
    kit = KitBuilder.kit(s.type, s.place, items)
    for kind in [h24, h12, leave]:
      offset = minutes(kind)                                 // 1440, 720, 30
      fire = s.start - offset minutes
      if fire <= now: continue                               // past: skip, no catch-up
      out.append(PlannedReminder(
        id = "session:" + s.key + ":" + kind,
        fire, text = render(kind, s, kit),
        category = category(kind, s)))
  sort out by (fireDate, identifier)                         // stable order
  out = first config.cap of out                              // soonest first
  if reinstallDate: add reinstall reminder (7.6)             // outside the cap
  return out

category(kind, s):
  h24:   s.type == race ? h24Race : h24
  h12:   s.type != race and s.place == nil ? h12Ask : h12
  leave: leave
```

Text templates (title, then body):
- H-24: `Tomorrow 05:00 Long Run 18 km`. Body: `Charge: watch, AirPods. Pack: gel, electrolyte, cap, banana.` Add `Starting at UI or home?` when place is unset and type is not race. Omit an empty "Pack:" clause.
- H-12: `Pack tonight: Long Run 18 km, 05:00`. Body: pack list, plus the place question when unset.
- Leave: `Time to go: Long Run 18 km`. Body: `Check your kit.` Tap opens the checklist.

"Tomorrow" is wrong if the offset is edited (for example H-24 set to 36 h). **[Decision, Opus review 14 Nov 2026]** The day word is computed from the fire date: "Today" or "Tomorrow" when the session falls on that day relative to the fire date, otherwise the weekday ("Sat 05:00 Long Run 18 km"). This matches the design mocks and stays correct with edited offsets. Rendering uses the device calendar and 24-hour time. Normal-run H-12 follows section 6 (sent only while the place is unset).

### 7.2 Edge cases

| Case | Behaviour |
|---|---|
| Fire date in the past | Skipped. A session added 10 h before start gets only the leave reminder. Exactly `fire == now` is skipped too. |
| Session already started | Ignored. |
| Event moved | New start gives a new session key (key includes start), so old state and reminders drop out. Place and ticks do not carry over. **[Decision]** (key rule is from PLAN.md; not carrying state is the consequence.) |
| Event deleted | Not in the fetched list, so its identifiers are not in the new plan and are removed by the rebuild. |
| Event retitled to non-run | Classifier returns nil, session dropped, reminders removed. |
| Two sessions same day | Separate keys, separate reminders. Notifications use `threadIdentifier = sessionKey` so they group per session. Two leave reminders may be close together: acceptable. |
| Recurring event | Same `calendarItemIdentifier`, different start, so keys differ per occurrence. |
| Cap | At most 60 session reminders; soonest first. Later ones appear on a later rebuild once earlier ones have fired. Normal load is about 24. |
| Session completed | No reminders at all for it. Delivered ones are removed (section 8). |
| Unset place on race | Never asked, `place` is nil, no actions. |
| Empty kit | H-24 body only the charge list (watch, AirPods are always present by seed). If the user deletes all items, the reminder says "Nothing on your list." |
| DST / time zone | Fire dates are absolute `Date`s; the trigger uses `Calendar.current` date components in the current zone. Jakarta has no DST. If the user travels, a rebuild on foreground recomputes. |
| Identifier stability | Same session + kind always gives the same identifier, so a rebuild is idempotent. |

### 7.3 Stable identifiers

`session:<key>:<kind>` where `key = "<calendarItemIdentifier>|<ISO8601 start, UTC, seconds>"`. Kind is `h24`, `h12` or `leave`. Use `calendarItemIdentifier` as the primary id; fall back to `eventIdentifier` if empty. **[Decision]** (PLAN.md allows either.) The `app:reinstall` identifier is reserved for 7.6.

### 7.4 Rebuild semantics

Rebuild is "remove all app-pending requests, then add the plan". Because identifiers are stable and the plan is a full set, running it twice gives the same state. `NotificationService.replaceAll(_:)` does: `removeAllPendingNotificationRequests()`, then `add` each request. Delivered notifications for sessions that are no longer planned or are completed are removed with `removeDeliveredNotifications(withIdentifiers:)`.

### 7.5 Placement of logic

The planner is pure: `now` and config come in as arguments, nothing reads the clock or the calendar. This is what makes the tests in section 13 possible.

### 7.6 Re-install expiry reminder

A free Apple ID build stops opening 7 days after install.
- `installDate`: **[Decision]** read from the creation date of the app bundle (`Bundle.main.bundleURL` attribute `.creationDate`) on each launch and stored in `AppSettings` when it changes. It is a heuristic and must be checked on the Mac. Fallback: the date of the first launch seen by the app.
- Expiry = `installDate + 7 days`. Settings shows "Re-install by <date>".
- Reminder: identifier `app:reinstall`, fire at `expiry - 1 day` (09:00 local if that time is in the future, otherwise skipped). Body: "Open Xcode and run the app again to renew it." Rebuilds add it after the cap, so total pending is at most 61.
- Re-installing from Xcode changes the bundle date, which moves the reminder.

## 8. Notification design

### 8.1 Categories and actions

| Category id | Used for | Actions |
|---|---|---|
| `RUN_H24` | H-24 for normal and long runs | `PLACE_UI` "Start at UI", `PLACE_HOME` "Start at home" |
| `RUN_H24_RACE` | H-24 for races | none |
| `RUN_H12_ASK` | H-12 when place is unset (non-race) | `PLACE_UI`, `PLACE_HOME` |
| `RUN_H12` | H-12 with place set, and races | none |
| `RUN_LEAVE` | Leave reminder | none (default tap opens checklist) |

**[Decision]** The sources name two categories (H24, H12). Splitting them is needed because a category's actions are fixed, while actions must be absent for races and for H-12 once the place is set.

Both place actions use options `[]` (no foreground, no authentication), so a press does not open the app.

A press on H-24 sets the place even if it was already set (lets the user change their mind).

### 8.2 Request content

| Field | Value |
|---|---|
| `title`, `body` | from planner |
| `categoryIdentifier` | category id above |
| `threadIdentifier` | `sessionKey` |
| `userInfo` | `["sessionKey": String, "kind": "h24"/"h12"/"leave"]` |
| `sound` | `.default` |
| `interruptionLevel` | `.active` for H-24, H-12. Leave: `.timeSensitive` (needed for Siri to announce it on AirPods), fallback `.active` if the free team cannot get the capability |
| trigger | `UNCalendarNotificationTrigger(dateMatching: yyyy-MM-dd HH:mm components, repeats: false)` |

Time Sensitive needs the `com.apple.developer.usernotifications.time-sensitive` entitlement. PLAN.md says to try it on the Mac and fall back if Xcode refuses. The code sets the level behind one constant (`useTimeSensitive`) so the fallback is one line.

AirPods: a Time Sensitive notification can be read aloud by Siri through Announce Notifications (the user turns it on in iOS Settings, not in the app). Only the leave reminder is Time Sensitive; H-24 and H-12 stay `.active` so they do not interrupt. The S0 spike checks the capability on the free team. With the fallback the leave reminder is a normal notification and Siri will not announce it. This is device-tested (section 13.4), not unit-tested.

**S0 result (14 Nov 2026):** the free Personal Team cannot sign Time Sensitive. `useTimeSensitive = false` and no Time Sensitive entitlement in project.yml. For AirPods, the owner turns on Announce Notifications for Run Prep in iOS Settings (per-app setting announces all of the app's notifications). Widget extension, App Group and Live Activity all passed, so the App Group and `RunningPrepWidgets` target are in (sections 3, 17).

### 8.3 Delegate

`NotificationDelegate: NSObject, UNUserNotificationCenterDelegate`, assigned in `RunningPrepApp.init` (before the first scene, so cold-launch taps are not lost).

```swift
func userNotificationCenter(_ c: UNUserNotificationCenter,
    didReceive r: UNNotificationResponse) async {
  let info = r.notification.request.content.userInfo
  guard let key = info["sessionKey"] as? String else { return }
  switch r.actionIdentifier {
  case "PLACE_UI":   await sync.setPlace(.ui,   for: key)   // write state, then rebuild
  case "PLACE_HOME": await sync.setPlace(.home, for: key)
  case UNNotificationDefaultActionIdentifier:
       await router.open(sessionKey: key)                   // deep link
  default: break
  }
}
func userNotificationCenter(_:willPresent:) async -> UNNotificationPresentationOptions
  { [.banner, .list, .sound] }                              // show while app is open
```

`setPlace` ignores sessions of type race. The delegate needs the shared `AppEnvironment` (container, coordinator, router), reachable from a launch with no UI.

### 8.4 Deep link to the checklist

The default tap on any of the three reminders sets `Router.pendingSessionKey`. `RootView` observes it, switches to the Upcoming tab and pushes `ChecklistView(sessionKey:)`. If the session no longer exists (moved or deleted since the notification), show a short "This session was changed" screen with a button to Upcoming. The leave reminder is the main use, as in PLAN.md; opening the checklist from H-24 or H-12 is a side benefit.

## 9. Sync coordinator

`@MainActor final class SyncCoordinator` owns the single rebuild pipeline.

### 9.1 Triggers

| # | Trigger | Where it comes from | Delay |
|---|---|---|---|
| 1 | App open / foreground | `scenePhase == .active` | none |
| 2 | Calendar changed | `NotificationCenter` `.EKEventStoreChanged` (while running) | debounce 1.5 s |
| 3 | Place chosen | `NotificationDelegate` action or Upcoming picker | none |
| 4 | App Intent | `RefreshRunRemindersIntent.perform()` | none, awaited |
| 5 | Background refresh | `BGAppRefreshTask` (bonus) | none |
| 6 | Item or settings edited | ViewModels after save | none |
| 7 | Checklist all ticked | Checklist view model | none |

**[Decision]** Triggers 6 and 7 are added to the five in PLAN.md: S6 requires "changes rebuild reminders" and "All set clears the leave reminder".

### 9.2 Pipeline

```
rebuild():
  1. settings = store.settings(); items = store.items()
  2. guard calendar auth == fullAccess else -> status .calendarDenied, stop
  3. events = calendar.events(from: now, to: now+14d, calendarId: settings.calendarId)
  4. sessions = events.compactMap { classify -> Session (place from SessionStateRecord) }
  5. states = store.sessionStates(for: sessions)
  6. plan = ReminderPlanner.plan(...)
  7. guard notification auth allows alerts else -> status .notificationsDenied (still publish sessions to UI)
  8. notifications.replaceAll(plan); remove stale delivered
  9. publish: upcoming sessions + status + lastSyncDate
```

Step 3 and 4 run even when notifications are denied, so Upcoming still works.

### 9.3 Concurrency

- Coordinator and view models are `@MainActor`. EventKit calls are cheap for a 14-day window and `EKEventStore` is not `Sendable`, so `CalendarService` is also `@MainActor` and returns `Sendable` `CalendarEvent` values.
- Core logic is pure and `Sendable`. It may run in a detached task but is fast enough to stay on the main actor.
- Single flight: a `running` flag and a `rerunRequested` flag. A trigger during a run sets `rerunRequested`; when the run ends it runs once more. This means no two `replaceAll` calls interleave (they would otherwise race between "remove all" and "add").
- Debounce for trigger 2: cancel and restart a `Task { try await Task.sleep(for: .seconds(1.5)); await rebuild() }`.
- `rebuildNow()` returns after the run (and any requested rerun) finishes. The App Intent awaits it so Shortcuts does not end the process early.
- Idempotent: the same inputs give the same pending set (7.4).
- SwiftData writes (place, ticks) use the main-actor `ModelContext` so the delegate, the intent and the views see the same data.

## 10. Permissions and failure states

| State | Detected by | App behaviour |
|---|---|---|
| Calendar not asked | `EKEventStore.authorizationStatus(for: .event) == .notDetermined` | Onboarding step "Allow calendar access" calls `requestFullAccessToEvents()` |
| Calendar denied or restricted | `.denied`, `.restricted`, or `.writeOnly` | Upcoming shows a blocked state with "Open Settings" (`UIApplication.openSettingsURLString`). No reminders scheduled. Existing pending requests stay until the next successful rebuild. **[Decision]** (stale reminders are better than none) |
| Notifications not asked | `UNAuthorizationStatus.notDetermined` | Onboarding step requests `[.alert, .sound, .badge]` |
| Notifications denied | `.denied` | Banner on Upcoming and Settings: "Reminders are off", "Open Settings". Sessions still listed. |
| Calendar missing | chosen `calendarId` not found in `calendars(for: .event)` | Banner "Calendar not found". Settings calendar picker opens. Rebuild is skipped and existing pending reminders stay until a calendar is chosen (a missing calendar is often a temporary Google sync gap). **[Decision, Opus review 14 Nov 2026; matches PRD section 11]** |
| "Stefan's' Training" absent at first run | no calendar with that title | Picker shown in onboarding, no default |
| Calendar empty / no runs in 14 days | zero sessions | Empty state "No runs in the next 14 days" |
| Loading | first fetch in flight | Skeleton or progress row on Upcoming |
| Expiry soon | `installDate + 7d - now < 1 day` | Settings row in warning state; reminder from 7.6 |
| 60-cap reached | planner returned exactly cap with more sessions dropped | Footnote in Settings "Some later reminders will be added as earlier ones fire" |

Calendar auth is re-read on each foreground. Granting access in system Settings and returning triggers a rebuild through trigger 1. The default calendar is chosen by title match (case-insensitive, ignoring apostrophe variants) against "Stefan's' Training".

## 11. App Intents, Siri and Shortcuts automation

P1. Four intents, one `AppShortcutsProvider`. All run inside the app process, so no App Group is needed.

| Intent | Does | Returns | Opens app |
|---|---|---|---|
| `RefreshRunRemindersIntent` | Rebuilds reminders (section 9) | Dialog with counts | No |
| `WhatToBringIntent` | Finds the next session, builds its kit with `KitBuilder` for its type and place | Spoken dialog and snippet answer listing the kit (for example "Tomorrow 05:00 Long Run: watch, AirPods, flask, belt, gel...") ; if none, "No runs in the next 14 days." | No |
| `SetStartPlaceIntent` | Parameter: place (UI or Home). Sets the place for the next non-race session, then rebuilds | Dialog "Start set to UI for Sat 05:00 Long Run." | No |
| `OpenChecklistIntent` | Opens the checklist for the next session (sets `Router.pendingSessionKey`) | none | Yes |

`RunPrepShortcuts: AppShortcutsProvider` exposes them with Siri phrases:

| Phrase | Intent |
|---|---|
| "What do I bring for my run in Run Prep" | `WhatToBringIntent` |
| "Start kit check in Run Prep" | `OpenChecklistIntent` |
| "Refresh reminders in Run Prep" (suggested; not in the decision, confirm) | `RefreshRunRemindersIntent` |
| "Set start place in Run Prep" (suggested; not in the decision, confirm) | `SetStartPlaceIntent` |

The two first phrases are final. Every App Shortcuts phrase must contain the app name (`\(.applicationName)` in code). These intents also appear in Spotlight and in the Shortcuts app with no extra work. "Next session" means the first non-skipped session that has not started yet.

The nightly 21:00 Shortcuts automation uses `RefreshRunRemindersIntent`.

```swift
struct RefreshRunRemindersIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Run Reminders"
    static var description = IntentDescription("Rebuilds the next 14 days of run reminders.")
    static var openAppWhenRun = false
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let result = await AppEnvironment.shared.sync.rebuildNow()
        return .result(dialog: "\(result.sessionCount) runs, \(result.reminderCount) reminders.")
    }
}
struct RunPrepShortcuts: AppShortcutsProvider { /* exposes the intents with the phrases above */ }
```

Sketch only; the other three follow the same pattern.

- The intents run inside the app process, so no App Group is needed (free team). If `OpenChecklistIntent` moves to `Shared/` for the Control Center control (section 17), it still runs in the app because it opens the app.
- `AppEnvironment.shared` builds the SwiftData container and services lazily so the intent works on a cold, background launch.
- It must work without UI: it reads calendar auth state and, if not granted, returns the dialog "Open Running Prep to allow calendar access." instead of throwing. **[Decision]**
- Shortcuts automation (guide in `docs/SHORTCUTS-SETUP.md`, S8): Shortcuts app > Automation > New > Time of Day > 21:00, Daily > Run Immediately (not "Run After Confirmation") > action "Refresh Run Reminders". iOS may still show a banner when it runs; this is expected.
- Risk: iOS can kill a background intent that runs long. The pipeline is a few hundred ms.

## 12. Screens and view models

Names only. Visual design is in `docs/DESIGN.md`.

| Screen | View | View model | Reads / writes |
|---|---|---|---|
| Onboarding (permissions, calendar pick) | `OnboardingView` | `OnboardingViewModel` | auth status, `AppSettings.calendarId` |
| Upcoming (next 14 days, place picker per row, status banners) | `UpcomingView` | `UpcomingViewModel` | coordinator's published sessions, `SessionStateRecord.place` |
| Session detail (type, start, place, kit preview, reminders list) | `SessionDetailView` | `SessionDetailViewModel` | sessions, kit via `KitBuilder`, place |
| Checklist (place question first, grouped ticks, "All set") | `ChecklistView` | `ChecklistViewModel` | `SessionStateRecord.checkedItemIds`, `completedAt` |
| Items (list, reorder, delete, add) | `ItemsView` | `ItemsViewModel` | `ItemRecord` |
| Item edit (name, groups, types, UI only) | `ItemEditView` | `ItemEditViewModel` | `ItemRecord` |
| Settings (calendar, keywords, offsets, re-install date, test reminder) | `SettingsView` | `SettingsViewModel` | `AppSettings`, `NotificationService` |

Visual rules for every screen are in section 16.

Navigation: root `TabView` (Upcoming, Items, Settings), with Onboarding as a full-screen cover until both permissions are decided. Checklist and Session detail are pushed from Upcoming or from the deep link.

Checklist rules: `completedAt` is set when every `KitItem` is ticked and cleared when an item is unticked. A kit item shown under two groups (watch in Charge and Bring) has one tick per group row, keyed by `"<itemId>:<group>"`. **[Decision]** (the sources do not say; tick per row matches "Charge the day before, grab on the way out".) `checkedItemIds` stores those keys.

If the place changes after ticks, ticks for items still in the kit are kept; the rest are ignored.

## 13. Test plan

### 13.1 Unit tests in RunPrepCore (`swift test`)

| Type | Cases |
|---|---|
| `SeedItems` | 14 rows; names match the PLAN table; N/L/R flags per row; uiOnly only for kunci motor and STNK; groups per row (watch and AirPods have charge + bring); unique ids; sort orders 0...13 |
| `TitleClassifier` | every row of the table in section 5; custom keyword lists; empty keyword ignored; race beats long run prefix; long run needs prefix; only trimmed whitespace |
| `KitBuilder` | normal home; normal UI; normal unset (conditional items); long home; long UI; long unset; race (any place) has no uiOnly; race with a custom item that is uiOnly + race; strength has no kit; item in two groups appears twice; ordering by group then sortOrder; H-24 = charge + pack; H-12 = pack; checklist = all three |
| `PlannerConfig` / `ReminderPlanner` | 05:00 long run: H-24 at 05:00 the day before, H-12 at 17:00 the day before, leave 04:30; session added 10 h before start: only leave; session added 20 h before: H-12 and leave; start in the past: nothing; event beyond 14 days: nothing; moved event: old id absent, new ids present; deleted event: no ids; two sessions same day: distinct ids and threads; 3 weeks of sessions (about 12 sessions, 14-day window): only sessions inside the window; 25 sessions: exactly 60 reminders, the 60 earliest, sorted; completed session: none; race: category `h24Race` and `h12`, no ask; normal unset: `h12Ask`; normal with place: `h12`; custom offsets (36 h, 45 min); identifier format `session:<key>:<kind>`; same inputs twice give equal output; reinstall reminder present and outside the cap; empty pack list text; text lists match the kit |

### 13.2 Manual device script (S3-S5, Checkpoint 2)

Create fake events in the Training calendar (names prefixed "TEST", dated so the reminder times are a few minutes away: shorten offsets in Settings to 3, 2, 1 min for the run). Reset offsets afterwards.

| # | Scenario | Setup | Expected |
|---|---|---|---|
| 1 | Normal run at home | "TEST Easy Run", tomorrow 06:00 | 3 reminders. H-24 buttons shown. Tap "Start at home". Upcoming shows Home. H-12 is not sent (place set, nothing to pack). Checklist has no key or STNK. |
| 2 | Normal run at UI | same title, different day | Tap "Start at UI". Checklist has kunci motor and STNK under Bring. |
| 3 | Long run 05:00 | "TEST Long Run 18 km", Saturday 05:00 | H-24 Fri 05:00, H-12 Fri 17:00, leave Sat 04:30. Pack: gel, electrolyte, cap, banana. |
| 4 | Race | "TEST Race HM" | No place question or buttons. No key or STNK. Pack list has 7 items. |
| 5 | Moved event | move test 3 by 1 day | After opening the app, old reminders gone (Settings > pending count), new times correct. Place resets. |
| 6 | Deleted event | delete test 1 | Its reminders disappear after next rebuild. |
| 7 | Added 10 h before | event starting in 10 h | Only the leave reminder. |
| 8 | Skipped types | "TEST Strength" | Not in Upcoming. |
| 9 | Checklist | tick everything | "All set". Leave reminder removed. Untick one: reminder is back after rebuild (if still in the future). |
| 10 | Denied calendar | revoke calendar in system Settings | Blocked state with Open Settings. |
| 11 | Denied notifications | revoke notifications | Banner. Sessions still listed. |
| 12 | Nightly intent | run the Shortcut by hand | Dialog with counts. Reminders rebuilt. |
| 13 | Cold-tap | kill the app, tap the leave notification | Checklist opens. |

Settings includes a debug row "Pending requests: N" for this script. **[Decision]** (small, helps the test; remove if the design drops it).

### 13.4 Device tests for the Apple ecosystem features

Run on the iPhone (iOS 26). Siri, Live Activity, widgets and Reduce Transparency cannot be tested in `swift test` or the simulator alone.

| # | Priority | Scenario | Setup | Expected |
|---|---|---|---|---|
| 14 | P1 | Siri phrase: what to bring | Say "What do I bring for my run in Run Prep" with a "TEST Long Run" tomorrow | Siri speaks the long-run kit. With no session, it says there are no runs. |
| 15 | P1 | Siri phrase: start kit check | Say "Start kit check in Run Prep" | Checklist for the next session opens. Phrases also show in Spotlight and Shortcuts. |
| 16 | P1 | Set place intent | Run `SetStartPlaceIntent` from Shortcuts with UI | Upcoming shows UI. Reminders rebuilt. Race sessions are not changed. |
| 17 | P1 | AirPods announce | Wear AirPods, turn on Announce Notifications, fire a leave reminder | Siri reads it. With the fallback (`.active`) it does not; record that. |
| 18 | P2 | Live Activity start | Tap the leave reminder; also open the checklist within 2 h of start | Activity shows on Lock Screen and Dynamic Island ("7/12" compact). Not started when more than 2 h before start. |
| 19 | P2 | Live Activity tick | Press the buttons on the Lock Screen and the expanded Dynamic Island | Next items ticked without opening the app. Count updates in the app and the activity. |
| 20 | P2 | Live Activity end | Reach "All set"; separately wait 15 min after start | Activity ends both ways. |
| 21 | P2 | Widget update | Add Lock Screen circular, rectangular and Home small. Change the place, move an event | Widgets show the new data after the rebuild (via `WidgetCenter.shared.reloadAllTimelines()`). |
| 22 | P2 | Control Center control | Add "Kit check"; tap it | Checklist opens. |
| 23 | P1 | Reduce Transparency and Increase Contrast | Turn each on in Accessibility settings | No unreadable text; place picker and floating buttons switch to an opaque style; checklist rows unchanged. |

Add tests 18 to 22 only if the S0 spike passed.

### 13.3 Mac checkpoint commands

```
brew install xcodegen                       # once
cd RunPrepCore && swift test                # Checkpoint 1: green
cd .. && xcodegen generate                  # makes RunningPrep.xcodeproj
xcodebuild -project RunningPrep.xcodeproj -scheme RunningPrep \
  -destination 'platform=iOS Simulator,name=<any simulator running iOS 26>' build
open RunningPrep.xcodeproj                  # set Team (free), run on device
```

Paste output (errors only) back. No statement that code compiles or tests pass is made until that output exists.

## 14. Build slice mapping

| Slice | Modules / files | Notes |
|---|---|---|
| S0 Spike: free-team signing (Checkpoint 1, Mac) **done 14 Nov 2026: all pass except Time Sensitive** | Throwaway widget extension target + App Group `group.<bundle-prefix>.runningprep` + Time Sensitive entitlement, signed with the personal team | Record the result in `memory.md`. Pass: S10 and S11 go ahead. Fail: ship P1 only; Live Activity, widgets and control wait for the paid program (USD 99/year). Time Sensitive failing alone only triggers the `.active` fallback. |
| S1 Skeleton + core seed | `project.yml`, `README.md`, `.gitignore`, `RunPrepCore/Package.swift`, `Models/*`, `SeedItems`, `TitleClassifier`, `KitBuilder`, their tests | App target is an empty `RunningPrepApp` |
| S2 Upcoming | `CalendarService`, `Store/*` (settings, seed on first launch), `OnboardingView`, `UpcomingView(+Model)`, `Mappers`, calendar picker | Reads sessions, no notifications |
| S3 Reminders | `ReminderPlanner` + tests, `NotificationService`, `NotificationDelegate` (registration only), `SyncCoordinator` (triggers 1, 2) | Categories registered here |
| S4 Place | actions in delegate, `SessionStateRecord.place`, place picker in Upcoming and `SessionDetailView`, trigger 3 | |
| S5 Checklist | `ChecklistView(+Model)`, `Router`, deep link in delegate, `ticks` and `completedAt`, trigger 7 | |
| S6 Items | `ItemsView`, `ItemEditView` (+ models), trigger 6 | |
| S7 Settings | `SettingsView(+Model)`, keyword/offset editors, `installDate` logic, `app:reinstall` reminder, test reminder | Planner already accepts reinstall date |
| S8 Nightly refresh | `RefreshRunRemindersIntent`, `AppShortcutsProvider`, `BackgroundRefresh` (bonus), `docs/SHORTCUTS-SETUP.md` | |
| S9 Siri + intents (P1) | `WhatToBringIntent`, `SetStartPlaceIntent`, `OpenChecklistIntent`, Siri phrases in `RunPrepShortcuts`, Time Sensitive on the leave reminder, TipKit hints | Device tests 14 to 17 and 23. Part of the MVP. |
| S10 Live Activity (P2, after Checkpoint 2, needs S0 pass) | `Shared/KitCheckAttributes`, tick `LiveActivityIntent`, `LiveActivityManager`, Live Activity UI in `RunningPrepWidgets` | Device tests 18 to 20. |
| S11 Widgets + control (P2, needs S0 pass) | App Group, `KitSnapshot`, Lock Screen and Home widgets, Control Center control, `reloadAllTimelines()` calls in `SyncCoordinator` | Device tests 21 and 22. |

Liquid Glass (section 16) is applied inside S2 to S7 as each screen is built, not as a separate slice. P3 (AlarmKit, Foundation Models) has no slice yet.

## 15. Risks and open questions

| Risk | Impact | Mitigation |
|---|---|---|
| Code is written without compiling | Med | Small slices, Mac checkpoint per phase, paste errors back |
| Free team refuses the Time Sensitive entitlement | Low | One-line fallback to `.active`. AirPods announce then does not work. |
| Free team refuses a widget extension or App Group | High for P2 | S0 spike at Checkpoint 1. If it fails, ship P1 only; P2 waits for the paid program (USD 99/year). |
| Live Activity cannot start at a scheduled time (no push) | Med | Start on leave-reminder tap or when the checklist opens within 2 h of start. Accept that it is not automatic. |
| `Menu` inside a `GlassEffectContainer` broke morphing in iOS 26.1 | Low | Do not combine them (section 16). Re-check on later iOS 26 releases. |
| Liquid Glass hurts legibility or battery on busy screens | Low | Glass on navigation and controls only; rows stay solid; test Reduce Transparency and Increase Contrast (test 23). |
| iOS 26-only target excludes older phones | Low | Single user, iPhone runs current iOS. |
| AlarmKit and Foundation Models APIs are new and not yet checked | Low | P3 only. Check the real API on the Mac before any design. Optional. |
| `installDate` from bundle creation date is wrong | Low | Check on the Mac; fallback to first launch |
| `EKEventStoreChanged` only fires while the app runs | Med | Rebuild on foreground, nightly intent, background refresh |
| Shortcuts automation not allowed to run silently or skipped by iOS | Med | Rebuild on every open; manual refresh button |
| Notification action runs while the app is suspended and the SwiftData write is lost | Med | Write state before rebuild inside the same delegate call; test cold-tap and background press (script 1, 2) |
| `calendarItemIdentifier` changes after a sync from Google | Med | If found on the Mac, switch to `eventIdentifier` or a hash of title + start. Effect today: old reminders dropped, place reset |
| Keyword substring match picks up a non-run title | Low | Editable keywords, type shown on Upcoming |
| Cap of 60 hides later reminders | Low | About 24 used normally |

Contradictions or gaps in the sources:
- `PLAN.md` T4 says "cap 64"; `tasks/plan.md` and the brief say the planner caps at 60. This document uses 60 (the limit is 64, so 60 leaves room for the reinstall reminder and a margin).
- `PLAN.md` uses task ids T1-T12; `tasks/todo.md` uses S1-S8. This document follows S1-S8.
- Source says "H-12 asks again if place is unset" but gives the normal run no pack items; H-12 for a normal run is therefore a place-question reminder only (section 6).
- `memory.md` says H-12 is a "bring list"; `PLAN.md` and the brief make it "pack tonight". This document follows PLAN.md and the brief (pack only).

Conflicts resolved on 14 Nov 2026: earlier text said "no widgets", "iOS 17+", "no App Groups" and "plain native look". These now read: widgets are P2 (needs the S0 spike), iOS 26.0, App Group only if the spike passes, Apple HIG with Liquid Glass. The project `CLAUDE.md` already says iOS 26+ and Liquid Glass, but still says to avoid App Groups on a free team; that is consistent with the S0 spike (App Group only if it passes).

Open questions (from the sources, still open): leave offset 30 vs 45 min for UI; nightly refresh time 21:00; exact race title; install Swift on Windows. New: S0 spike result (free team); AlarmKit wanted (P3); two extra Siri phrases in section 11 are suggestions to confirm. Added here: whether an unset place should include the UI-only items (assumed yes, conditional); whether a place pick should survive an event move (assumed no).

## 16. Liquid Glass UI implementation

Decision 14 Nov 2026. Design language: Apple HIG + Liquid Glass, iOS 26 SDK. Colour and layout tokens stay in `docs/DESIGN.md`; this section is the implementation rule set.

### 16.1 Rules

| Rule | Detail |
|---|---|
| Standard components get glass for free | `TabView` tab bar, `NavigationStack` toolbars, sheets and menus adopt glass with the iOS 26 SDK. Do not rebuild them. |
| Custom glass only in three places | The place picker (UI campus / Home), floating circular toolbar buttons, and the "Lock Screen" Live Activity pill on the checklist (section 17). |
| Glass API | `.glassEffect(_:in:)`, placed last in the modifier chain. `GlassEffectContainer(spacing:)` around each group of glass controls. `.buttonStyle(.glass)` and `.buttonStyle(.glassProminent)` for buttons. |
| App tint | Cobalt, set once with `.tint` at the root. |
| Glass sits on navigation and controls only | Content rows (checklist, items, sessions) stay on solid grouped backgrounds for legibility. |
| Accessibility | The system handles glass under Reduce Transparency and Increase Contrast. Custom glass views read `accessibilityReduceTransparency` and switch to an opaque fill. |
| Known issue | A `Menu` inside a `GlassEffectContainer` broke morphing in iOS 26.1. Avoid that combination: keep menus outside glass containers. |

### 16.2 Type, icons, feedback

| Topic | Rule |
|---|---|
| Font | SF Pro (system font) everywhere. Dynamic Type supported on every screen. |
| Timing digits | `.largeTitle`, or `.system(size:weight:.bold, design: .default)`, with `.monospacedDigit()` so counts and countdowns do not jitter. |
| Icons | SF Symbols with symbol effects, for example `.symbolEffect(.bounce)` on a tick. |
| Haptics | `.sensoryFeedback(.success, trigger:)` when the checklist reaches "All set". |
| Hints | TipKit for two hints: choose place, edit items. |

### 16.3 Mapping to screens

| Screen | Standard glass (automatic) | Custom glass | Solid content | Notes |
|---|---|---|---|---|
| Upcoming | Tab bar, large-title navigation bar | Place picker (UI / Home) in a `GlassEffectContainer(spacing:)` | Session rows on grouped background | Status banners (permission denied) are solid. TipKit hint: choose place. |
| Checklist | Navigation bar | Floating circular toolbar buttons (for example place change); Live Activity pill (P2) | Group sections and item rows (Charge, Pack, Bring) on solid backgrounds | Tick uses `.symbolEffect(.bounce)`. "All set" fires `.sensoryFeedback(.success, trigger:)`. Count uses monospaced digits. |
| Items | Navigation bar, edit and reorder controls | Floating circular "Add" button | Item rows | Delete confirmation is a system alert. TipKit hint: edit items. |
| Item edit | Sheet and its toolbar | None | Form on grouped background | Plain form. |
| Settings | Tab bar, navigation bar | None | Form sections | Pickers and steppers are standard. "Send test reminder" may use `.buttonStyle(.glass)`. |
| Onboarding | Full-screen cover | Primary actions `.buttonStyle(.glassProminent)`, secondary `.buttonStyle(.glass)` | Explanatory text on the plain background | Steps: calendar, notifications. Denied states link to Settings. |

Empty, loading and permission-denied states follow the same rules: banners and messages are solid, actions are glass buttons.

### 16.4 Checks

- Reduce Transparency and Increase Contrast: device test 23 (section 13.4).
- Reduce Motion: standard effects respect it; custom animations check `accessibilityReduceMotion`.
- None of this can be built or checked on Windows. Exact modifier signatures are checked on the Mac against the iOS 26 SDK.

## 17. Live Activity, widgets and control

P2, after Checkpoint 2. Needs the widget extension `RunningPrepWidgets` and the `Shared/` folder (section 3). Built only if the S0 spike passes. Every type below is a sketch until the Mac checkpoint.

### 17.1 Live Activity "Kit check"

```swift
struct KitCheckAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var items: [KitCheckItem]       // id, name, group, isTicked
        var ticked: Int
        var total: Int
        var leaveDate: Date             // for the countdown
        var isAllSet: Bool
    }
    var sessionKey: String
    var sessionTitle: String
    var startDate: Date
    var place: String?                  // "UI", "Home" or nil
}
```

The content state carries the kit itself, so the Live Activity needs no App Group. The UI is an `ActivityConfiguration` with a Lock Screen view and a `DynamicIsland`.

| Surface | Content |
|---|---|
| Lock Screen | Title, count "7/12", place, leave countdown, buttons |
| Dynamic Island compact | Icon and "7/12" |
| Dynamic Island expanded | Count, place, leave countdown, buttons |

Start and end rules:

| Event | Rule |
|---|---|
| Start | When the leave reminder is tapped, or when the checklist opens within 2 h of the session start. `LiveActivityManager` requests the activity with `Activity`. ActivityKit cannot start an activity at a scheduled time without push, and push is out of scope, so there is no automatic start. |
| Update | On every tick in the app and on every tick from the activity buttons. |
| End | At "All set", or 15 minutes after the session start, whichever comes first. Also ended if the session is moved or deleted (rebuild). |
| One at a time | If one is running for another session, end it first. |

Buttons use a `LiveActivityIntent` (in `Shared/`). The activity shows the next two unticked items as pills (design frame 11); one press ticks that one item. It updates `SessionStateRecord`, then the activity. **[Decision, Opus review 14 Nov 2026, matches the design]**

### 17.2 Widgets (WidgetKit)

| Family | Content | Data |
|---|---|---|
| Lock Screen circular | Kit count ring | Ticked and total for the next session |
| Lock Screen rectangular | Next session, leave time, next items | Next session and its next unticked items |
| Home Screen small | Next session time, title, place status | Next session |

Data sharing: the extension is a separate process. It reads either the SwiftData store or a small JSON snapshot, both through the App Group `group.<bundle-prefix>.runningprep`. **[Decision]** Prefer the JSON snapshot (`KitSnapshot`: next session key, title, start, place, ticked, total, next items), written by the app. It is simpler and keeps SwiftData models out of the extension.

### 17.3 Timeline policy

- Widgets use a `TimelineProvider`. Entries are placed at each reminder time (H-24, H-12, leave) and the session start, so a widget changes at the same moments as the notifications.
- On every app rebuild (`SyncCoordinator`, section 9) the app writes the snapshot, then calls `WidgetCenter.shared.reloadAllTimelines()`. Ticks do the same.
- The extension never calls EventKit. It trusts the snapshot.

### 17.4 Control Center control

A `ControlWidget` (iOS 18+ API, available on iOS 26) named "Kit check". It runs `OpenChecklistIntent`, which opens the app on the next session's checklist. Same extension and `Shared/` as above.

### 17.5 P3 notes (optional, not designed)

- AlarmKit (iOS 26): optional loud leave alarm for 05:00 long runs. Breaks through Silent and Focus. Needs `NSAlarmKitUsageDescription` and user permission. A countdown UI would need the widget extension. Not designed until the open question is answered.
- Foundation Models (on-device Apple Intelligence): optional fallback to classify titles that match no keyword (section 5). Supported iPhones only. Off by default. The classifier stays keyword-first and pure; any model call lives outside `RunPrepCore`.

### 17.6 Tests

`RunPrepCore` unit tests cover the pure parts (kit, counts). Live Activity, widgets and control are device tests 18 to 22 (section 13.4). The snapshot builder is a pure function and gets a unit test once it exists.
