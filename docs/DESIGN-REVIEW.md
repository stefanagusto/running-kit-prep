# Design review 001 - 14 Nov 2026

Scope: every frame in `Design/Running Prep App.pen` (design system, screens 01-10, surfaces 11-12). Run with antislop (mode: during, global preference) and ux-ui-agent-skills design-review. Static mockup: nothing is clickable, so interaction checks were done by inspection, not by clicking (R-35).

## Scores (after fixes)

| Dimension | Weight | Score | Note |
|---|---|---|---|
| Visual hierarchy | 20% | 8 | One focal point per screen: next-run card, kit count, item list, timing settings |
| Consistency | 20% | 8 | One glass recipe, shared components, sentence-case labels |
| Accessibility | 20% | 8 | Contrast measured; 44 pt targets; Reduce Transparency fallback documented. Dynamic Type only checked on paper |
| Usability | 20% | 8 | Place in one tap; ticks saved; floating "next item" jump |
| Responsiveness | 10% | 7 | iPhone 390 pt only; small (375) and Max (430) widths not drawn |
| Performance | 10% | 8 | System materials; no heavy imagery |
| **Overall** | | **7.9** | Was about 6.5 before fixes (doubled glass, failing contrast, small target) |

## Findings and fixes

| # | Severity | Where | Finding | Fix | Status |
|---|---|---|---|---|---|
| 1 | Critical | Tab bar, all glass | Gradient edge + inner highlight + blur + large shadow drew a doubled outline; did not read as Liquid Glass (reported by owner) | Single recipe: translucent body, 1 px hairline, blur, one soft shadow. Selected tab is a glass pill | fixed |
| 2 | Critical | 01 Upcoming card | `#c9d3ff` secondary text 3.85:1 on the lightest corner (R-25) | Card gradient starts at `#2b4be6`; secondary text `#e3e8ff`, 5.31:1 | fixed |
| 3 | Major | 02/03 Kit check | "UI campus · change" chip about 24 pt tall, below 44 pt (R-03, WCAG 2.5.8) | 44 pt glass capsule button | fixed |
| 4 | Major | 04 Notifications | Light-theme cards on a dark Lock Screen looked pasted on | Frame set to dark theme; cards use dark glass | fixed |
| 5 | Major | 03 All set | Frame was 1212 pt tall, not a phone; done button at the end of a long scroll | Phone height 844, floating glass-prominent done button | fixed |
| 6 | Major | 09 States | No loading state (R-27) | Added "first calendar read" loading state | fixed |
| 7 | Minor | All screens | All-caps tracked labels (R-06, iOS 26 headers are sentence case) | 32 labels to sentence case, 13 pt semibold | fixed |
| 8 | Minor | 01 Session rows | Place chips look tappable but are labels | Documented: chips are labels, row tap opens the checklist | documented |
| 9 | Enhancement | All screens | Only 390 pt width drawn | Check 375 and 430 widths in Xcode previews during S2 | open |
| 10 | Enhancement | 11-12 | Board labels still all caps | Annotation only, not app UI | kept |

Nielsen heuristics touched: H1 (lane progress, "5 to go", Live Activity status), H3 (back, cancel, change place), H4 (iOS 26 tab bar and toolbars), H5 (delete confirmation in PRD), H8 (one coloured card per screen).

## antislop Delivery Gate

Block 1, Hard Gate (all must be "no"):
- R-02 PASS: no em dash in screen copy (session titles use an en dash from the calendar data).
- R-03 PASS: 390 pt frames, no clipped text; 44 pt targets after fix 3.
- R-17, R-18, R-36, R-38 PASS: no statistics, testimonials or claims; numbers are the owner's own sessions and items.
- R-23 PASS: no logo made; app icon is a placeholder glyph on a cobalt tile, to confirm before S1.
- R-24 PASS: tab bar has three destinations, each drawn (Upcoming, Items, Settings).
- R-25 PASS: pairs measured (see DESIGN.md section 3 and fix 2).
- R-26, R-35 PASS by inspection: static mockup, every control maps to a TDD action; not clickable, so no click-through was possible.
- R-27 PASS: empty, loading, denied, not found, notifications off.
- R-28 PASS: no FAQ.
- R-32 n/a for a mockup; VoiceOver and Full Keyboard Access are in the TDD test plan.
- R-33 PASS: no patch scripts.
- R-34 PASS: light and dark drawn for Upcoming; tokens are themed.
- R-37 PASS: direction is `docs/DESIGN.md` (owner chose Start Line palette and asked for Liquid Glass).

Block 2, Purpose-Gate:
- R-01 gradient: one cobalt gradient card per screen, reason: marks the next run as the focal point. PASS.
- R-04 icons: Lucide is a canvas stand-in for SF Symbols (mapping in DESIGN.md section 5). PASS with reason.
- R-06 type: SF Pro because the owner asked for the Apple design framework; Inter is the canvas stand-in. PASS.
- R-10 glass: owner override recorded. Liquid Glass is the platform material the owner asked for; it is limited to system bars, toolbar buttons, the place picker, the floating kit bar and notifications, never on content rows.
- R-12 shadow: one soft shadow only on floating glass (elevation marker). PASS.
- R-13 glow: none. R-07, R-08, R-09, R-14, R-19, R-22: not used or passing.

Block 3, Liveliness: dials ENERGY 2 / RHYTHM 2 / MOTION 1 (utility app, system motion). Focal point per screen yes; one accent (cobalt) plus volt only for "all set"; identity motif = timing digits + lane lines + bib chip. PASS.

Block 4, Craftsmanship: no AI template layout, radius varies by role (capsule controls, 22/26 pt cards), no generic CTAs ("Allow notifications", "Open iOS Settings", "Done · have a good run"), palette = cobalt + volt + warn + neutrals. PASS.

# Review 002 - 14 Nov 2026 (design-screen + a11y-audit + design critic)

Method: every screen exported from pen.dev to HTML, then real-render gates run on the exports (`measure_render`, `slop_tells`, `check_no_emoji`), plus a canvas tap-target measurement and an adversarial design-critic pass. Brief: consumer utility, one expert user, mood "ready", subtle motion, Apple iOS 26 HIG + Start Line.

## Gate output (after fixes)
- measure_render: OK on all 12 exports (upcoming 43, upcoming dark 43, checklist 29, all set 28, notifications 20, items 41, item edit 16, settings 27, onboarding 10, denied 8, lock 15, large text 26 text elements meet WCAG AA).
- check_no_emoji: OK. slop_tells: OK on upcoming and all set.
- Tap targets (canvas bounds): every control 44 pt or more.
- Not run: verify_states / verify_target_size / keyboard gates. The exports are static mockups with no real buttons, so those gates have nothing to exercise; they run against the SwiftUI app later (VoiceOver and Full Keyboard Access in the TDD test plan).

## a11y findings
| WCAG | Sev | Finding | Fix |
|---|---|---|---|
| 1.4.3 | P0 | Dark Upcoming kept old `#c9d3ff` text, 4.38:1 (gate caught it) | `#e3e8ff`, re-measured OK |
| 1.4.3 | P0 | Gate could not see gradient backgrounds, so card and lock text could not be measured | Gradients carry a solid base equal to their lightest stop; manual worst cases: white 6.46, `#e3e8ff` 5.31, volt-free now |
| 1.4.11 | P1 | Off toggle track `rule` on `raised` 1.37:1 | Off track `rule-strong` (3.59:1); code uses system Toggle |
| 2.5.8 | P1 | Live Activity tick buttons 40 pt | 44 pt |
| 1.4.4 | P1 | Dynamic Type not shown | Frame 13: Kit check at AX1, nothing clips |
| 4.1.2, 2.4.11 | P1 | Icon-only buttons need names; floating bars can hide focus | Labels and `.safeAreaInset` rule in DESIGN.md 8a |
| 1.4.1 | pass | Status always icon + text | - |

## Design critic (verdict: revise -> fixed)
| # | Finding | Result |
|---|---|---|
| 1 | Toggles clipped (item edit, settings) | Export artifact only: browser font metrics differ; canvas renders correctly (checked) |
| 2 | "Allowed" clipped on onboarding | Export artifact only (checked on canvas). Dead space and "Step 2 of 2" were real: button anchored to bottom, step label removed |
| 3 | Place picker unclear on the cobalt card; warn chip competes with the digits | Clear glass picker, white bold labels, bold prompt; warn chip removed from card |
| 4 | Volt used beyond "all set" | Card icons pale cobalt; lock countdown, ring and island count white or cobalt |
| 5 | All set had no payoff; button over cut row | Progress lanes turn volt, larger ALL SET next to 12 of 12, scroll edge fade under the Done button |
| 6 | 20 pt vs 16 pt margins | 16 pt everywhere |
| 7 | Notification actions looked like text | Actions carry icons (bike, house) and a divider |
| 8 | Denied screen showed a design legend; generic icon tile | Legend removed from the screen (states listed in DESIGN.md 8); large symbol without tile, ContentUnavailableView pattern kept centred (iOS convention) |
