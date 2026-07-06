# Quickstart: Validate Search View UI

## Prerequisites
- Swift toolchain supporting `swift-tools-version: 6.3`
- Package dependencies resolved (`TMDBLib`, `ImageCacheLib`)
- Deterministic searchable paginated source doubles and view-factory stubs in test target
- A concrete `TMDBClient` instance available for `SearchView` construction
- Concrete TV-series factory example: `Sources/TMDBUXLib/SearchView/TVSeries/TVSeriesSearchViewFactory.swift`

## Setup
From repository root:

```bash
swift package resolve
```

## Wiring `SearchView`
1. Create/configure a `TMDBClient`.
2. Construct `SearchView` with `viewModel`, `factory`, and `tmdbClient`.
3. Access the shared client in child views with `@Environment(\.tmdbClient)`.

## Validation Scenario 1: Initial/valid search flow (P1)
1. Start with empty UI (`noSearch`).
2. Enter a valid term (for example `"Batman"`).
3. Trigger `submitSearch()`.

Expected outcome:
- Previous results are cleared before first-page load.
- State transitions to `loadingFirstPage`.
- Completion transitions to either `loadedResults` or `loadedEmpty` per payload.
- References: [data-model.md](./data-model.md), [contracts/search-view-ui-contract.md](./contracts/search-view-ui-contract.md)

## Validation Scenario 2: Empty/missing term guard (P1)
1. Keep term nil/empty/whitespace.
2. Trigger `submitSearch()`.

Expected outcome:
- No retrieval request is sent to source.
- Current UI state remains unchanged (no loading transition).

## Validation Scenario 3: First-page and next-page errors (P1/P2)
1. Configure source to fail initial page.
2. Run valid search.
3. Configure source to succeed first page, then fail next page.
4. Trigger pagination at list end.

Expected outcome:
- Initial failure maps to `initialSearchError`.
- Next-page failure maps to `nextPageError` while preserving already visible items.

## Validation Scenario 4: Pagination append + terminal behavior (P2)
1. Configure multi-page fixture with deterministic ordering.
2. Run valid search and scroll to list end repeatedly.
3. Continue after source indicates no additional pages.

Expected outcome:
- Each successful next page appends in order.
- End-of-list loading indicator appears only during next-page load.
- No request is made after exhaustion.

## Validation Scenario 5: Single item selection semantics (P3)
1. Run search with multiple items.
2. Select one row, then select another.

Expected outcome:
- Only one item is selected at any time.
- Selected value is emitted as exact `Entity` from source results.

## Run Validation
```bash
swift test
```

Expected outcome:
- Test suite passes with behavior matching:
  - [data-model.md](./data-model.md)
  - [contracts/search-view-ui-contract.md](./contracts/search-view-ui-contract.md)

## Implementation Validation Notes
- Executed command:
  ```bash
  swift test
  ```
- Latest result (2026-07-06): **PASS** (`52 tests passed`).
- Search View state-machine and pagination paths validated by:
  - `SearchViewModelSubmitSearchTests`
  - `SearchViewModelErrorGuardTests`
  - `SearchViewModelPaginationTests`
  - `SearchViewModelPaginationErrorTests`
  - `SearchViewModelSelectionTests`
