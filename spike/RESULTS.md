# S0 signing spike results

Run on 14 Nov 2026, iPhone 17, free Apple ID (Personal Team "Stefan Hutapea"), Xcode with iOS 26 SDK. Date of first install: 14 Nov 2026.

| Check | Result (pass/fail) | Notes / error text |
|---|---|---|
| Widget extension signs and installs | pass | App ran on the iPhone with the SpikeWidgets extension embedded |
| App Group entitlement signs | pass | `group.com.stefanagusto.runprep.spike` |
| App Group write/read in app | pass | "OK: 14/11/2026, 14.24" |
| Widget reads App Group value | pass | App Group check widget showed the value written by the app |
| Time Sensitive entitlement signs | fail | "Personal development teams, including "Stefan Hutapea", do not support the Time Sensitive Notifications capability." Entitlement removed from project.yml, rest retested |
| timeSensitiveSetting value | notSupported | granted: true, authorization: authorized |
| Time Sensitive notification shown as Time Sensitive on Lock Screen | n/a | Arrived as a normal notification (expected without the entitlement) |
| Live Activity starts | pass | "OK: id 46BDB8BD-..." and shown on the Lock Screen |
| Dynamic Island shows | pass | Compact view shown on iPhone 17 |
| App still opens after 7 days (date to check: 21 Nov 2026) | pending | Expected to stop opening; re-run from Xcode to renew |

Harmless warning: "All interface orientations must be supported unless the app requires full screen" (set orientations in the real app).

## Decision

- [x] Partial: everything except Time Sensitive works on the free Apple ID. P2 (Live Activity, widgets, Control Center control) stays in the plan without the paid program. The leave reminder uses a normal notification; Time Sensitive comes back only with the paid program.
