# Contract: Paginated Data Source Public Interface

## Overview
This contract defines the library-facing pagination API for forward-only sequential page retrieval.

## Swift Contract Shape (normative)
```swift
public protocol PaginatedDataSource {
    associatedtype Entity

    var hasMorePages: Bool { get }

    func nextPage() async -> PageResult<Entity>
}

public enum PageResult<Entity> {
    case page([Entity])
    case noMorePages
}
```

## Behavioral Rules (normative)
1. `nextPage()` returns the next sequential page only (no random-access API).
2. `hasMorePages` communicates whether additional page retrieval is possible.
3. When exhausted, `nextPage()` returns `.noMorePages` (not `.page` and not terminal error for this case).
4. Empty page payloads (`entities.isEmpty`) are valid `.page` results.
5. Page ordering must be preserved for all consecutive calls within a session.

## Compatibility Notes
- API naming must follow Swift conventions (camelCase, no underscore separators).
- Contract must remain compatible with package target platforms declared in `Package.swift`.

## Usage Notes
- Consumers should loop while `hasMorePages` is `true`, or stop when `nextPage()` returns `.noMorePages`.
- `.page([])` is a valid successful outcome and must not be treated as terminal completion.
- Once exhausted, repeated `nextPage()` calls remain stable and continue returning `.noMorePages`.
