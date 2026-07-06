import Foundation

/// UI state for search submission, pagination, and error handling.
public enum SearchViewState<Entity> {
    /// No search has been submitted yet.
    case noSearch
    /// The first page is loading after a valid submission.
    case loadingFirstPage
    /// One or more items were loaded successfully.
    case loadedResults([Entity])
    /// The first page completed with no results.
    case loadedEmpty
    /// A later page is loading while existing items stay visible.
    case loadingNextPage([Entity])
    /// A later page failed while preserving already loaded items.
    case nextPageError(items: [Entity], error: Error)
    /// The first page failed.
    case initialSearchError(Error)
}
