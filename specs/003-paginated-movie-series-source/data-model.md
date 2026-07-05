# Data Model: Paginated Movie Series Data Source

## Entity: PaginatedMovieSeriesDataSource
- **Purpose**: Concrete `PaginatedDataSource` implementation for TMDB movie search pagination.
- **Core fields**:
  - `tmdbClient: TMDBClient`
  - `searchTerm: String?`
  - `language: String?`
  - `region: String?`
  - `includeAdult: Bool?`
  - `firstAirDateYear: Int?`
  - `primaryReleaseYear: Int?`
  - `state: PaginationState`
  - `isLoading: Bool`
  - `nextPageIndex: Int` (1-based)
  - `lastKnownTotalPages: Int?`
- **Validation rules**:
  - `searchTerm` must be non-empty after trimming whitespace before retrieval.
  - `nextPage()` and `refresh()` fail with `missingSearchTerm` when term is absent/blank.
  - Setting/changing `searchTerm` resets `state = .beforeFirstPage`, `nextPageIndex = 1`, and clears prior paging progress.
  - `searchTerm` assignment never performs I/O.
  - `isLoading` is true only while request execution is active.

## Entity: MovieSearchSession
- **Purpose**: Internal representation of active pagination progress for one search term.
- **Fields**:
  - `term: String`
  - `nextPageIndex: Int`
  - `lastLoadedPage: Int?`
  - `totalPages: Int?`
- **Validation rules**:
  - Session is invalidated immediately when `searchTerm` changes.
  - `nextPageIndex` increments only after successful `.page(...)` response.
  - Session is exhausted when `lastLoadedPage >= totalPages`.

## Entity: MoviePagePayload
- **Purpose**: API payload returned by TMDB and mapped into pagination outcomes.
- **Source type**: `Page<MovieListResult>` (or equivalent TMDBLib movie page result type)
- **Key fields**:
  - `page: Int`
  - `results: [MovieListResult]`
  - `totalPages: Int`
  - `totalResults: Int`
- **Validation rules**:
  - Empty `results` is valid and mapped to `.page([])` when request succeeds.
  - When next page would exceed `totalPages`, outcome is `.noMorePages`.

## Entity: PaginatedMovieSeriesDataSourceError
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
