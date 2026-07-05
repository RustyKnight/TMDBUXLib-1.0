# Implementation Plan: Paginated Movie Data Source

**Branch**: `[feature/003-paginated-movie-series-source]` | **Date**: 2026-07-05 | **Spec**: [specs/003-paginated-movie-series-source/spec.md](./spec.md)

**Input**: Feature specification from `/specs/003-paginated-movie-series-source/spec.md` and source plan context from `/Docs/TMDBUX/004-PaginatedMovieDataSource/Plan.md`

## Summary

Implement a `SearchablePaginatedDataSource`-conforming movie search source backed by `TMDBClient.searchMovies`, with explicit missing-search-term failure, optional query filters (`language`, `region`, `includeAdult`, `firstAirDateYear`, `primaryReleaseYear`), and deterministic pagination reset when `searchTerm` changes.

## Technical Context

**Language/Version**: Swift 6 mode (`swift-tools-version: 6.3`)

**Primary Dependencies**: Swift concurrency (`async/await`), `TMDBLib` (`TMDBClient`, paged movie search payloads), existing `SearchablePaginatedDataSource` contract in `TMDBUXLib`

**Storage**: N/A (in-memory pagination/session state only)

**Testing**: Swift Testing (`swift test`) with deterministic fakes/spies for TMDB client behavior

**Target Platform**: macOS 14+, iOS 17+, tvOS 17+, visionOS 1+

**Project Type**: Swift package library

**Performance Goals**: One network request per `nextPage()`/`refresh()` invocation; preserve ordered page progression for representative multi-page (3+) flows in validation tests

**Constraints**:
- Search term is mandatory before retrieval (including `refresh`)
- Search-term assignment is configuration only (no implicit fetch)
- Search-term changes reset to `.beforeFirstPage` and discard prior results/session progress
- Public API naming follows Swift conventions (camelCase, no underscores)
- No new package dependencies; reuse existing package + TMDB client

**Scale/Scope**: One concrete movie search pagination implementation and related tests; no UI, caching, or metadata enrichment beyond TMDB paged search payloads

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Constitution file (`.specify/memory/constitution.md`) is still a template placeholder with no enforceable ratified principles.
- Gate result (pre-research): **PASS (provisional)** — no explicit enforceable constitution rules present.
- Gate result (post-design): **PASS (provisional)** — design artifacts align with feature spec and source-plan constraints.

## Project Structure

### Documentation (this feature)

```text
specs/003-paginated-movie-series-source/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── paginated-movie-data-source.md
└── tasks.md             # Created in Phase 2 by /speckit.tasks
```

### Source Code (repository root)

```text
Package.swift
Sources/
└── TMDBUXLib/
    ├── TMDBUXLib.swift
    └── Pagination/
        ├── PaginatedDataSource.swift
        ├── PaginatedTVSeriesDataSource.swift
        └── PaginatedMovieDataSource.swift   # planned

Tests/
└── TMDBUXLibTests/
    └── Pagination/
        ├── Support/
        ├── PaginatedDataSource*Tests.swift
        ├── PaginatedTVSeriesDataSource*Tests.swift
        └── PaginatedMovieDataSource*Tests.swift   # planned
```

**Structure Decision**: Keep the existing single Swift package layout and add movie-search-specific pagination source/test types under existing `TMDBUXLib` and `TMDBUXLibTests/Pagination` areas. Feature planning artifacts stay scoped to `specs/003-paginated-movie-series-source/`.

## Complexity Tracking

No constitution violations requiring justification.
