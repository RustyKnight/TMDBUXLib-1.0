public protocol PaginatedDataSource {
    associatedtype Entity

    var hasMorePages: Bool { get }

    func nextPage() async -> PageResult<Entity>
}

public enum PageResult<Entity> {
    case page([Entity])
    case noMorePages
}
