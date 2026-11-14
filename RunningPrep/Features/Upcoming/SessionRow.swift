import RunPrepCore
import SwiftUI

extension SessionType {
    var label: String {
        switch self {
        case .normal: return "Normal run"
        case .long: return "Long run"
        case .race: return "Race"
        }
    }

    var symbol: String {
        switch self {
        case .normal: return "figure.run"
        case .long: return "road.lanes"
        case .race: return "medal"
        }
    }
}

extension Session {
    var placeText: String {
        if type == .race { return "Race venue" }
        switch place {
        case .ui: return "UI campus"
        case .home: return "Home"
        case .none: return "Place not set"
        }
    }

    var placeSymbol: String {
        if type == .race { return "flag" }
        return place == nil ? "exclamationmark.circle" : "mappin.and.ellipse"
    }

    var placeIsMissing: Bool { type != .race && place == nil }

    var timeText: String {
        start.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
    }

    var longDateText: String {
        start.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    var accessibilityText: String {
        "\(title), \(longDateText), \(timeText), \(type.label.lowercased()), \(placeText.lowercased())"
    }
}

enum ChipStyle {
    case accent, neutral, warn
}

struct Chip: View {
    let text: String
    let symbol: String
    var style = ChipStyle.accent

    var body: some View {
        ChipContent(text: text, symbol: symbol)
            .foregroundStyle(foreground)
            .background(background, in: Capsule())
    }

    private var foreground: Color {
        switch style {
        case .accent: return Color.accentColor
        case .neutral: return Color.secondary
        case .warn: return Color("Warn")
        }
    }

    private var background: Color {
        switch style {
        case .accent: return Color("AccentSoft")
        case .neutral: return Color(.secondarySystemFill)
        case .warn: return Color("WarnSoft")
        }
    }
}

/// Icon and text kept tight on one line; shared by row chips and card chips.
struct ChipContent: View {
    let text: String
    let symbol: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol).imageScale(.small)
            Text(text).lineLimit(1)
        }
        .font(.footnote.weight(.semibold))
        .fixedSize()
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }
}

struct SessionRow: View {
    let session: Session
    var now = Date()

    private var countdown: CountdownLabel { .forSession(session, now: now) }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.start.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(session.timeText)
                    .font(.title2.bold())
                    .monospacedDigit()
            }
            .frame(minWidth: 56, alignment: .leading)
            VStack(alignment: .leading, spacing: 6) {
                CountdownDateLine(label: countdown, dateText: session.longDateText)
                Text(session.title).font(.headline)
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 6) { chips }
                    VStack(alignment: .leading, spacing: 6) { chips }
                }
            }
        }
        .padding(.vertical, 4)
        .frame(minHeight: 44, alignment: .topLeading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(countdown.text), \(session.accessibilityText)")
    }

    @ViewBuilder
    private var chips: some View {
        Chip(text: session.type.label, symbol: session.type.symbol, style: .neutral)
        Chip(
            text: session.placeText,
            symbol: session.placeSymbol,
            style: session.placeIsMissing ? .warn : .neutral
        )
    }
}
