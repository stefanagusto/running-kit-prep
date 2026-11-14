import Foundation

/// Tick keys and progress for the kit check. Pure.
public enum Checklist {
    /// "<item uuid>:<group raw>". Watch and AirPods sit in two groups, so each group has its own key.
    public static func tickKey(_ item: KitItem) -> String {
        "\(item.id.uuidString):\(item.group.rawValue)"
    }

    /// Counts only keys that belong to the kit now. Stale keys (a place change removed the item) are ignored.
    public static func progress(kit: Kit, ticked: Set<String>) -> (done: Int, total: Int) {
        let done = kit.items.filter { ticked.contains(tickKey($0)) }.count
        return (done, kit.items.count)
    }

    /// An empty kit is never complete.
    public static func isComplete(kit: Kit, ticked: Set<String>) -> Bool {
        let counts = progress(kit: kit, ticked: ticked)
        return counts.total > 0 && counts.done == counts.total
    }
}
