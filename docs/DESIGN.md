# Running Prep App - design system

Last updated: 14 Nov 2026. Source file: `Design/Running Prep App.pen` (pen.dev). Frames: `Design System` (tokens + components), screens `01`-`10`, ecosystem surfaces `11`-`12`.

## 1. Direction

**"Start Line, in Liquid Glass."** The app is the pocket version of the Running Journey page (`../Running Coach/DESIGN.md`, palette A "Start Line"), rebuilt on Apple's iOS 26 design language.

- Apple first: Human Interface Guidelines, Liquid Glass, SF Pro, SF Symbols, standard SwiftUI containers. The app should feel like a first-party iOS utility.
- The brand shows in three places only: cobalt as the app tint, volt for "all set", and the **timing digits + lane lines** motif (big start time, segmented progress).
- One primary job per screen. Upcoming = choose the place for the next run. Checklist = tick the kit. Items = change the rules. Settings = change timing.

## 2. Liquid Glass rules

| Use glass for | Keep solid |
|---|---|
| Tab bar (system, automatic) | Session rows and the next-session card |
| Toolbars and nav buttons (system, automatic): back, refresh, add, cancel, save as 44 pt glass circles | Checklist rows |
| Place picker (UI campus / Home), custom `.glassEffect` in a `GlassEffectContainer` | Items and Settings grouped lists |
| Primary action: `.buttonStyle(.glassProminent)` tinted cobalt | Text blocks, empty states |
| Secondary action: `.buttonStyle(.glass)` | |
| "On Lock Screen" Live Activity pill on the checklist | |
| Notification banners, Live Activity, Dynamic Island (system) | |

- Glass floats on top of content; content never sits on glass. This keeps checklist text legible over any background.
- Capsule shapes for buttons and pickers, 26 pt corner radius for cards, 22 pt for grouped lists (iOS 26 proportions).
- Never stack glass on glass. Group nearby glass controls in one `GlassEffectContainer` so they morph together.
- Reduce Transparency and Increase Contrast: system components adapt by themselves; custom glass falls back to `raised` fill with a `rule` border.
- Avoid a `Menu` inside a `GlassEffectContainer` (morphing bug reported in iOS 26.1).
- Canvas recipe (pen file only): one translucent body (`glass`), one 1 px hairline edge (`glass-stroke`), background blur 20, one soft shadow (y 6, blur 20). No gradient edge and no inner highlight: stacking those drew a doubled outline (fixed 14 Nov 2026 after review). Tinted variant = solid `accent` with a faint white edge. Selected tab = `tab-sel` glass pill with tinted icon and label (iOS 26 tab bar). Code always uses the real material.
- Section labels are sentence case, 13 pt semibold, no tracking (iOS 26 grouped list headers). The only all-caps text is the volt "ALL SET" bib chip, kept as the brand's race-bib motif.
- Tap targets: every control is at least 44 pt (the checklist's place button is a 44 pt glass capsule, not a chip). Session-row chips are labels only; tapping the row opens its checklist.
- Secondary text on the cobalt next-run card is `#e3e8ff` (5.31:1 on the lightest corner `#2b4be6`).
- On the cobalt card the place picker is clear glass (white 14%, white edge) with white bold labels; the prompt "Where do you start?" is the card's one action. No warn chip on the card (the prompt already says it); the warn chip stays on list rows.
- One side margin everywhere: 16 pt (all screens, review 002).
- Place picker interaction (owner request 14 Nov 2026): tap a side, or press, hold and slide. On press the thumb swells (1.08 x 1.16) into an interactive Liquid Glass lens (`.glassEffect(.regular.interactive())`), follows the finger, the label under it turns cobalt with a selection haptic, a tap only swells the lens; on release it glides slowly (spring 0.55 s, bounce 0.18) to the chosen side, staying swollen until it lands, and the labels fade across over 0.35 s (owner: should feel like the Threads tab bar). Reduce Motion: no swell, short ease. VoiceOver: one adjustable element "Start place" with named actions.
- Kit line under the picker shows what the place changes: "Pack 4 · Bring 6, incl. kunci motor and STNK" at UI campus, "Pack 4 · Bring 4" at Home; "if at UI" while unset. Races show the line without a picker.
- Countdown (owner request 14 Nov 2026, frame 14): the next-run card shows a white pill ("Today", "Tomorrow", "In 2 days") before the weekday; each row's date line starts with the countdown ("In 3 days · Monday, 23 November"). The countdown is the first line of each row, above the title, 15 pt. Tiers: Today/Tomorrow = AccentSoft pill with accent text; 2 to 3 days = accent semibold; 4+ days = secondary regular. Place chips are neutral (outline) so only the countdown is blue. Card weekday in regular weight next to the white pill. Words carry the meaning, colour and weight add emphasis (design critic 14 Nov 2026). Counted in calendar days from now (startOfDay to startOfDay). The list section is titled "Coming up".
- Scroll edge: a page-colour fade (140 pt) sits under every floating bottom bar so rows never slice under the glass (iOS 26 scroll edge effect).
- Empty states follow `ContentUnavailableView`: large symbol without a tile, centred title and text, one action.
- Onboarding: the main button is anchored to the bottom (thumb reach); no step counter since there is one screen.
- Main screens (Upcoming, Checklist, Items, Settings) are drawn at real phone height (844 pt) with content scrolling under the floating glass tab bar, toolbar buttons and the checklist's floating kit bar, so the glass reads as glass.
- The next-session card on Upcoming is a cobalt gradient card; the glass place picker sits on it. This is the one coloured surface per screen.

## 3. Colour tokens

Defined as variables in the .pen file with light and dark values. In code: an asset catalog colour set per token, plus `.tint(Color.accent)` on the root view.

| Token | Light | Dark | Role |
|---|---|---|---|
| `page` | `#eef1f6` | `#05070d` | Screen background (system grouped background in code) |
| `raised` | `#fafbfc` | `#131927` | Rows, cards |
| `ink` | `#0d1220` | `#eef1f6` | Primary text, timing digits |
| `ink-2` | `#333a4c` | `#c5ccd9` | Secondary text |
| `muted` | `#566074` | `#98a2b5` | Labels, meta |
| `rule` | `#d3d9e2` | `#252d3f` | Hairlines, empty lanes |
| `rule-strong` | `#7b8597` | `#5f6a80` | Checkbox borders, chevrons |
| `accent` | `#1f3fd6` | `#567bf7` | App tint: selected, filled lanes, checked boxes |
| `accent-text` | `#1f3fd6` | `#88a7fd` | Tinted text and icons |
| `accent-soft` | `#e3e8fb` | `#1a2547` | Selected background, chips |
| `on-accent` | `#fafbfc` | `#0a0e18` | Text on accent |
| `signal` | `#d7f23a` | `#d7f23a` | Volt: "All set" only (bib chip + the completed progress lanes). Not on icons, countdowns or rings |
| `on-signal` | `#0d1220` | `#0a0e18` | Text on volt |
| `warn` | `#9a3b00` | `#ffb27a` | "Place not set", delete |
| `warn-soft` | `#fbeadf` | `#3a2213` | Warn chip background |
| `glass` | `#ffffffb8` | `#1b2233b8` | Canvas stand-in for Liquid Glass (code uses the real material) |
| `glass-stroke` | `#ffffffcc` | `#ffffff2e` | Glass edge highlight (canvas only) |
| `glass-tint` | `#1f3fd6e0` | `#567bf7e0` | Prominent glass button (canvas only; code uses `.glassProminent` + tint) |

Rules:
- Cobalt means "selected / action / done". Volt means "all set" and nothing else. Warn colour always comes with an icon and words.
- Measured contrast (WCAG, 14 Nov 2026): accent-text on accent-soft 6.28 (light) / 6.43 (dark); warn on warn-soft 5.98 / 8.39; muted on raised 6.10 / 6.83; on-accent on accent 7.40 (light); on-accent on accent dark 5.12. All pass AA for normal text. Volt is never used as text on a light surface.

## 4. Type

SF Pro (system) in the app with Dynamic Type. Inter stands in on the canvas because SF Pro is not available there.

| Style | Canvas | App | Use |
|---|---|---|---|
| Timing digits | Inter ExtraBold 56 | `.system(size: 56, weight: .bold)` + `.monospacedDigit()` | Next session start time |
| Large title | Inter Bold 34, -0.5 tracking | `.largeTitle` (navigation large title) | Screen titles |
| Headline | Inter Semibold 17 | `.headline` | Row titles |
| Body | Inter Regular 17 | `.body` | Checklist items, settings |
| Subhead | Inter Regular 15 | `.subheadline` | Meta lines |
| Caption | Inter Bold 12, +1.2 tracking, caps | `.caption.weight(.bold)` + tracking | Group labels ("PACK · 3 OF 4") |

## 5. Icons and motion

- SF Symbols in the app (Lucide stands in on the canvas). Mapping: backpack (app), bicycle (UI campus), house (home), figure.run (normal run), road.lanes (long run), medal (race), battery.100.bolt (charge), checklist (kit check), exclamationmark.circle (place not set).
- Symbol effects: `.bounce` on tick, `.contentTransition(.numericText())` on counts.
- Haptics: `.sensoryFeedback(.selection)` on tick, `.success` on "All set".
- Motion follows system defaults; nothing custom beyond glass morphing. Respect Reduce Motion.
- No emoji anywhere.

## 6. Components (in the .pen file)

| Component | Notes | SwiftUI |
|---|---|---|
| Button Primary | Glass prominent capsule, 52 pt, icon + label | `Button` + `.buttonStyle(.glassProminent)` |
| Button Secondary | Glass capsule | `.buttonStyle(.glass)` |
| Chip | Type / place / warn, 6 pt radius | small `Label` in a capsule background |
| Bib Chip | Volt, condensed caps "ALL SET" | custom view |
| Place Picker | Glass segmented, UI campus / Home | custom segmented with `.glassEffect` in `GlassEffectContainer` |
| Checklist Row | 52 pt, box + label + optional "UI only" tag | `Toggle` with a custom checkbox style inside `List` |
| Group Header + lanes | Label, count, one lane per item | section header view |
| Session Row | Day + time digits, title, meta, chips | `List` row |
| Item Row | Name + rule summary + chevron | `NavigationLink` row |
| Settings Row | Label + value + chevron, or toggle | `LabeledContent`, `Toggle` |
| Notification | Banner + action list | system notification with category actions |
| Status Bar, Tab Bar | Canvas only; system in code | `TabView` |

## 7. Screens

| Frame | Screen | Primary intent |
|---|---|---|
| 01 Upcoming | Next session card (timing digits, lane lines, place picker, reminder timeline) + next 14 days | Choose the place for the next run |
| 02 Checklist | Kit check in progress, groups Charge / Pack / Bring, lane progress | Tick the kit |
| 03 Checklist All Set | 12 of 12, volt "ALL SET", done button | Leave |
| 04 Notifications | H-24 with UI / Home actions, H-12, leave | Act from the Lock Screen |
| 05 Items | Grouped item list | Find an item to change |
| 06 Item Edit | Name, remind me to, sessions, UI only, delete | Change one rule |
| 07 Settings | Calendar, keywords, offsets, nightly refresh, install expiry, test | Change timing |
| 08 Onboarding | Calendar + notification permission | Grant access |
| 09 Calendar Denied | Empty / denied states | Recover |
| 10 Upcoming Dark | Dark theme check | - |
| 11 Lock Screen | Live Activity with tick pills, Lock Screen widgets | Tick without opening the app |
| 13 Kit check · Largest text (AX1) | Dynamic Type check at the largest accessibility size | Prove nothing clips |
| 12 Dynamic Island + Control + Siri | Island compact / expanded, Control Center control, Siri answer, Home widget | Glance and ask |

Session detail is not a separate screen: the next-session card on Upcoming and the checklist cover it.

## 8a. Accessibility rules (a11y audit 14 Nov 2026)

| WCAG | Rule in code |
|---|---|
| 1.1.1 / 4.1.2 | Every icon-only button gets a label: Back "Back to Upcoming", Refresh "Refresh sessions", Add "Add item", Cancel "Cancel", Save "Save item", Jump "Go to next unticked item". Checklist rows read "Watch, Charge, ticked" (name, group, state). Lane progress is hidden from VoiceOver; the "7 of 12" text carries it. |
| 1.4.1 | Status never by colour alone: "Place not set" has an icon and words, ticked rows have a tick, "UI only" is text. |
| 1.4.3 | Measured with `measure_render` on every exported screen, light and dark: all pass AA. Gradient cards carry a solid base fill equal to their lightest stop, so the measurement is the worst case. |
| 1.4.4 / Dynamic Type | Frame 13 shows Kit check at the largest accessibility size: rows grow, nothing clips. At accessibility sizes, the "UI only" tag moves under the item name (`ViewThatFits` or `dynamicTypeSize.isAccessibilitySize`). |
| 1.4.11 | Checkbox border `rule-strong` 3.59:1 (light) / 3.23:1 (dark). Toggles are the system `Toggle`; the off track on the canvas uses `rule-strong` so it reads at 3:1. |
| 2.4.11 | Floating tab bar and kit bar must not hide the focused or last row: content uses `.safeAreaInset(edge: .bottom)` so it scrolls clear of them. |
| 2.5.8 | All controls are 44 pt or more, including the Live Activity tick buttons (44 pt). |
| Reduce Motion / Transparency | System handles glass; custom glass falls back to `raised` + `rule` border; tick bounce and count transitions are skipped with Reduce Motion. |

## 8. States checklist (each screen)

Empty (no runs in 14 days), loading (first calendar read), calendar denied, calendar not found, notifications off (banner on Upcoming), place not set (warn chip), all set (volt). Frame 09 shows the shared empty-state layout.
