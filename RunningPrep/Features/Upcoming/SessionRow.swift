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
        start.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute())
    }

    var longDateText: String {
        start.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    var accessibilityText: String {
        "\(title), \(longDateText), \(timeText), \(type.label.lowercased()), \(placeText.lowercased())"
    }
}

struct Chip: View {
    let text: String
    let symbol: String
    var warn = false

    var body: some View {
        Label(text, systemImage: symbol)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(warn ? Color("Warn") : Color.accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(warn ? Color("WarnSoft") : Color("AccentSoft"), in: Capsule())
    }
}

struct SessionRow: View {
    let session: Session

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
                Text(session.title).font(.headline)
                Text(session.longDateText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Chip(text: session.type.label, symbol: session.type.symbol)
                    Chip(text: session.placeText, symbol: session.placeSymbol, warn: session.placeIsMissing)
                }
            }
        }
        .padding(.vertical, 4)
        .frame(minHeight: 44, alignment: .topLeading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(session.accessibilityText)
    }
}
