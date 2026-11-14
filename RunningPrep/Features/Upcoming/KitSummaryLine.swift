import RunPrepCore
import SwiftUI

/// One line under the place picker that shows what the place changes:
/// "Pack 4 · Bring 6, incl. kunci motor and STNK" for UI campus, "Pack 4 · Bring 4" for Home.
/// Uses the seed items until items become editable (S6).
struct KitSummaryLine: View {
    let session: Session
    var items: [ItemRule] = SeedItems.all

    private static let lightText = Color(red: 0xE3 / 255, green: 0xE8 / 255, blue: 0xFF / 255)

    private var kit: Kit { KitBuilder.kit(for: session.type, place: session.place, items: items) }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "backpack")
                .foregroundStyle(Self.lightText)
                .accessibilityHidden(true)
            Text(text)
                .font(.subheadline)
                .contentTransition(.opacity)
        }
        .animation(.easeOut(duration: 0.2), value: text)
        .accessibilityElement(children: .combine)
    }

    private var text: String {
        let pack = kit.items(in: [.pack]).count
        let bring = kit.items(in: [.bring])
        var parts: [String] = []
        if pack > 0 { parts.append("Pack \(pack)") }
        parts.append("Bring \(bring.count)")
        var line = parts.joined(separator: " \u{00B7} ")
        let uiItems = bring.filter { item in items.first { $0.id == item.id }?.uiOnly == true }
        if !uiItems.isEmpty {
            let names = uiItems.map { Self.shortName($0.name) }
            let joined = names.count == 2 ? "\(names[0]) and \(names[1])" : names.joined(separator: ", ")
            line += uiItems.contains(where: \.conditional)
                ? ", incl. \(joined) if at UI"
                : ", incl. \(joined)"
        }
        return line
    }

    /// "Motorbike key (kunci motor)" reads as "kunci motor"; other names stay as they are.
    private static func shortName(_ name: String) -> String {
        guard let open = name.firstIndex(of: "("), let close = name.lastIndex(of: ")"), open < close else {
            return name
        }
        return String(name[name.index(after: open)..<close])
    }
}
