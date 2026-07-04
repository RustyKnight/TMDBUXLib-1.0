# Phase 0 Research: Paginated TV Series Data Source

## Decision 1: Use `TMDBClient.searchTV` as the only page-fetch primitive
- **Decision**: Implement retrieval via `TMDBClient.searchTV(query:page:language:includeAdult:firstAirDateYear:progress:)`.
- **Rationale**: It directly matches required feature behavior (search term + optional filters + explicit page index) and returns `Page<TVSeriesListResult>`.
- **Alternatives considered**:
  - `searchTVWithAllPages(...)`: rejected because it bypasses caller-driven pagination.
  - Custom endpoint wrapper: rejected as unnecessary abstraction for this scope.

## Decision 2: Treat missing/blank `searchTerm` as explicit domain error
- **Decision**: Return a dedicated `missingSearchTerm` failure for `nextPage()` and `refresh()` when `searchTerm` is nil/blank.
- **Rationale**: Required by FR-001/FR-002 and source spec assumptions for predictable consumer behavior.
- **Alternatives considered**:
  - Silently no-op when search term missing: rejected because it hides invalid usage.
  - Generic transport error: rejected due to weak diagnosability.

## Decision 3: Search-term mutation resets session state only
- **Decision**: Changing `searchTerm` resets pagination state to `.beforeFirstPage`, clears loaded results/session progress, and does not fetch automatically.
- **Rationale**: Directly satisfies FR-003, FR-006, and FR-007.
- **Alternatives considered**:
  - Auto-fetch first page on assignment: rejected because spec requires explicit `nextPage()`/`refresh()` trigger.
  - Keep old pages when term changes: rejected because it mixes result sets.

## Decision 4: Keep filters initialization-scoped and reapplied on every request
- **Decision**: `language`, `includeAdult`, and `firstAirDateYear` are optional initialization parameters that are passed to every `searchTV` call.
- **Rationale**: Matches source plan and ensures consistent query semantics across page traversal.
- **Alternatives considered**:
  - Mutable per-request filters: rejected to avoid state ambiguity and accidental cross-page inconsistency.
  - Ignoring filters after first page: rejected because it would break result continuity.

## Decision 5: Validate behavior with deterministic Swift Testing doubles
- **Decision**: Use Swift Testing with deterministic doubles/spies for TMDB search behavior, including empty pages and exhaustion.
- **Rationale**: Provides stable, repeatable verification of pagination and reset semantics without live-network flakiness.
- **Alternatives considered**:
  - Live TMDB integration-only tests: rejected for nondeterminism and execution cost.
  - XCTest-only approach: rejected in favor of project preference for Swift Testing.

## Validation Notes (2026-07-05)
- Implemented `TMDBPaginatedTVSeriesDataSource` with:
  - explicit `missingSearchTerm` validation for `nextPage()`/`refresh()`
  - deterministic term-change and refresh reset behavior
  - request forwarding for `language`, `includeAdult`, `firstAirDateYear`
  - `.noMorePages` terminal behavior and successful empty-page mapping
- Added deterministic TMDB search test doubles and fixtures:
  - `TMDBSearchTVClientSpy`
  - `TVSeriesPageFixtures`
  - `PaginatedTVSeriesAssertions`
- Validation command:
  - `swift test` ✅ passed
