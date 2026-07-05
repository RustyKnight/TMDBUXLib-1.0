# Phase 0 Research: Paginated Movie Data Source

## Decision 1: Use `TMDBClient.searchMovies` as the only page-fetch primitive
- **Decision**: Implement retrieval via `TMDBClient.searchMovies(query:page:language:region:includeAdult:firstAirDateYear:primaryReleaseYear:...)`.
- **Rationale**: Source spec explicitly defines this workflow and required optional filter surface.
- **Alternatives considered**:
  - Multi-page bulk loader API: rejected because it bypasses caller-driven pagination semantics.
  - Custom API wrapper layer: rejected as unnecessary for this focused feature scope.

## Decision 2: Treat missing/blank `searchTerm` as explicit domain error
- **Decision**: Return a dedicated `missingSearchTerm` failure for both `nextPage()` and `refresh()` when `searchTerm` is nil/blank.
- **Rationale**: Directly satisfies FR-001/FR-002 and keeps invalid consumer usage diagnosable.
- **Alternatives considered**:
  - Silent no-op with no failure: rejected because it hides invalid preconditions.
  - Generic transport error: rejected because it conflates domain and network concerns.

## Decision 3: Search-term mutation resets session state only
- **Decision**: Changing `searchTerm` resets pagination state to `.beforeFirstPage`, clears loaded progress, and does not fetch automatically.
- **Rationale**: Required by FR-003/FR-004/FR-005 and prevents cross-term data mixing.
- **Alternatives considered**:
  - Auto-fetch first page on assignment: rejected because retrieval must remain explicit.
  - Keep previous pages after term change: rejected due to stale/mixed-result risk.

## Decision 4: Keep filters initialization-scoped and reapplied on every request
- **Decision**: `language`, `region`, `includeAdult`, `firstAirDateYear`, and `primaryReleaseYear` are optional initializer parameters forwarded on every `searchMovies` request.
- **Rationale**: Matches source plan requirements and keeps paging behavior consistent across all pages and refreshes.
- **Alternatives considered**:
  - Mutable per-request filters: rejected to avoid state ambiguity during pagination.
  - Applying filters only on first page: rejected as it breaks query consistency.

## Decision 5: Validate behavior with deterministic Swift Testing doubles
- **Decision**: Use Swift Testing with deterministic doubles/spies for movie search behavior, including empty pages and end-of-pagination scenarios.
- **Rationale**: Provides repeatable, reliable validation of pagination state transitions without live-network flakiness.
- **Alternatives considered**:
  - Live TMDB integration-only tests: rejected for nondeterminism and slower feedback loops.
  - XCTest-only approach: rejected in favor of project preference for Swift Testing.
