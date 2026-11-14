import Foundation

/// The 14 starter items from PRD section 6. The ids are fixed so tests and
/// future seed migrations can refer to them.
public enum SeedItems {
    public static let all: [ItemRule] = [
        row("5EED0001-0000-4000-8000-000000000001", "Soft flask", [.bring], [.normal, .long, .race]),
        row("5EED0002-0000-4000-8000-000000000002", "Running belt", [.bring], [.normal, .long, .race]),
        row("5EED0003-0000-4000-8000-000000000003", "Watch", [.charge, .bring], [.normal, .long, .race]),
        row("5EED0004-0000-4000-8000-000000000004", "AirPods", [.charge, .bring], [.normal, .long, .race]),
        row("5EED0005-0000-4000-8000-000000000005", "Motorbike key (kunci motor)", [.bring], [.normal, .long], uiOnly: true),
        row("5EED0006-0000-4000-8000-000000000006", "STNK", [.bring], [.normal, .long], uiOnly: true),
        row("5EED0007-0000-4000-8000-000000000007", "Energy gel", [.pack], [.long, .race]),
        row("5EED0008-0000-4000-8000-000000000008", "Electrolyte", [.pack], [.long]),
        row("5EED0009-0000-4000-8000-000000000009", "Running cap", [.pack], [.long, .race]),
        row("5EED000A-0000-4000-8000-00000000000A", "Banana", [.pack], [.long, .race]),
        row("5EED000B-0000-4000-8000-00000000000B", "Sunglasses + contact lenses", [.pack], [.race]),
        row("5EED000C-0000-4000-8000-00000000000C", "Uniqlo seamless jersey, shorts, underwear", [.pack], [.race]),
        row("5EED000D-0000-4000-8000-00000000000D", "Socks and shoes", [.pack], [.race]),
        row("5EED000E-0000-4000-8000-00000000000E", "Bib + magnets", [.pack], [.race])
    ].enumerated().map { index, rule in
        var rule = rule
        rule.sortOrder = index
        return rule
    }

    private static func row(
        _ id: String,
        _ name: String,
        _ groups: Set<ItemGroup>,
        _ appliesTo: Set<SessionType>,
        uiOnly: Bool = false
    ) -> ItemRule {
        ItemRule(
            id: UUID(uuidString: id)!,
            name: name,
            groups: groups,
            appliesTo: appliesTo,
            uiOnly: uiOnly,
            sortOrder: 0
        )
    }
}
