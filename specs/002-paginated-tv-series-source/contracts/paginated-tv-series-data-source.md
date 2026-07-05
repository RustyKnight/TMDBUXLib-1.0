# Contract: Paginated TV Series Data Source Public Interface

## Overview
This contract defines a TV-series-specific paginated data source backed by `TMDBClient.searchTV`.

## Swift Contract Shape (normative)
```swift
import TMDBLib

public enum PaginatedTVSeriesDataSourceError: Error {
    case missingSearchTerm
}

public protocol PaginatedTVSeriesDataSource: SearchablePaginatedDataSource
where Entity == TVSeriesListResult {
    init(
        tmdbClient: TMDBClient,
        language: String?,
        includeAdult: Bool?,
        firstAirDateYear: Int?
    )
}
```

## Behavioral Rules (normative)
1. `searchTerm` must be set to a non-empty, non-whitespace value before `nextPage()` or `refresh()` can succeed.
2. If retrieval is requested without a valid `searchTerm`, the call fails with `PaginatedTVSeriesDataSourceError.missingSearchTerm`.
3. Assigning/changing `searchTerm` resets pagination state to `.beforeFirstPage` and discards prior session progress/results.
4. Assigning/changing `searchTerm` does not trigger retrieval automatically.
5. `nextPage()` requests `TMDBClient.searchTV` with current term, current page index, and configured optional filters.
6. `refresh()` restarts from first page for current term using the same filter set.
7. Successful empty search results are valid `.page([])` outcomes, not failures.
8. When no further pages remain, retrieval returns `.noMorePages` and transitions state to `.noMorePage`.
9. Public API naming uses Swift conventions (camelCase, no underscores).

## Compatibility Notes
- Platform compatibility must remain aligned with package declarations in `Package.swift`.
- No additional package dependency is required beyond existing `TMDBLib` integration.

## Usage Notes
- Instantiate `TMDBPaginatedTVSeriesDataSource` with `TMDBClient` and optional filters, then set `searchTerm`.
- Call `try await nextPage()` to begin retrieval.
- Use `try await refresh()` to restart paging for the current term.
- Repeated `nextPage()` after exhaustion should remain stable and keep returning `.noMorePages`.
