import RunPrepCore
import SwiftUI

extension ItemGroup {
    var title: String {
        switch self {
        case .charge: return "Charge"
        case .pack: return "Pack"
        case .bring: return "Bring"
        }
    }
}

/// One row of the list. Watch and AirPods appear in two groups, so the id is the tick key.
struct ChecklistEntry: Identifiable {
    let item: KitItem
    let uiOnly: Bool
    let ticked: Bool
    var id: String { Checklist.tickKey(item) }
}

struct ChecklistRow: View {
    let entry: ChecklistEntry
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack(spacing: 14) {
                Checkbox(isOn: entry.ticked)
                Text(entry.item.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if entry.uiOnly {
                    Chip(
                        text: entry.item.conditional ? "(if at UI)" : "UI only",
                        symbol: "bicycle",
                        style: .neutral
                    )
                }
            }
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: entry.ticked)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(entry.ticked ? [.isButton, .isSelected] : [.isButton])
        .accessibilityHint("Double tap to \(entry.ticked ? "untick" : "tick").")
    }

    private var accessibilityText: String {
        var parts = [entry.item.name, entry.item.group.title]
        if entry.uiOnly { parts.append(entry.item.conditional ? "if at UI" : "UI only") }
        parts.append(entry.ticked ? "ticked" : "not ticked")
        return parts.joined(separator: ", ")
    }
}

struct Checkbox: View {
    let isOn: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(isOn ? Color.accentColor : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(isOn ? Color.accentColor : Color.secondary, lineWidth: 1.5)
            )
            .overlay {
                Image(systemName: "checkmark")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.white)
                    .opacity(isOn ? 1 : 0)
                    .symbolEffect(.bounce, value: reduceMotion ? false : isOn)
            }
            .frame(width: 26, height: 26)
            .accessibilityHidden(true)
    }
}
