import XCTest
@testable import RunPrepCore

final class ItemSummaryTests: XCTestCase {
    private func rule(_ types: Set<SessionType>, uiOnly: Bool = false) -> ItemRule {
        ItemRule(id: UUID(), name: "X", groups: [.pack], appliesTo: types, uiOnly: uiOnly, sortOrder: 0)
    }

    func testAllSessions() {
        XCTAssertEqual(ItemSummary.text(for: rule([.normal, .long, .race])), "All sessions")
    }

    func testTypesInFixedOrder() {
        XCTAssertEqual(ItemSummary.text(for: rule([.race, .long])), "Long run \u{00B7} Race")
        XCTAssertEqual(ItemSummary.text(for: rule([.long])), "Long run")
        XCTAssertEqual(ItemSummary.text(for: rule([.normal, .long])), "Normal \u{00B7} Long run")
    }

    func testUiOnlySuffix() {
        XCTAssertEqual(
            ItemSummary.text(for: rule([.normal, .long], uiOnly: true)),
            "Normal \u{00B7} Long run \u{00B7} UI only"
        )
        XCTAssertEqual(ItemSummary.text(for: rule([.normal, .long, .race], uiOnly: true)), "All sessions \u{00B7} UI only")
    }
}
