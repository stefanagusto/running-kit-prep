import RunPrepCore
import SwiftUI

extension Color {
    /// Volt: "all set" only (DESIGN.md).
    static let volt = Color(red: 0xD7 / 255, green: 0xF2 / 255, blue: 0x3A / 255)
}

/// "7 of 12", "5 to go" and the lane progress. The count text carries it for VoiceOver.
struct ChecklistProgressHeader: View {
    let done: Int
    let total: Int
    let segments: [Bool]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var complete: Bool { total > 0 && done == total }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("\(done) of \(total)")
                    .font(.title.bold())
                    .contentTransition(.numericText())
                if complete {
                    BibChip()
                } else {
                    Text("\(total - done) to go")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            LaneProgress(segments: segments, complete: complete)
        }
        .animation(reduceMotion ? nil : .snappy, value: done)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            complete ? "All set. \(done) of \(total) ticked." : "\(done) of \(total) ticked, \(total - done) to go"
        )
    }
}

struct LaneProgress: View {
    let segments: [Bool]
    let complete: Bool

    var body: some View {
        HStack(spacing: 3) {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, on in
                Capsule()
                    .fill(on ? (complete ? Color.volt : Color.accentColor) : Color(.tertiarySystemFill))
                    .frame(height: 6)
            }
        }
        .accessibilityHidden(true)
    }
}

/// The race-bib chip. The only all-caps text in the app.
struct BibChip: View {
    var body: some View {
        Text("ALL SET")
            .font(.subheadline.weight(.heavy))
            .fontWidth(.condensed)
            .tracking(1)
            .foregroundStyle(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.volt, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

/// Subline plus the place button (hidden for races, and while the place question is showing).
struct ChecklistSubline: View {
    let session: Session
    let setPlace: (Place) -> Void

    private var timeText: String {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: session.start)
        let weekday = session.start.formatted(.dateTime.weekday(.wide))
        return "\(weekday) " + String(format: "%02d.%02d", parts.hour ?? 0, parts.minute ?? 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(session.title) \u{00B7} \(timeText)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if session.type != .race, session.place != nil {
                placeMenu
            }
        }
    }

    private var placeMenu: some View {
        Menu {
            Button { setPlace(.ui) } label: {
                Label("UI campus", systemImage: session.place == .ui ? "checkmark" : "bicycle")
            }
            Button { setPlace(.home) } label: {
                Label("Home", systemImage: session.place == .home ? "checkmark" : "house")
            }
        } label: {
            Text("\(session.placeText) \u{00B7} change")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .frame(minHeight: 44)
                .glassEffect(.regular, in: .capsule)
        }
        .accessibilityLabel("Start place: \(session.placeText). Change")
    }
}
