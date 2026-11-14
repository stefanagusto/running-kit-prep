import XCTest
@testable import RunPrepCore

final class PlaceResolverTests: XCTestCase {
    func testUniversitasIndonesia() {
        XCTAssertEqual(PlaceResolver.place(location: "Universitas Indonesia"), .ui)
        XCTAssertEqual(PlaceResolver.place(location: "Universitas Indonesia Jalan Margonda"), .ui)
    }

    func testUIAsWholeWord() {
        XCTAssertEqual(PlaceResolver.place(location: "UI"), .ui)
        XCTAssertEqual(PlaceResolver.place(location: "Gedung UI, Depok"), .ui)
        XCTAssertEqual(PlaceResolver.place(location: "gedung ui"), .ui)
    }

    func testBuildingDoesNotMatchUI() {
        XCTAssertNil(PlaceResolver.place(location: "Building 5"))
        XCTAssertNil(PlaceResolver.place(location: "Guitar Hall"))
    }

    func testHome() {
        XCTAssertEqual(PlaceResolver.place(location: "Rumah"), .home)
        XCTAssertEqual(PlaceResolver.place(location: "home"), .home)
    }

    func testNilAndBlank() {
        XCTAssertNil(PlaceResolver.place(location: nil))
        XCTAssertNil(PlaceResolver.place(location: ""))
        XCTAssertNil(PlaceResolver.place(location: "   "))
    }

    func testUIBeatsHome() {
        XCTAssertEqual(PlaceResolver.place(location: "Home run at UI"), .ui)
    }

    func testDiacriticsAndCase() {
        let rules = PlaceRules(uiKeywords: ["Café Kampus"], homeKeywords: ["Maison"])
        XCTAssertEqual(PlaceResolver.place(location: "CAFE KAMPUS 2", rules: rules), .ui)
        XCTAssertEqual(PlaceResolver.place(location: "ma maison", rules: rules), .home)
    }

    func testCustomRulesReplaceDefaults() {
        let rules = PlaceRules(uiKeywords: ["Senayan"], homeKeywords: ["Kos"])
        XCTAssertEqual(PlaceResolver.place(location: "GBK Senayan", rules: rules), .ui)
        XCTAssertEqual(PlaceResolver.place(location: "kos", rules: rules), .home)
        XCTAssertNil(PlaceResolver.place(location: "Universitas Indonesia", rules: rules))
    }

    func testBlankKeywordsIgnored() {
        let rules = PlaceRules(uiKeywords: ["", "  "], homeKeywords: [""])
        XCTAssertNil(PlaceResolver.place(location: "Anywhere", rules: rules))
    }
}
