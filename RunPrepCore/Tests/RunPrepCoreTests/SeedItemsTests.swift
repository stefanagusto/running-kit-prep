import XCTest
@testable import RunPrepCore

final class SeedItemsTests: XCTestCase {
    private struct Row {
        let name: String
        let appliesTo: Set<SessionType>
        let groups: Set<ItemGroup>
        let uiOnly: Bool
    }

    // PRD section 6, in table order.
    private let table: [Row] = [
        Row(name: "Soft flask", appliesTo: [.normal, .long, .race], groups: [.bring], uiOnly: false),
        Row(name: "Running belt", appliesTo: [.normal, .long, .race], groups: [.bring], uiOnly: false),
        Row(name: "Watch", appliesTo: [.normal, .long, .race], groups: [.charge, .bring], uiOnly: false),
        Row(name: "AirPods", appliesTo: [.normal, .long, .race], groups: [.charge, .bring], uiOnly: false),
        Row(name: "Motorbike key (kunci motor)", appliesTo: [.normal, .long], groups: [.bring], uiOnly: true),
        Row(name: "STNK", appliesTo: [.normal, .long], groups: [.bring], uiOnly: true),
        Row(name: "Energy gel", appliesTo: [.long, .race], groups: [.pack], uiOnly: false),
        Row(name: "Electrolyte", appliesTo: [.long], groups: [.pack], uiOnly: false),
        Row(name: "Running cap", appliesTo: [.long, .race], groups: [.pack], uiOnly: false),
        Row(name: "Banana", appliesTo: [.long, .race], groups: [.pack], uiOnly: false),
        Row(name: "Sunglasses + contact lenses", appliesTo: [.race], groups: [.pack], uiOnly: false),
        Row(name: "Uniqlo seamless jersey, shorts, underwear", appliesTo: [.race], groups: [.pack], uiOnly: false),
        Row(name: "Socks and shoes", appliesTo: [.race], groups: [.pack], uiOnly: false),
        Row(name: "Bib + magnets", appliesTo: [.race], groups: [.pack], uiOnly: false)
    ]

    func testHasFourteenItems() {
        XCTAssertEqual(SeedItems.all.count, 14)
    }

    func testIdsAreUnique() {
        XCTAssertEqual(Set(SeedItems.all.map(\.id)).count, 14)
    }

    func testNamesAreUnique() {
        XCTAssertEqual(Set(SeedItems.all.map(\.name)).count, 14)
    }

    func testSortOrderIsZeroThroughThirteen() {
        XCTAssertEqual(SeedItems.all.map(\.sortOrder), Array(0...13))
    }

    func testEveryRowMatchesTheTable() {
        XCTAssertEqual(SeedItems.all.count, table.count)
        for (item, row) in zip(SeedItems.all, table) {
            XCTAssertEqual(item.name, row.name)
            XCTAssertEqual(item.appliesTo, row.appliesTo, row.name)
            XCTAssertEqual(item.groups, row.groups, row.name)
            XCTAssertEqual(item.uiOnly, row.uiOnly, row.name)
        }
    }

    func testIdsAreFixed() {
        XCTAssertEqual(SeedItems.all.first?.id.uuidString, "5EED0001-0000-4000-8000-000000000001")
        XCTAssertEqual(SeedItems.all.last?.id.uuidString, "5EED000E-0000-4000-8000-00000000000E")
    }

    func testEveryItemHasAGroupAndASessionType() {
        for item in SeedItems.all {
            XCTAssertFalse(item.groups.isEmpty, item.name)
            XCTAssertFalse(item.appliesTo.isEmpty, item.name)
        }
    }
}
