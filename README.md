# Running Prep App

A personal iPhone app. It reads the training calendar, works out what to charge, pack and bring for each run, and sends reminders the day before.

## Build on the Mac

1. `brew install xcodegen`
2. `cd running-kit-prep`
3. `cd RunPrepCore && swift test` (expected: all tests pass)
4. `cd .. && xcodegen generate`
5. `open RunningPrep.xcodeproj`
6. In Xcode, select the RunningPrep target, open Signing & Capabilities and pick your Personal Team.
7. Connect the iPhone, choose it as the run destination and press Run.

A free Apple ID build stops opening after 7 days. Run it from Xcode again to re-install.
