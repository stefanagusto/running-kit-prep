import SwiftUI
import UserNotifications
import ActivityKit
import WidgetKit

@main
struct SigningSpikeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var groupResult = "Not run"
    @State private var notifResult = "Not run"
    @State private var startResult = "Not run"
    @State private var endResult = "Not run"

    var body: some View {
        NavigationStack {
            List {
                Section("App Group write") {
                    Button("Write and read back") { writeGroup() }
                    Text(groupResult)
                }
                Section("Notifications + Time Sensitive") {
                    Button("Ask permission and schedule in 10 s") {
                        Task { @MainActor in await runNotifications() }
                    }
                    Text(notifResult)
                }
                Section("Live Activity") {
                    Button("Start Live Activity") {
                        Task { @MainActor in startActivity() }
                    }
                    Text(startResult)
                    Button("End Live Activities") {
                        Task { @MainActor in await endActivities() }
                    }
                    Text(endResult)
                }
                Section {
                    Text("Record results in spike/RESULTS.md")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Signing Spike")
        }
    }

    private func writeGroup() {
        guard let defaults = UserDefaults(suiteName: SpikeShared.appGroup) else {
            groupResult = "FAIL: suite unavailable"
            return
        }
        defaults.set(Date().formatted(), forKey: SpikeShared.key)
        let value = defaults.string(forKey: SpikeShared.key) ?? "nil"
        groupResult = "OK: \(value)"
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func runNotifications() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            let settings = await center.notificationSettings()
            var text = "granted: \(granted)\nauthorization: \(describe(settings.authorizationStatus))\ntimeSensitiveSetting: \(describe(settings.timeSensitiveSetting))"

            let content = UNMutableNotificationContent()
            content.title = "Spike: time sensitive"
            content.body = "Lock the phone now. If this shows as Time Sensitive, the entitlement works."
            content.sound = .default
            content.interruptionLevel = .timeSensitive
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            let request = UNNotificationRequest(identifier: "spike.timesensitive", content: content, trigger: trigger)
            do {
                try await center.add(request)
                text += "\nscheduled for 10 s from now"
            } catch {
                text += "\nschedule error: \(error.localizedDescription)"
            }
            notifResult = text
        } catch {
            notifResult = "Permission error: \(error.localizedDescription)"
        }
    }

    private func describe(_ status: UNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "notDetermined"
        case .denied: return "denied"
        case .authorized: return "authorized"
        case .provisional: return "provisional"
        case .ephemeral: return "ephemeral"
        @unknown default: return "unknown"
        }
    }

    private func describe(_ setting: UNNotificationSetting) -> String {
        switch setting {
        case .notSupported: return "notSupported"
        case .disabled: return "disabled"
        case .enabled: return "enabled"
        @unknown default: return "unknown"
        }
    }

    private func startActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            startResult = "Live Activities are disabled (areActivitiesEnabled is false)"
            return
        }
        do {
            let activity = try Activity.request(
                attributes: SpikeActivityAttributes(sessionTitle: "Long Run 18 km"),
                content: .init(state: .init(ticked: 7, total: 12), staleDate: nil)
            )
            startResult = "OK: id \(activity.id)"
        } catch {
            startResult = "Error: \(error.localizedDescription)"
        }
    }

    private func endActivities() async {
        let all = Activity<SpikeActivityAttributes>.activities
        for activity in all {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        endResult = "Ended \(all.count) activities"
    }
}
