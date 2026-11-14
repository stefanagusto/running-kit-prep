import RunPrepCore
import SwiftData
import SwiftUI

struct ChecklistView: View {
    let session: Session
    let sync: SyncCoordinator
    @Query private var records: [SessionStateRecord]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(session: Session, sync: SyncCoordinator) {
        self.session = session
        self.sync = sync
        let key = session.key
        _records = Query(filter: #Predicate<SessionStateRecord> { $0.sessionKey == key })
    }

    private var kit: Kit { KitBuilder.kit(for: session.type, place: session.place, items: SeedItems.all) }
    private var ticked: Set<String> { Set(records.first?.checkedItemIds ?? []) }
    private var counts: (done: Int, total: Int) { Checklist.progress(kit: kit, ticked: ticked) }
    private var complete: Bool { Checklist.isComplete(kit: kit, ticked: ticked) }

    private var nextItem: KitItem? {
        kit.items.first { !ticked.contains(Checklist.tickKey($0)) }
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                headerSection
                ForEach(ItemGroup.allCases, id: \.self) { group in
                    groupSection(group)
                }
            }
            .safeAreaInset(edge: .bottom) { bottomBar(proxy) }
        }
        .navigationTitle("Kit check")
        .navigationBarTitleDisplayMode(.large)
        .sensoryFeedback(trigger: complete) { _, new in new ? .success : nil }
    }

    private var headerSection: some View {
        Section {
            ChecklistSubline(session: session, setPlace: setPlace)
                .clearRow()
            if session.placeIsMissing {
                PlacePrompt(session: session, select: setPlace)
                    .padding(16)
                    .foregroundStyle(.white)
                    .background(PlacePicker.cobalt, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .clearRow()
            }
            ChecklistProgressHeader(
                done: counts.done,
                total: counts.total,
                segments: kit.items.map { ticked.contains(Checklist.tickKey($0)) }
            )
            .clearRow()
        }
    }

    @ViewBuilder
    private func groupSection(_ group: ItemGroup) -> some View {
        let items = kit.items(in: [group])
        if !items.isEmpty {
            let done = items.filter { ticked.contains(Checklist.tickKey($0)) }.count
            Section {
                ForEach(items.map(entry)) { entry in
                    ChecklistRow(entry: entry) { toggle(entry.item) }
                }
            } header: {
                Text("\(group.title) \u{00B7} \(done) of \(items.count)")
                    .font(.subheadline.weight(.semibold))
                    .textCase(nil)
            }
        }
    }

    @ViewBuilder
    private func bottomBar(_ proxy: ScrollViewProxy) -> some View {
        if complete {
            DoneBar { dismiss() }
        } else if counts.total > 0 {
            KitBar(done: counts.done, total: counts.total, nextName: nextItem?.name) {
                guard let next = nextItem else { return }
                withAnimation(reduceMotion ? nil : .easeInOut) {
                    proxy.scrollTo(Checklist.tickKey(next), anchor: .center)
                }
            }
        }
    }

    private func entry(_ item: KitItem) -> ChecklistEntry {
        let rule = SeedItems.all.first { $0.id == item.id }
        return ChecklistEntry(
            item: item,
            uiOnly: rule?.uiOnly == true,
            ticked: ticked.contains(Checklist.tickKey(item))
        )
    }

    private func toggle(_ item: KitItem) {
        withAnimation(reduceMotion ? nil : .snappy) {
            sync.tick(Checklist.tickKey(item), session: session, kit: kit)
        }
    }

    private func setPlace(_ place: Place) {
        Task { await sync.setPlace(place, for: session.key) }
    }
}

private extension View {
    func clearRow() -> some View {
        listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
    }
}
