# Implementation Plan: Paginated TV Series Data Source

**Branch**: `[feature/002-paginated-tv-series-source]` | **Date**: 2026-07-05 | **Spec**: [specs/002-paginated-tv-series-source/spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-paginated-tv-series-source/spec.md` and source plan context from `/Docs/TMDBUX/003-PaginatedTVSeriesDataSource/Plan.md`

## Summary

Implement a `SearchablePaginatedDataSource`-conforming TV series search source backed by `TMDBClient.searchTV`, with explicit missing-search-term failure, optional query filters (language/includeAdult/firstAirDateYear), and deterministic pagination reset when `searchTerm` changes.

## Technical Context

**Language/Version**: Swift 6 mode (`swift-tools-version: 6.3`)

**Primary Dependencies**: Swift concurrency (`async/await`), `TMDBLib` (`TMDBClient`, `Page<TVSeriesListResult>`), existing `SearchablePaginatedDataSource` contract in `TMDBUXLib`

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

**Scale/Scope**: One concrete TV search pagination implementation and related tests; no UI, caching, or metadata enrichment beyond TMDB paged search payloads

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Constitution file (`.specify/memory/constitution.md`) is still a template placeholder with no enforceable ratified principles.
- Gate result (pre-research): **PASS (provisional)** — no explicit enforceable constitution rules present.
- Gate result (post-design): **PASS (provisional)** — design artifacts align with feature spec and source-plan constraints.

## Project Structure

### Documentation (this feature)

```text
specs/002-paginated-tv-series-source/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── paginated-tv-series-data-source.md
└── tasks.md             # Created in Phase 2 by /speckit.tasks
```

### Source Code (repository root)

```text
Package.swift
Sources/
└── TMDBUXLib/
    ├── TMDBUXLib.swift
    └── Pagination/
        └── PaginatedDataSource.swift

Tests/
└── TMDBUXLibTests/
    ├── TMDBUXLibTests.swift
    └── Pagination/
        ├── Support/
        └── PaginatedDataSource*Tests.swift
```

**Structure Decision**: Keep the existing single Swift package layout and add TV-series-specific pagination source/test types under existing `TMDBUXLib` and `TMDBUXLibTests/Pagination` areas. Feature planning artifacts stay scoped to `specs/002-paginated-tv-series-source/`.

## Complexity Tracking

No constitution violations requiring justification.
