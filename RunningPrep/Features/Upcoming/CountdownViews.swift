import RunPrepCore
import SwiftUI

extension CountdownLabel {
    static func forSession(_ session: Session, now: Date = Date()) -> CountdownLabel {
        Countdown.label(from: now, to: session.start, calendar: .current)
    }
}

/// White pill on the cobalt card, followed by the weekday.
struct CountdownKicker: View {
    let label: CountdownLabel
    let weekday: String

    private static let lightText = Color(red: 0xE3 / 255, green: 0xE8 / 255, blue: 0xFF / 255)

    var body: some View {
        HStack(spacing: 8) {
            Text(label.text)
                .font(.subheadline.bold())
                .foregroundStyle(PlacePicker.cobalt)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.white, in: Capsule())
            Text(weekday)
                .font(.subheadline)
                .foregroundStyle(Self.lightText)
        }
    }
}

/// First line of a row: the countdown, then the long date. Weight and colour follow the tier.
struct CountdownDateLine: View {
    let label: CountdownLabel
    let dateText: String

    var body: some View {
        switch label.tier {
        case .soon:
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(label.text)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.accentColor)
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Color("AccentSoft"), in: Capsule())
                dateOnly
            }
        case .near:
            Text(label.text).font(.subheadline.weight(.semibold)).foregroundStyle(Color.accentColor)
                + Text(" \u{00B7} \(dateText)").font(.subheadline).foregroundStyle(.secondary)
        case .later:
            Text("\(label.text) \u{00B7} \(dateText)").font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var dateOnly: some View {
        Text("\u{00B7} \(dateText)").font(.subheadline).foregroundStyle(.secondary)
    }
}
