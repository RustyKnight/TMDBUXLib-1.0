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
2. Call `nextPage()` repeatedly for at least three pages in fixture-backed tests.
3. Verify outcomes are `.page(...)` in sequence and entities are not duplicated.

Expected outcome:
- Sequence is preserved across consecutive reads (SC-001, SC-004).

## Validation Scenario 2: Exhaustion handling (P2)
1. Run `PaginatedDataSourceCompletionTests` and `PaginatedDataSourceHasMorePagesTests`.
2. Consume all pages from a finite fixture.
3. Call `nextPage()` additional times after exhaustion.

Expected outcome:
- Extra request returns `.noMorePages` and remains distinguishable from `.page(...)` (SC-002).

## Validation Scenario 3: Empty-but-valid page (P3)
1. Run `PaginatedDataSourceEmptyPageTests`.
2. Configure one page with zero entities.
3. Retrieve that page with `nextPage()`.

Expected outcome:
- `.page([])` is treated as success, not failure.
- Pagination continues to subsequent pages after an empty payload.

## Run Validation
```bash
swift test
```

Expected outcome:
- Swift Testing suite passes with contract behavior matching:
  - [data-model.md](./data-model.md)
  - [contracts/paginated-data-source.md](./contracts/paginated-data-source.md)
