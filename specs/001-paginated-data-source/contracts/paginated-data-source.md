# Contract: Paginated Data Source Public Interface

## Overview
This contract defines the library-facing pagination API for forward-only sequential page retrieval.

## Swift Contract Shape (normative)
```swift
public protocol PaginatedDataSource {
    associatedtype Entity

    var hasMorePages: Bool { get }
    var isLoading: Bool { get }
    var hasLoadedResults: Bool { get }

    func nextPage() async -> PageResult<Entity>
    func refresh() async -> PageResult<Entity>
}

public enum PageResult<Entity> {
    case page([Entity])
    case noMorePages
}
```

## Behavioral Rules (normative)
1. `nextPage()` returns the next sequential page only (no random-access API).
2. `hasMorePages` communicates whether additional page retrieval is possible.
3. `isLoading` reports whether a page request is currently in progress.
4. `hasLoadedResults` reports whether a load attempt (`nextPage()` or `refresh()`) has been made at least once.
5. When exhausted, `nextPage()` returns `.noMorePages` (not `.page` and not terminal error for this case).
6. Empty page payloads (`entities.isEmpty`) are valid `.page` results.
7. Page ordering must be preserved for all consecutive calls within a session.
8. `refresh()` resets pagination to the start and returns the newly loaded first-page result.

## Compatibility Notes
- API naming must follow Swift conventions (camelCase, no underscore separators).
- Contract must remain compatible with package target platforms declared in `Package.swift`.

## Usage Notes
- Consumers should loop while `hasMorePages` is `true`, or stop when `nextPage()` returns `.noMorePages`.
- `refresh()` ignores current pagination position and restarts from the first page.
- `isLoading` should be `true` only during an active `nextPage()` execution.
- `hasMorePages == false` with `hasLoadedResults == false` means no load has been attempted yet.
- `.page([])` is a valid successful outcome and must not be treated as terminal completion.
- Once exhausted, repeated `nextPage()` calls remain stable and continue returning `.noMorePages`.
