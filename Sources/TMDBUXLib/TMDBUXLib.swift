/// TMDBUXLib public API entrypoint.
///
/// Pagination contract types exposed by this module:
/// - ``PaginatedDataSource``
/// - ``SearchablePaginatedDataSource``
/// - ``PaginatedTVSeriesDataSource``
/// - ``PaginatedMovieDataSource``
/// - ``PageResult``
///
/// Search view contract types exposed by this module:
/// - ``SearchViewState``
/// - ``SearchViewFactory``
/// - ``TVSeriesSearchViewFactory``
/// - ``SearchViewModeling``
/// - ``SearchViewModel``
/// - ``SearchView``
///
/// Concrete search-view implementations currently live under `SearchView/`,
/// with TV-series-specific defaults in `SearchView/TVSeries/`.
public enum TMDBUXLib {}

public extension TMDBUXLib {
    /// Public API usage note:
    /// Call `try await nextPage()` sequentially, use `try await refresh()` to restart from page one,
    /// and treat `.noMorePages` as terminal completion.
    static let paginationUsageNote = "Call try await nextPage() sequentially, use try await refresh() to restart, and stop at .noMorePages."

    /// Public API usage note:
    /// Bind `searchTerm`, call `submitSearch()`, and forward end-of-list events to
    /// `loadNextPageIfNeeded(currentItem:)` for paginated search UI behavior.
    static let searchViewUsageNote = "Bind searchTerm, call submitSearch(), and use loadNextPageIfNeeded(currentItem:) at list end."
}
