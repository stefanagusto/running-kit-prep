import RunPrepCore
import SwiftUI

/// The reminders of the next session, one row each, on the card.
struct ReminderTimeline: View {
    let slots: [ReminderSlot]
    var now = Date()

    private static let iconColor = Color(red: 0xE3 / 255, green: 0xE8 / 255, blue: 0xFF / 255)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(slots, id: \.kind) { slot in
                row(slot)
            }
        }
        .padding(.top, 4)
    }

    private func row(_ slot: ReminderSlot) -> some View {
        let info = Self.info(slot)
        let text = Self.timeText(slot.fireDate) + (slot.fireDate <= now ? " \u{00B7} passed" : "")
        return HStack(spacing: 10) {
            Image(systemName: info.symbol)
                .foregroundStyle(Self.iconColor)
                .frame(width: 24)
                .accessibilityHidden(true)
            Text(info.label)
                .font(.subheadline.weight(.semibold))
            Spacer(minLength: 8)
            Text(text)
                .font(.subheadline)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
        }
        .frame(minHeight: 28)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(info.label), \(text)")
    }

    private static func info(_ slot: ReminderSlot) -> (symbol: String, label: String) {
        switch slot.kind {
        case .h24: return ("battery.100percent.bolt", "Charge + pack")
        case .h12:
            return ("backpack", ReminderPlanner.packWord(fireDate: slot.fireDate, calendar: .current))
        default: return ("figure.run", "Leave + checklist")
        }
    }

    private static func timeText(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.abbreviated).hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
    }
}
