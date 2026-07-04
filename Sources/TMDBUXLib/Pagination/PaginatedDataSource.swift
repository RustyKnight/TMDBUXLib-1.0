/// Contract for forward-only paginated retrieval.
public protocol PaginatedDataSource {
    /// Entity type emitted by this data source.
    associatedtype Entity

    /// Indicates whether additional pages can currently be requested.
    var hasMorePages: Bool { get }
    /// Indicates whether a page request is currently in progress.
    var isLoading: Bool { get }
    /// Indicates whether any load attempt has been made.
    var hasLoadedResults: Bool { get }

    /// Loads and returns the next page in sequence, or throws if retrieval fails.
    func nextPage() async throws -> PageResult<Entity>
    /// Resets pagination to the start and returns the freshly loaded first page, or throws if retrieval fails.
    func refresh() async throws -> PageResult<Entity>
}

/// Result of a pagination request.
public enum PageResult<Entity> {
    /// A successful page payload.
    case page([Entity])
    /// Terminal state when no additional pages remain.
    case noMorePages
}
