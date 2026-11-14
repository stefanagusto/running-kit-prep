import XCTest
@testable import RunPrepCore

final class KitBuilderTests: XCTestCase {
    private func kit(_ type: SessionType, _ place: Place?) -> Kit {
        KitBuilder.kit(for: type, place: place, items: SeedItems.all)
    }

    private func names(_ kit: Kit, _ group: ItemGroup) -> [String] {
        kit.items(in: [group]).map(\.name)
    }

    private let charge = ["Watch", "AirPods"]
    private let bringBase = ["Soft flask", "Running belt", "Watch", "AirPods"]
    private let longPack = ["Energy gel", "Electrolyte", "Running cap", "Banana"]
    private let racePack = [
        "Energy gel", "Running cap", "Banana", "Sunglasses + contact lenses",
        "Uniqlo seamless jersey, shorts, underwear", "Socks and shoes", "Bib + magnets"
    ]

    func testNormalHome() {
        let k = kit(.normal, .home)
        XCTAssertEqual(names(k, .charge), charge)
        XCTAssertEqual(names(k, .pack), [])
        XCTAssertEqual(names(k, .bring), bringBase)
    }

    func testNormalUI() {
        let k = kit(.normal, .ui)
        XCTAssertEqual(names(k, .pack), [])
        XCTAssertEqual(names(k, .bring), bringBase + ["Motorbike key (kunci motor)", "STNK"])
        XCTAssertFalse(k.items.contains { $0.conditional })
    }

    func testNormalPlaceUnsetKeepsUIItemsAsConditional() {
        let k = kit(.normal, nil)
        XCTAssertEqual(names(k, .bring), bringBase + ["Motorbike key (kunci motor)", "STNK"])
        let conditional = k.items.filter(\.conditional).map(\.name)
        XCTAssertEqual(conditional, ["Motorbike key (kunci motor)", "STNK"])
    }

    func testLongHome() {
        let k = kit(.long, .home)
        XCTAssertEqual(names(k, .charge), charge)
        XCTAssertEqual(names(k, .pack), longPack)
        XCTAssertEqual(names(k, .bring), bringBase)
    }

    func testLongUI() {
        let k = kit(.long, .ui)
        XCTAssertEqual(names(k, .pack), longPack)
        XCTAssertEqual(names(k, .bring), bringBase + ["Motorbike key (kunci motor)", "STNK"])
    }

    func testRaceHasNoUIItemsWhateverThePlace() {
        for place in [nil, Place.ui, Place.home] {
            let k = kit(.race, place)
            XCTAssertEqual(names(k, .charge), charge)
            XCTAssertEqual(names(k, .pack), racePack)
            XCTAssertEqual(names(k, .bring), bringBase)
            XCTAssertFalse(k.items.contains { $0.conditional })
        }
    }

    func testRaceDropsUIOnlyItemEvenIfRuleIncludesRace() {
        let rule = ItemRule(
            id: UUID(), name: "Bike key", groups: [.bring],
            appliesTo: [.normal, .long, .race], uiOnly: true, sortOrder: 0
        )
        XCTAssertTrue(KitBuilder.kit(for: .race, place: .ui, items: [rule]).items.isEmpty)
        XCTAssertEqual(KitBuilder.kit(for: .long, place: .ui, items: [rule]).items.count, 1)
    }

    func testWatchAndAirPodsAppearTwice() {
        let k = kit(.normal, .home)
        for name in ["Watch", "AirPods"] {
            let groups = k.items.filter { $0.name == name }.map(\.group)
            XCTAssertEqual(groups, [.charge, .bring], name)
        }
    }

    func testOrderIsGroupThenSortOrder() {
        func rule(_ name: String, _ groups: Set<ItemGroup>, _ order: Int) -> ItemRule {
            ItemRule(id: UUID(), name: name, groups: groups, appliesTo: [.normal], uiOnly: false, sortOrder: order)
        }
        let items = [
            rule("B2", [.bring], 2), rule("P5", [.pack], 5), rule("B1", [.bring], 1),
            rule("C9", [.charge], 9), rule("P3", [.pack], 3)
        ]
        let k = KitBuilder.kit(for: .normal, place: .home, items: items)
        XCTAssertEqual(k.items.map(\.name), ["C9", "P3", "P5", "B1", "B2"])
    }

    func testItemsInFiltersByGroups() {
        let k = kit(.long, .home)
        XCTAssertEqual(k.items(in: [.charge, .pack]).map(\.name), charge + longPack)
        XCTAssertEqual(k.items(in: [.pack]).map(\.name), longPack)
        XCTAssertEqual(k.items(in: []), [])
        XCTAssertEqual(k.items(in: [.charge, .pack, .bring]), k.items)
    }

    func testEmptyItemListGivesEmptyKit() {
        XCTAssertTrue(KitBuilder.kit(for: .long, place: .ui, items: []).items.isEmpty)
    }
}
