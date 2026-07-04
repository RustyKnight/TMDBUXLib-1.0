# Quickstart: Validate Paginated Data Source

## Prerequisites
- Swift toolchain supporting `swift-tools-version: 6.3`
- macOS environment with package dependencies resolvable

## Setup
From repository root:

```bash
swift package resolve
```

## Validation Scenario 1: Sequential page retrieval (P1)
1. Run `PaginatedDataSourceSequentialTests` and `PaginatedDataSourceOrderingTests`.
2. Call `try await nextPage()` repeatedly for at least three pages in fixture-backed tests.
3. Verify outcomes are `.page(...)` in sequence and entities are not duplicated.

Expected outcome:
- Sequence is preserved across consecutive reads (SC-001, SC-004).

## Validation Scenario 2: Exhaustion handling (P2)
1. Run `PaginatedDataSourceCompletionTests` and `PaginatedDataSourceHasMorePagesTests`.
2. Consume all pages from a finite fixture.
3. Call `try await nextPage()` additional times after exhaustion.
4. Observe `isLoading` before and after each request.
5. Verify `hasLoadedResults` before the first request and after the first request.

Expected outcome:
- Extra request returns `.noMorePages` and remains distinguishable from `.page(...)` (SC-002).
- `isLoading` is `false` when no request is actively running.
- `hasLoadedResults` is `false` before the first request and `true` after a request attempt.

## Validation Scenario 3: Empty-but-valid page (P3)
1. Run `PaginatedDataSourceEmptyPageTests`.
2. Configure one page with zero entities.
3. Retrieve that page with `try await nextPage()`.

Expected outcome:
- `.page([])` is treated as success, not failure.
- Pagination continues to subsequent pages after an empty payload.

## Validation Scenario 4: Refresh behavior
1. Run `PaginatedDataSourceRefreshTests`.
2. Consume one or more pages to change pagination position.
3. Call `try await refresh()`.

Expected outcome:
- `refresh()` returns first-page results.
- Subsequent `nextPage()` continues from the page after refreshed first-page results.

## Run Validation
```bash
swift test
```

Expected outcome:
- Swift Testing suite passes with contract behavior matching:
  - [data-model.md](./data-model.md)
  - [contracts/paginated-data-source.md](./contracts/paginated-data-source.md)
