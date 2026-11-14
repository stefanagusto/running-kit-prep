import Foundation

public enum KitBuilder {
    public static func kit(for type: SessionType, place: Place?, items: [ItemRule]) -> Kit {
        var entries: [(item: KitItem, sortOrder: Int)] = []
        for rule in items where rule.appliesTo.contains(type) {
            var conditional = false
            if rule.uiOnly {
                if type == .race { continue }
                switch place {
                case .ui: break
                case .home: continue
                case .none: conditional = true
                }
            }
            for group in rule.groups {
                let item = KitItem(id: rule.id, name: rule.name, group: group, conditional: conditional)
                entries.append((item, rule.sortOrder))
            }
        }
        entries.sort { lhs, rhs in
            if rank(lhs.item.group) != rank(rhs.item.group) {
                return rank(lhs.item.group) < rank(rhs.item.group)
            }
            if lhs.sortOrder != rhs.sortOrder { return lhs.sortOrder < rhs.sortOrder }
            return lhs.item.name < rhs.item.name
        }
        return Kit(items: entries.map { $0.item })
    }

    private static func rank(_ group: ItemGroup) -> Int {
        ItemGroup.allCases.firstIndex(of: group) ?? 0
    }
}
