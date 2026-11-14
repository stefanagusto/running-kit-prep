import XCTest
@testable import RunPrepCore

final class ChecklistProgressTests: XCTestCase {
    private func kit(_ type: SessionType, _ place: Place?) -> Kit {
        KitBuilder.kit(for: type, place: place, items: SeedItems.all)
    }

    private func keys(_ kit: Kit, where match: (KitItem) -> Bool = { _ in true }) -> Set<String> {
        Set(kit.items.filter(match).map(Checklist.tickKey))
    }

    func testKeyFormat() {
        let item = KitItem(
            id: UUID(uuidString: "5EED0003-0000-4000-8000-000000000003")!,
            name: "Watch", group: .charge, conditional: false
        )
        XCTAssertEqual(Checklist.tickKey(item), "5EED0003-0000-4000-8000-000000000003:charge")
    }

    func testWatchTickedSeparatelyPerGroup() {
        let k = kit(.normal, .home)
        let chargeWatch = k.items.first { $0.name == "Watch" && $0.group == .charge }!
        let bringWatch = k.items.first { $0.name == "Watch" && $0.group == .bring }!
        XCTAssertNotEqual(Checklist.tickKey(chargeWatch), Checklist.tickKey(bringWatch))
        let ticked: Set<String> = [Checklist.tickKey(chargeWatch)]
        XCTAssertEqual(Checklist.progress(kit: k, ticked: ticked).done, 1)
    }

    func testProgressCounts() {
        let k = kit(.normal, .home)
        let p = Checklist.progress(kit: k, ticked: [])
        XCTAssertEqual(p.done, 0)
        XCTAssertEqual(p.total, 6)
    }

    func testStaleKeysIgnored() {
        let k = kit(.normal, .home)
        let ticked: Set<String> = ["nonsense:pack", "5EED0006-0000-4000-8000-000000000006:bring"]
        XCTAssertEqual(Checklist.progress(kit: k, ticked: ticked).done, 0)
    }

    func testCompletion() {
        let k = kit(.normal, .home)
        XCTAssertFalse(Checklist.isComplete(kit: k, ticked: []))
        var ticked = keys(k)
        XCTAssertTrue(Checklist.isComplete(kit: k, ticked: ticked))
        ticked.remove(Checklist.tickKey(k.items[0]))
        XCTAssertFalse(Checklist.isComplete(kit: k, ticked: ticked))
    }

    func testEmptyKitNeverComplete() {
        XCTAssertFalse(Checklist.isComplete(kit: Kit(items: []), ticked: []))
    }

    func testPlaceChangeFromUIToHomeDropsUIItems() {
        let ui = kit(.normal, .ui)
        let ticked = keys(ui)
        let before = Checklist.progress(kit: ui, ticked: ticked)
        XCTAssertEqual(before.done, 8)
        XCTAssertEqual(before.total, 8)
        let home = kit(.normal, .home)
        let p = Checklist.progress(kit: home, ticked: ticked)
        XCTAssertEqual(p.total, 6)
        XCTAssertEqual(p.done, 6)
        XCTAssertTrue(Checklist.isComplete(kit: home, ticked: ticked))
    }
}
