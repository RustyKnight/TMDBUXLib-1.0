# Data Model: Paginated TV Series Data Source

## Entity: PaginatedTVSeriesDataSource
- **Purpose**: Concrete `SearchablePaginatedDataSource` implementation for TMDB TV search pagination.
- **Core fields**:
  - `tmdbClient: TMDBClient`
  - `searchTerm: String?`
  - `language: String?`
  - `includeAdult: Bool?`
  - `firstAirDateYear: Int?`
  - `state: PaginationState`
  - `isLoading: Bool`
  - `nextPageIndex: Int` (1-based for TMDB API)
  - `lastKnownTotalPages: Int?`
- **Validation rules**:
  - `searchTerm` must be non-empty after trimming whitespace before any retrieval.
  - `nextPage()` and `refresh()` fail with `missingSearchTerm` when term is absent/blank.
  - Setting/changing `searchTerm` resets `state = .beforeFirstPage`, `nextPageIndex = 1`, and clears session progress.
  - `searchTerm` assignment never performs I/O.
  - `isLoading` is true only while request execution is active.

## Entity: TVSeriesSearchSession
- **Purpose**: Internal representation of active pagination progress for the current search term.
- **Fields**:
  - `term: String`
  - `nextPageIndex: Int`
  - `lastLoadedPage: Int?`
  - `totalPages: Int?`
- **Validation rules**:
  - Session is invalidated immediately when `searchTerm` changes.
  - `nextPageIndex` increments only after successful `.page(...)` response.
  - Session becomes exhausted when `lastLoadedPage >= totalPages`.

## Entity: TVSeriesPagePayload
- **Purpose**: API payload returned by TMDB and mapped into pagination outcomes.
- **Source type**: `Page<TVSeriesListResult>`
- **Key fields**:
  - `page: Int`
  - `results: [TVSeriesListResult]`
  - `totalPages: Int`
  - `totalResults: Int`
- **Validation rules**:
  - Empty `results` is valid and mapped to `.page([])` if page retrieval succeeds.
  - When next page would exceed `totalPages`, outcome is `.noMorePages`.

## Entity: PaginatedTVSeriesDataSourceError
- **Purpose**: Domain error surface for invalid retrieval preconditions.
- **Cases**:
  - `missingSearchTerm`
- **Validation rules**:
  - Must be thrown/returned consistently for both `nextPage()` and `refresh()` without a valid term.
  - Must remain distinguishable from transport/decoding errors propagated from `TMDBClient`.

## State Transitions
1. **Initial**: `state = .beforeFirstPage`, `nextPageIndex = 1`.
2. **MissingTermFailure**: Retrieval attempted with nil/blank term → `missingSearchTerm`, state unchanged.
3. **PageLoaded**: Retrieval succeeds with payload page; `state = .morePages` when more pages remain.
4. **Exhausted**: Retrieval determines no additional pages remain; return `.noMorePages`, `state = .noMorePage`.
5. **RefreshReset**: `refresh()` resets index/session then loads first page for current term.
6. **TermChanged**: Any term change invalidates prior session and returns to initial state.
