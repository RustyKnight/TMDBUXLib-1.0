# Contract: Paginated Movie Series Data Source Public Interface

## Overview
This contract defines a movie-search-specific paginated data source backed by `TMDBClient.searchMovies`.

## Swift Contract Shape (normative)
```swift
import TMDBLib

public enum PaginatedMovieSeriesDataSourceError: Error {
    case missingSearchTerm
}

public protocol PaginatedMovieSeriesDataSource: PaginatedDataSource
where Entity == MovieListResult {
    init(
        tmdbClient: TMDBClient,
        language: String?,
        region: String?,
        includeAdult: Bool?,
        firstAirDateYear: Int?,
        primaryReleaseYear: Int?
    )

    var searchTerm: String? { get set }
}
```

## Behavioral Rules (normative)
1. `searchTerm` must be set to a non-empty, non-whitespace value before `nextPage()` or `refresh()` can succeed.
2. If retrieval is requested without a valid `searchTerm`, the call fails with `PaginatedMovieSeriesDataSourceError.missingSearchTerm`.
3. Assigning/changing `searchTerm` resets pagination state to `.beforeFirstPage` and discards prior session progress/results.
4. Assigning/changing `searchTerm` does not trigger retrieval automatically.
5. `nextPage()` requests `TMDBClient.searchMovies` with current term, current page index, and configured optional filters.
   - `firstAirDateYear` is forwarded through the TMDB `year` query parameter.
6. `refresh()` restarts from first page for current term using the same filter set.
7. Successful empty search results are valid `.page([])` outcomes, not failures.
8. When no further pages remain, retrieval returns `.noMorePages` and transitions state to `.noMorePage`.
9. Public API naming uses Swift conventions (camelCase, no underscores).

## Compatibility Notes
- Platform compatibility remains aligned with `Package.swift`.
- No additional package dependency is required beyond existing `TMDBLib` integration.

## Usage Notes
- Instantiate `TMDBPaginatedMovieSeriesDataSource` with `TMDBClient` and optional filters, then set `searchTerm`.
- Call `try await nextPage()` to begin retrieval.
- Use `try await refresh()` to restart paging for the current term.
- Repeated `nextPage()` after exhaustion should remain stable and keep returning `.noMorePages`.
