import RunPrepCore
import SwiftUI

struct NextSessionCard: View {
    let session: Session
    let calendarName: String

    private static let lightText = Color(red: 0xE3 / 255, green: 0xE8 / 255, blue: 0xFF / 255)

    private var dayWord: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(session.start) { return "Today" }
        if calendar.isDateInTomorrow(session.start) { return "Tomorrow" }
        return session.start.formatted(.dateTime.weekday(.wide))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Next \u{00B7} \(dayWord)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Self.lightText)
            Text(session.timeText)
                .font(.system(size: 56, weight: .bold))
                .monospacedDigit()
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
            lanes
            Text(session.title)
                .font(.title3.weight(.semibold))
            Text("\(session.start.formatted(.dateTime.day().month(.wide))) \u{00B7} \(calendarName)")
                .font(.subheadline)
                .foregroundStyle(Self.lightText)
            chips
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Next session. \(dayWord). \(session.accessibilityText)")
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

    private var chips: some View {
        HStack(spacing: 6) {
            cardChip(session.type.label, session.type.symbol)
            if session.type != .race {
                cardChip(session.placeText, session.placeSymbol)
            }
        }
        .padding(.top, 4)
    }

    private func cardChip(_ text: String, _ symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.white.opacity(0.18), in: Capsule())
    }
}
