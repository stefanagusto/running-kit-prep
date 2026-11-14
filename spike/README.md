# S0 free-team signing spike

Throwaway project. It checks what a free Apple ID personal team can sign: a widget extension, an App Group, Time Sensitive notifications and a Live Activity. This folder is deleted after S0.

Nothing here was compiled. It was written on Windows with no Swift toolchain, so expect to fix small errors.

## Steps (on the Mac)

0. Get the code: commit and push this repo from Windows (`git remote add origin <your GitHub repo>`, `git push -u origin main`), then `git clone` or `git pull` on the Mac. Needs Xcode 26 or later (iOS 26 SDK).
1. Install XcodeGen: `brew install xcodegen`.
2. Replace `CHANGE-ME` with a unique reverse-DNS name in `project.yml` (every place it appears) and in `Shared/SpikeActivityAttributes.swift` (the app group string appears once there; use the same value as in `project.yml`).
3. Run `cd spike && xcodegen generate`.
4. Open `SigningSpike.xcodeproj`.
5. For both targets (SigningSpike and SpikeWidgets), open Signing & Capabilities and pick your personal team.
6. Plug in the iPhone. Turn on Developer Mode if asked. Run the SigningSpike scheme.
7. On the iPhone, trust the developer profile: Settings > General > VPN & Device Management.
8. Tap each row in the app. For the notification test, tap the button, then lock the phone within 10 seconds. Add the widget to the Home Screen or Lock Screen to check the App Group value.
9. Fill in `RESULTS.md`.
10. If signing fails for a capability, copy the exact Xcode error into `RESULTS.md`, remove that entitlement line from `project.yml`, run `xcodegen generate` again, and retest the rest.
