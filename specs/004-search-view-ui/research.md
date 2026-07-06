# Phase 0 Research: Search View UI

## Decision 1: Use a single generic entity across data source, row rendering, and selection
- **Decision**: Define the search view surface as generic over `Entity`, constrained so the paginated source, row renderer, and selected output all use exactly the same `Entity` type.
- **Rationale**: The source plan requires selected items to be the physical data-source item (`MovieListResult` or `TVSeriesListResult`), which is best guaranteed by generics rather than runtime casting.
- **Alternatives considered**:
  - Use type-erased selection (`any`/boxed values): rejected because it weakens compile-time safety and can permit type mismatches.
  - Use separate movie and TV view implementations: rejected because it duplicates behavior already shared by requirements.

## Decision 2: Model UI behavior with explicit state enum matching FR-008
- **Decision**: Represent view-model output with explicit states for `noSearch`, `loadingFirstPage`, `loadedResults`, `loadedEmpty`, `loadingNextPage`, `nextPageError`, and `initialSearchError`.
- **Rationale**: FR-008 requires each of these states to be exposed and maintained; an explicit enum keeps transitions testable and deterministic.
- **Alternatives considered**:
  - Derive UI from loosely coupled booleans (`isLoading`, `hasError`, etc.): rejected due to ambiguous combinations and edge-case bugs.
  - Merge first-page and next-page errors into one state: rejected because requirements explicitly separate them.

## Decision 3: Keep view content customizable through caller-provided factory protocols
- **Decision**: Use a caller-provided factory contract for initial/empty/error body content, row content, and prompt text.
- **Rationale**: FR-014 to FR-016 and the source plan require external customization of both state views and item rendering.
- **Alternatives considered**:
  - Hard-code default views in library: rejected because it prevents host-app UX customization.
  - Accept only closure parameters on initializer: rejected in favor of named protocol requirements for clearer public API evolution.

## Decision 4: Guard pagination triggers to prevent duplicate next-page requests
- **Decision**: On end-of-list events, request next page only when current state indicates more pages available and no in-flight load.
- **Rationale**: FR-009, FR-010, and edge cases require avoiding duplicate fetches while showing proper loading indicators.
- **Alternatives considered**:
  - Trigger fetch on every end-of-list event: rejected because it can issue concurrent duplicates.
  - Disable infinite scroll and require explicit button: rejected as inconsistent with required scrolling behavior.

## Decision 5: Validate behavior using deterministic Swift Testing doubles
- **Decision**: Validate state transitions and selection behavior with in-memory/double data sources and view factory stubs under Swift Testing.
- **Rationale**: Provides repeatable proof for first-page/next-page success, empty, and error flows without network nondeterminism.
- **Alternatives considered**:
  - UI snapshot-only tests: rejected because they do not fully prove async state transition rules.
  - Live TMDB integration tests only: rejected due to variability and slower feedback loops.
