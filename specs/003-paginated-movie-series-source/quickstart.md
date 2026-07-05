# Quickstart: Validate Paginated Movie Series Data Source

## Prerequisites
- Swift toolchain supporting `swift-tools-version: 6.3`
- Resolved package dependencies (`TMDBLib`, `ImageCacheLib`)
- Deterministic TMDB movie-search doubles/spies in test target

## Setup
From repository root:

```bash
swift package resolve
```

## Validation Scenario 1: Missing search term enforcement (P1)
1. Instantiate the movie paginated data source with no `searchTerm`.
2. Invoke `try await nextPage()`.
3. Invoke `try await refresh()`.

Expected outcome:
- Both retrieval attempts fail with `missingSearchTerm` (SC-001).

## Validation Scenario 2: First page and sequential retrieval (P1)
1. Set a valid `searchTerm` (for example `"Star Wars"`).
2. Invoke `try await nextPage()` repeatedly against a deterministic multi-page fixture.
3. Validate returned pages follow increasing page order and preserve entity ordering.

Expected outcome:
- First call returns first page for term.
- Subsequent calls return next pages in order until exhaustion.
- Exhausted sequence returns `.noMorePages`.

## Validation Scenario 3: Search term reset behavior (P2)
1. Load one or more pages for initial term.
2. Change `searchTerm` to a different valid value.
3. Inspect pagination state and invoke `try await nextPage()`.

Expected outcome:
- State resets to `.beforeFirstPage` on term change.
- Next retrieval starts from page 1 for new term and prior session is discarded (SC-002, SC-003).

## Validation Scenario 4: Optional filter forwarding (P3)
1. Initialize source with each optional filter combination:
   - `language`
   - `region`
   - `includeAdult`
   - `firstAirDateYear`
   - `primaryReleaseYear`
2. Execute `nextPage()` and `refresh()` using deterministic client spy assertions.

Expected outcome:
- Retrieval remains successful with a valid term.
- Filter values are forwarded on every TMDB search request (SC-004).

## Run Validation
```bash
swift test --filter PaginatedMovieSeriesDataSource
swift test
```

Expected outcome:
- Test suite passes with behavior matching:
  - [data-model.md](./data-model.md)
  - [contracts/paginated-movie-series-data-source.md](./contracts/paginated-movie-series-data-source.md)
