import RunPrepCore
import SwiftUI

/// Two-segment place control for the cobalt card. Plain translucent capsule, so it
/// does not depend on a glass API and still reads with Reduce Transparency on.
struct PlacePicker: View {
    let selection: Place?
    let select: (Place) -> Void

    static let cobalt = Color(red: 0x1F / 255, green: 0x3F / 255, blue: 0xD6 / 255)

    var body: some View {
        HStack(spacing: 0) {
            segment(.ui, title: "UI campus", symbol: "bicycle", label: "Start at UI campus")
            segment(.home, title: "Home", symbol: "house", label: "Start at home")
        }
        .padding(3)
        .background(.white.opacity(0.14), in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.35), lineWidth: 1))
    }

    private func segment(_ place: Place, title: String, symbol: String, label: String) -> some View {
        let selected = selection == place
        return Button {
            select(place)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: symbol).imageScale(.medium)
                Text(title).lineLimit(1)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(selected ? Self.cobalt : Color.white)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(selected ? Color.white : Color.clear, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// The card's one action: the prompt, the picker and, when the calendar chose, where that came from.
struct PlacePrompt: View {
    let session: Session
    let select: (Place) -> Void

    private static let lightText = Color(red: 0xE3 / 255, green: 0xE8 / 255, blue: 0xFF / 255)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Where do you start?")
                .font(.headline.weight(.bold))
            PlacePicker(selection: session.place, select: select)
            if session.placeSource == .calendar {
                Text(sourceText)
                    .font(.footnote)
                    .foregroundStyle(Self.lightText)
            }
        }
        .padding(.top, 4)
    }

    private var sourceText: String {
        let location = session.location?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return location.isEmpty || location.count > 30
            ? "From your calendar"
            : "From your calendar \u{00B7} \(location)"
    }
}
