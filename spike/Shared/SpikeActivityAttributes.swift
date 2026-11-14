import ActivityKit

struct SpikeActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var ticked: Int
        var total: Int
    }

    var sessionTitle: String
}

enum SpikeShared {
    static let appGroup = "group.com.CHANGE-ME.runprep.spike"
    static let key = "spike.lastWrite"
}
