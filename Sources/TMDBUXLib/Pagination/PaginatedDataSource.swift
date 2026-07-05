/// Contract for forward-only paginated retrieval.
public protocol PaginatedDataSource {
    /// Entity type emitted by this data source.
    associatedtype Entity

    /// Indicates the current pagination state.
    var state: PaginationState { get }
    /// Indicates whether a page request is currently in progress.
    var isLoading: Bool { get }

    /// Loads and returns the next page in sequence, or throws if retrieval fails.
    func nextPage() async throws -> PageResult<Entity>
    /// Resets pagination to the start and returns the freshly loaded first page, or throws if retrieval fails.
    func refresh() async throws -> PageResult<Entity>
}

/// Contract for paginated retrieval filtered by an optional search term.
public protocol SearchablePaginatedDataSource: PaginatedDataSource {
    /// Current search term used to filter paginated results.
    var searchTerm: String? { get set }
}

/// Current state of pagination progress.
public enum PaginationState {
    /// No page has been loaded yet.
    case beforeFirstPage
    /// Additional pages are available.
    case morePages
    /// The last page has been loaded and no additional pages are available.
    case noMorePage
}

/// Result of a pagination request.
public enum PageResult<Entity> {
    /// A successful page payload.
    case page([Entity])
    /// Terminal state when no additional pages remain.
    case noMorePages
}
