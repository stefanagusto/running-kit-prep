import XCTest
@testable import RunPrepCore

final class ItemOrderingTests: XCTestCase {
    private let seed = SeedItems.all

    private func names(_ items: [ItemRule], _ group: ItemGroup) -> [String] {
        ItemOrdering.items(in: group, from: items).map(\.name)
    }

    func testMoveWithinPackKeepsChargeAndBringOrders() {
        // Banana (pack index 3) to the top.
        let moved = ItemOrdering.move(items: seed, in: .pack, from: IndexSet(integer: 3), to: 0)
        XCTAssertEqual(Array(names(moved, .pack).prefix(4)), ["Banana", "Energy gel", "Electrolyte", "Running cap"])
        XCTAssertEqual(names(moved, .charge), names(seed, .charge))
        XCTAssertEqual(names(moved, .bring), names(seed, .bring))
        let before = Dictionary(uniqueKeysWithValues: seed.map { ($0.id, $0.sortOrder) })
        for item in moved where !item.groups.contains(.pack) {
            XCTAssertEqual(item.sortOrder, before[item.id])
        }
    }

    func testMoveDownUsesDestinationBeforeTheMove() {
        // Energy gel (pack index 0) to the end: destination is the list count.
        let moved = ItemOrdering.move(items: seed, in: .pack, from: IndexSet(integer: 0), to: 8)
        XCTAssertEqual(names(moved, .pack).last, "Energy gel")
        XCTAssertEqual(names(moved, .pack).first, "Electrolyte")
    }

    func testMovingWatchInBringSwapsIntoTheSlotsBringUsed() {
        // Bring: flask, belt, watch, airpods, key, stnk. Watch to just after AirPods.
        let moved = ItemOrdering.move(items: seed, in: .bring, from: IndexSet(integer: 2), to: 4)
        XCTAssertEqual(names(moved, .bring), [
            "Soft flask", "Running belt", "AirPods", "Watch",
            "Motorbike key (kunci motor)", "STNK"
        ])
        // Watch and AirPods share their slots, so Charge shows the same swap.
        XCTAssertEqual(names(moved, .charge), ["AirPods", "Watch"])
        XCTAssertEqual(names(moved, .pack), names(seed, .pack))
    }

    func testNoDuplicateSortOrdersAndSameSlots() {
        let moved = ItemOrdering.move(items: seed, in: .pack, from: IndexSet(integer: 7), to: 1)
        let orders = moved.map(\.sortOrder)
        XCTAssertEqual(Set(orders).count, orders.count)
        XCTAssertEqual(orders.sorted(), seed.map(\.sortOrder).sorted())
        XCTAssertEqual(moved.map(\.id), seed.map(\.id))
    }

    func testOutOfRangeSourceChangesNothing() {
        XCTAssertEqual(ItemOrdering.move(items: seed, in: .charge, from: IndexSet(integer: 5), to: 0), seed)
    }

    func testNextSortOrder() {
        XCTAssertEqual(ItemOrdering.nextSortOrder(after: seed), 14)
        XCTAssertEqual(ItemOrdering.nextSortOrder(after: []), 0)
    }
}
