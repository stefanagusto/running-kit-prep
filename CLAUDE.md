# Running Prep App

Personal project: an iPhone reminder for what to bring to each run (normal run, long run, race; UI campus or home), with charge and packing reminders the day before.

## Read at the start of each session
1. `PLAN.md` - status hub and progress table. Update it when a step changes.
2. `memory.md` - durable facts and decisions. Add new ones with the date.
3. `docs/PRD.md`, `docs/TDD.md`, `docs/DESIGN.md` - the guides. Code must follow them; change a guide first, then the code.
4. `tasks/plan.md` and `tasks/todo.md` - implementation plan and task list for `/agent-skills:build`.
5. Design: `Design/Running Prep App.pen`, only through the pencil MCP (never read the .pen file directly).
3. For running context only: `../Running Coach/CLAUDE.md` and `../Running Coach/memory/running-memory.md`. Read only, never edit files in `../Running Coach/` from this project.

## Rules
- Personal project: keep it separate from WPH work.
- Wait for my OK on the plan before building. Ask before anything that publishes, installs or sends.
- Use the agent-orchestration skill: Opus does planning, research and review; Sonnet builds from the written plan; Haiku runs checks and searches. Always set `model`. Check every subagent result before using it. Copy the item rules and these rules into each brief.
- The item rules table in `docs/PRD.md` section 6 is the source of truth for the seed items (`RunPrepCore/Sources/RunPrepCore/SeedItems.swift`). Once the app is installed, the user's edits in the app win.
- Windows workspace with no Swift toolchain: write Swift here, but builds and tests happen on my Mac at each checkpoint in PLAN.md section 4. Never claim code compiles or tests pass until I paste the Mac output.
- Stack: iOS 26+, SwiftUI with Liquid Glass (standard containers get glass automatically; custom `.glassEffect` only on controls, never on content rows), SwiftData, EventKit, UserNotifications, App Intents, later ActivityKit and WidgetKit. No third-party packages, no server. Pure logic goes in the `RunPrepCore` Swift package; the Xcode project comes from `project.yml` (XcodeGen), never a hand-edited `.xcodeproj`.
- Free Apple ID: avoid capabilities a free team may not get (App Groups, push).
- UI: Apple HIG + Liquid Glass, SF Pro with Dynamic Type, SF Symbols, no emoji. Follow `docs/DESIGN.md` tokens. Cover empty, loading and permission-denied states. Respect Reduce Transparency and Reduce Motion.
- This folder is its own git repo; I push to GitHub myself. Commit only when I ask.
- Write in plain English, short sentences.
