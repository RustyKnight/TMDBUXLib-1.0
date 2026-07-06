# Implementation Plan: Search View UI

**Branch**: `[feature/004-search-view-ui]` | **Date**: 2026-07-06 | **Spec**: [specs/004-search-view-ui/spec.md](./spec.md)

**Input**: Feature specification from `/specs/004-search-view-ui/spec.md` and source plan context from `/Docs/TMDBUX/005-SearchView/Plan.md`

## Summary

Design a reusable SwiftUI search view surface for TMDB movie/TV results that uses a caller-provided paginated search source and caller-provided view factory, enforces valid term submission, supports deterministic first-page/next-page UI states, and emits exactly one selected result item of the same entity type produced by the data source.

## Technical Context

**Language/Version**: Swift 6 mode (`swift-tools-version: 6.3`)

**Primary Dependencies**: SwiftUI, Swift concurrency (`async/await`), `TMDBLib` entity types (`MovieListResult`, `TVSeriesListResult`), existing `SearchablePaginatedDataSource` contracts in `TMDBUXLib`

**Storage**: N/A (view-model/session state in memory only)

**Testing**: Swift Testing (`swift test`) with deterministic in-memory paginated source doubles and UI-state view-model assertions

**Target Platform**: macOS 14+, iOS 17+, tvOS 17+, visionOS 1+

**Project Type**: Swift package library (UI + support abstractions)

**Performance Goals**:
- Trigger at most one initial-page request per explicit valid search submission.
- Trigger at most one next-page request per end-of-list event while not already loading.
- Keep UI state transitions deterministic and observable for all FR-008 states.

**Constraints**:
- Public-facing names must follow Swift conventions (camelCase, no underscores).
- Search term must be non-empty/non-whitespace before starting search.
- New search must clear previous results before first-page loading appears.
- Item selection type must match data-source entity type (single generic entity).
- `SearchView` requires a non-optional `TMDBClient` and shares it with composed child content via environment.
- Reuse existing package dependencies only (`TMDBLib`, `ImageCacheLib` present in package).

**Scale/Scope**: One generic search-view contract + search-state model + view-model/adapter behavior covering initial load, empty/error outcomes, pagination, and single selection; no persistence, no ranking logic changes, no external navigation flow ownership.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Constitution file (`.specify/memory/constitution.md`) is still a template placeholder with no enforceable ratified principles.
- Gate result (pre-research): **PASS (provisional)** — no explicit enforceable constitution rules present.
- Gate result (post-design): **PASS (provisional)** — generated design artifacts remain aligned with feature spec and source-plan intent.

## Project Structure

### Documentation (this feature)

```text
specs/004-search-view-ui/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── search-view-ui-contract.md
└── tasks.md             # Created in Phase 2 by /speckit.tasks
```

### Source Code (repository root)

```text
Package.swift
Sources/
└── TMDBUXLib/
    ├── TMDBUXLib.swift
    ├── Pagination/
    │   ├── PaginatedDataSource.swift
    │   ├── PaginatedTVSeriesDataSource.swift
    │   └── PaginatedMovieDataSource.swift
    └── SearchView/
        ├── SearchViewState.swift
        ├── SearchViewFactory.swift
        ├── SearchViewModel.swift
        ├── SearchView.swift
        ├── TMDBClientEnvironment.swift
        └── TVSeries/
            └── TVSeriesSearchViewFactory.swift

Tests/
└── TMDBUXLibTests/
    ├── Pagination/
    │   └── Support/
    └── SearchView/
        ├── Support/
        └── SearchView*Tests.swift
```

**Structure Decision**: Keep the existing single Swift package layout. Add search-view-specific interfaces and behavior under a new `Sources/TMDBUXLib/SearchView/` area with matching test coverage in `Tests/TMDBUXLibTests/SearchView/`, while keeping feature planning artifacts under `specs/004-search-view-ui/`.

## Complexity Tracking

No constitution violations requiring justification.
