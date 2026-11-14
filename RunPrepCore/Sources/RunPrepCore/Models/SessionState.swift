public struct SessionState: Equatable, Sendable {
    public var completed: Bool

    public init(completed: Bool = false) {
        self.completed = completed
    }
}
