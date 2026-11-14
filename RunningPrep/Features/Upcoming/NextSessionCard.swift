import RunPrepCore
import SwiftUI

struct NextSessionCard: View {
    let session: Session
    let slots: [ReminderSlot]
    let onPlace: (Place) -> Void
    let onOpenChecklist: () -> Void
    var now = Date()

    private static let lightText = Color(red: 0xE3 / 255, green: 0xE8 / 255, blue: 0xFF / 255)

    private var countdown: CountdownLabel { .forSession(session, now: now) }
    private var weekday: String { session.start.formatted(.dateTime.weekday(.wide)) }

    private var metaText: String {
        let date = session.start.formatted(.dateTime.day().month(.wide))
        return session.calendarTitle.isEmpty ? date : "\(date) \u{00B7} \(session.calendarTitle)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            summary
            if session.type != .race {
                PlacePrompt(session: session, select: onPlace)
            } else {
                Button(action: onOpenChecklist) {
                    KitSummaryLine(session: session)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            openButton
            ReminderTimeline(slots: slots, now: now)
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0x2B / 255, green: 0x4B / 255, blue: 0xE6 / 255),
                    Color(red: 0x1A / 255, green: 0x2F / 255, blue: 0xA8 / 255),
                    Color(red: 0x0F / 255, green: 0x1A / 255, blue: 0x5C / 255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
        )
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 8) {
            CountdownKicker(label: countdown, weekday: weekday)
            Text(session.timeText)
                .font(.system(size: 56, weight: .bold))
                .monospacedDigit()
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
            lanes
            Text(session.title)
                .font(.title3.weight(.semibold))
            Text(metaText)
                .font(.subheadline)
                .foregroundStyle(Self.lightText)
            ChipContent(text: session.type.label, symbol: session.type.symbol)
                .background(.white.opacity(0.18), in: Capsule())
                .padding(.top, 4)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Next session. \(countdown.text), \(weekday). \(session.accessibilityText)")
    }

    private var openButton: some View {
        Button(action: onOpenChecklist) {
            Label("Open kit check", systemImage: "checklist")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PlacePicker.cobalt)
                .padding(.horizontal, 16)
                .frame(minHeight: 44)
                .background(.white, in: Capsule())
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    private var lanes: some View {
        VStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { _ in
                Rectangle().fill(.white.opacity(0.2)).frame(height: 1)
            }
        }
        .padding(.vertical, 4)
        .accessibilityHidden(true)
    }
}
