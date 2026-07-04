/// TMDBUXLib public API entrypoint.
///
/// Pagination contract types exposed by this module:
/// - ``PaginatedDataSource``
/// - ``PageResult``
public enum TMDBUXLib {}

public extension TMDBUXLib {
    /// Public API usage note:
    /// Call `nextPage()` sequentially and treat `.noMorePages` as terminal completion.
    static let paginationUsageNote = "Call nextPage() sequentially until .noMorePages."
}
