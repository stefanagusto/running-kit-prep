import SwiftUI

/// Calendars grouped by account, with a search field. Used in the sheet
/// opened from the toolbar and in the "calendar not found" state.
struct CalendarPickerList: View {
    let options: [CalendarOption]
    let selectedId: String?
    let onChoose: (String) -> Void
    var footer: String?

    @State private var query = ""

    private var filtered: [CalendarOption] {
        let text = query.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return options }
        return options.filter {
            $0.title.localizedCaseInsensitiveContains(text) || $0.account.localizedCaseInsensitiveContains(text)
        }
    }

    private var accounts: [String] {
        var seen: [String] = []
        for option in filtered where !seen.contains(option.account) { seen.append(option.account) }
        return seen.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    var body: some View {
        List {
            ForEach(accounts, id: \.self) { account in
                Section(account) {
                    ForEach(filtered.filter { $0.account == account }) { option in
                        row(option)
                    }
                }
            }
            if let footer {
                Section { } footer: { Text(footer) }
            }
        }
        .searchable(text: $query, prompt: "Search calendars")
        .overlay {
            if filtered.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
    }

    private func row(_ option: CalendarOption) -> some View {
        Button {
            onChoose(option.id)
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(option.color)
                    .frame(width: 12, height: 12)
                    .accessibilityHidden(true)
                Text(option.title)
                    .foregroundStyle(.primary)
                Spacer()
                if option.id == selectedId {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .accessibilityLabel("\(option.title), \(option.account)")
        .accessibilityAddTraits(option.id == selectedId ? .isSelected : [])
    }
}

/// Sheet version with a title and a Done button.
struct CalendarPickerSheet: View {
    let options: [CalendarOption]
    let selectedId: String?
    let onChoose: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            CalendarPickerList(options: options, selectedId: selectedId) { id in
                onChoose(id)
                dismiss()
            }
            .navigationTitle("Training calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
