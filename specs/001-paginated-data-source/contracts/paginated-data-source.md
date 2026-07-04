# Contract: Paginated Data Source Public Interface

## Overview
This contract defines the library-facing pagination API for forward-only sequential page retrieval.

## Swift Contract Shape (normative)
```swift
public protocol PaginatedDataSource {
    associatedtype Entity

    var state: PaginationState { get }
    var isLoading: Bool { get }

    func nextPage() async throws -> PageResult<Entity>
    func refresh() async throws -> PageResult<Entity>
}

public enum PaginationState {
    case beforeFirstPage
    case morePages
    case noMorePage
}

public enum PageResult<Entity> {
    case page([Entity])
    case noMorePages
}
```

## Behavioral Rules (normative)
1. `nextPage()` returns the next sequential page only (no random-access API) and may throw retrieval errors.
2. `state` communicates pagination progress (`beforeFirstPage`, `morePages`, `noMorePage`).
3. `isLoading` reports whether a page request is currently in progress.
4. Before any load attempt, `state` is `.beforeFirstPage`.
5. While additional pages remain, `state` is `.morePages`.
6. After the last page is loaded (or when no pages exist after a load attempt), `state` is `.noMorePage`.
7. When exhausted, `nextPage()` returns `.noMorePages` (not `.page` and not terminal error for this case).
8. Empty page payloads (`entities.isEmpty`) are valid `.page` results.
9. Page ordering must be preserved for all consecutive calls within a session.
10. `refresh()` resets pagination to the start, returns the newly loaded first-page result, and may throw retrieval errors.

## Compatibility Notes
- API naming must follow Swift conventions (camelCase, no underscore separators).
- Contract must remain compatible with package target platforms declared in `Package.swift`.

## Usage Notes
- Consumers can inspect `state` before loading and stop when `try await nextPage()` returns `.noMorePages`.
- `try await refresh()` ignores current pagination position and restarts from the first page.
- `isLoading` should be `true` only during an active `nextPage()` execution.
- `state == .beforeFirstPage` means no load has been attempted yet.
- `.page([])` is a valid successful outcome and must not be treated as terminal completion.
- Once exhausted, repeated `nextPage()` calls remain stable and continue returning `.noMorePages`.
