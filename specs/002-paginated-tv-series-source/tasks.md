# Tasks: Paginated TV Series Data Source

**Input**: Design documents from `/specs/002-paginated-tv-series-source/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/paginated-tv-series-data-source.md`, `quickstart.md`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare package/test scaffolding for TV-series pagination work.

- [X] T001 Verify TMDB dependencies and platform constraints remain unchanged in `Package.swift`
- [X] T002 Create TV-series test-double scaffold in `Tests/TMDBUXLibTests/Pagination/Support/TMDBSearchTVClientSpy.swift`
- [X] T003 [P] Create reusable TV-series page fixture builders in `Tests/TMDBUXLibTests/Pagination/Support/TVSeriesPageFixtures.swift`
- [X] T004 [P] Add shared TV-series pagination assertions in `Tests/TMDBUXLibTests/Pagination/Support/PaginatedTVSeriesAssertions.swift`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Define the contract and base implementation shape required by all user stories.

**⚠️ CRITICAL**: No user story implementation starts before this phase is complete.

- [X] T005 Define `PaginatedTVSeriesDataSourceError` and `PaginatedTVSeriesDataSource` public contract in `Sources/TMDBUXLib/Pagination/PaginatedTVSeriesDataSource.swift`
- [X] T006 Implement base stored properties (`tmdbClient`, filters, pagination state, page index, loading guard) in `Sources/TMDBUXLib/Pagination/PaginatedTVSeriesDataSource.swift`
- [X] T007 Add internal request builder that maps source configuration to `TMDBClient.searchTV` arguments in `Sources/TMDBUXLib/Pagination/PaginatedTVSeriesDataSource.swift`
- [X] T008 [P] Add baseline compile smoke test for concrete TV-series source instantiation in `Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceInitializationTests.swift`

**Checkpoint**: Contract, source shell, and shared test support are ready.

---

## Phase 3: User Story 1 - Search TV series by term (Priority: P1) 🎯 MVP

**Goal**: Retrieve first and subsequent pages for a valid search term.

**Independent Test**: Set a valid term, call `nextPage()`, and verify first page is returned; continue calls and verify ordered progression then terminal `.noMorePages`.

### Tests for User Story 1

- [X] T009 [P] [US1] Add first-page retrieval test for valid term in `Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceSearchTests.swift`
- [X] T010 [P] [US1] Add ordered multi-page progression test in `Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceSearchTests.swift`
- [X] T011 [P] [US1] Add no-more-pages terminal behavior test after exhaustion in `Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceSearchTests.swift`

### Implementation for User Story 1

- [X] T012 [US1] Implement `nextPage()` success flow with page fetch + `PageResult.page` mapping in `Sources/TMDBUXLib/Pagination/PaginatedTVSeriesDataSource.swift`
- [X] T013 [US1] Implement page index/total-pages state transitions and terminal `.noMorePages` behavior in `Sources/TMDBUXLib/Pagination/PaginatedTVSeriesDataSource.swift`
- [X] T014 [US1] Ensure successful empty result pages return `.page([])` (not failure) in `Sources/TMDBUXLib/Pagination/PaginatedTVSeriesDataSource.swift`

**Checkpoint**: US1 is independently functional and testable as the MVP increment.

---

## Phase 4: User Story 2 - Enforce required search term (Priority: P1)

**Goal**: Fail fast with explicit `missingSearchTerm` when retrieval is attempted without a valid term.

**Independent Test**: Leave term unset/blank, call `nextPage()` and `refresh()`, and verify both fail with `missingSearchTerm`.

### Tests for User Story 2

- [X] T015 [P] [US2] Add `nextPage()` missing-term failure test in `Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceMissingTermTests.swift`
- [X] T016 [P] [US2] Add `refresh()` missing-term failure test in `Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceMissingTermTests.swift`
- [X] T017 [P] [US2] Add whitespace-only term normalization failure test in `Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceMissingTermTests.swift`
- [X] T018 [P] [US2] Add assignment-without-fetch behavior test in `Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceMissingTermTests.swift`

### Implementation for User Story 2

- [X] T019 [US2] Implement trimmed-term validation and `missingSearchTerm` error path for `nextPage()` and `refresh()` in `Sources/TMDBUXLib/Pagination/PaginatedTVSeriesDataSource.swift`
- [X] T020 [US2] Ensure `searchTerm` assignment is configuration-only with no implicit I/O in `Sources/TMDBUXLib/Pagination/PaginatedTVSeriesDataSource.swift`

**Checkpoint**: US2 independently enforces precondition behavior and explicit failure semantics.

---

## Phase 5: User Story 3 - Reset search session on term changes (Priority: P2)

**Goal**: Reset pagination/session progress whenever the search term changes.

**Independent Test**: Load pages for term A, switch to term B, verify state resets, then verify first retrieval for term B starts at page 1 and old progression is discarded.

### Tests for User Story 3

- [X] T021 [P] [US3] Add term-change state reset test (`.beforeFirstPage`, index reset) in `Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceTermResetTests.swift`
- [X] T022 [P] [US3] Add term-change discard-old-session and restart-from-page-1 test in `Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceTermResetTests.swift`
- [X] T023 [P] [US3] Add `refresh()` reset-from-current-term test in `Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceTermResetTests.swift`

### Implementation for User Story 3

- [X] T024 [US3] Implement `searchTerm` change detection that resets pagination state/session progress in `Sources/TMDBUXLib/Pagination/PaginatedTVSeriesDataSource.swift`
- [X] T025 [US3] Implement `refresh()` to reset to page 1 and fetch first page for active term in `Sources/TMDBUXLib/Pagination/PaginatedTVSeriesDataSource.swift`

**Checkpoint**: US3 independently guarantees deterministic session reset behavior.

---

## Phase 6: User Story 4 - Apply optional search filters (Priority: P3)

**Goal**: Forward optional filters (`language`, `includeAdult`, `firstAirDateYear`) consistently on retrieval calls.

**Independent Test**: Configure each optional filter, call retrieval with valid term, and verify spy recorded forwarded filter values on each request.

### Tests for User Story 4

- [X] T026 [P] [US4] Add filter-forwarding test for `nextPage()` requests in `Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceFiltersTests.swift`
- [X] T027 [P] [US4] Add filter-forwarding persistence test across multi-page traversal in `Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceFiltersTests.swift`
- [X] T028 [P] [US4] Add filter-forwarding-on-`refresh()` test in `Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceFiltersTests.swift`

### Implementation for User Story 4

- [X] T029 [US4] Wire initializer-provided optional filters into each TMDB search request in `Sources/TMDBUXLib/Pagination/PaginatedTVSeriesDataSource.swift`
- [X] T030 [US4] Preserve filter application across term changes and refresh cycles in `Sources/TMDBUXLib/Pagination/PaginatedTVSeriesDataSource.swift`

**Checkpoint**: US4 independently validates filter-aware retrieval behavior.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and documentation alignment across all stories.

- [X] T031 [P] Update usage/contract notes for TV-series pagination behavior in `specs/002-paginated-tv-series-source/contracts/paginated-tv-series-data-source.md`
- [X] T032 [P] Align validation walkthrough with implemented test names in `specs/002-paginated-tv-series-source/quickstart.md`
- [X] T033 Run full package tests and record validation notes in `specs/002-paginated-tv-series-source/research.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1) has no prerequisites.
- Foundational (Phase 2) depends on Setup and blocks all user stories.
- User Story phases (3-6) depend on Foundational completion.
- Polish (Phase 7) depends on completion of all targeted user stories.

### User Story Dependencies

- **US1 (P1)**: Starts after Phase 2; no dependency on other stories.
- **US2 (P1)**: Starts after Phase 2; behavior is independently testable, but implementation shares source file with US1.
- **US3 (P2)**: Starts after Phase 2; functionally builds on pagination flow established in US1.
- **US4 (P3)**: Starts after Phase 2; reuses request pipeline implemented in US1.

### Recommended Delivery Order

1. Phase 1 → Phase 2
2. US1 (MVP)
3. US2
4. US3
5. US4
6. Phase 7 polish

---

## Parallel Opportunities

- **Setup**: T003 and T004 can run in parallel once T002 creates support scaffold.
- **Foundational**: T008 can run in parallel with T006/T007 after T005 exists.
- **US1**: T009-T011 can be authored in parallel.
- **US2**: T015-T018 can be authored in parallel.
- **US3**: T021-T023 can be authored in parallel.
- **US4**: T026-T028 can be authored in parallel.
- **Polish**: T031 and T032 can run in parallel before T033 final validation.

## Parallel Example: User Story 1

```bash
Task: "T009 [US1] Add first-page retrieval test in Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceSearchTests.swift"
Task: "T010 [US1] Add ordered multi-page progression test in Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceSearchTests.swift"
Task: "T011 [US1] Add no-more-pages terminal behavior test in Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceSearchTests.swift"
```

## Parallel Example: User Story 2

```bash
Task: "T015 [US2] Add nextPage missing-term test in Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceMissingTermTests.swift"
Task: "T016 [US2] Add refresh missing-term test in Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceMissingTermTests.swift"
Task: "T017 [US2] Add whitespace-only term test in Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceMissingTermTests.swift"
```

## Parallel Example: User Story 3

```bash
Task: "T021 [US3] Add term-change reset-state test in Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceTermResetTests.swift"
Task: "T022 [US3] Add restart-from-page-1-after-term-change test in Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceTermResetTests.swift"
Task: "T023 [US3] Add refresh reset behavior test in Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceTermResetTests.swift"
```

## Parallel Example: User Story 4

```bash
Task: "T026 [US4] Add nextPage filter-forwarding test in Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceFiltersTests.swift"
Task: "T027 [US4] Add multi-page filter persistence test in Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceFiltersTests.swift"
Task: "T028 [US4] Add refresh filter-forwarding test in Tests/TMDBUXLibTests/Pagination/PaginatedTVSeriesDataSourceFiltersTests.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phases 1-2.
2. Deliver Phase 3 (US1) and validate its independent test criteria.
3. Demo/ship MVP after US1 passes.

### Incremental Delivery

1. Add US2 to enforce retrieval preconditions.
2. Add US3 to guarantee deterministic term-change reset behavior.
3. Add US4 to complete optional filter forwarding.
4. Finish with Phase 7 documentation + full-suite validation.

### Parallel Team Strategy

1. Team completes Setup + Foundational together.
2. Split story test authoring in parallel by story phase.
3. Sequence shared-source-file implementation merges to avoid conflicts in `Sources/TMDBUXLib/Pagination/PaginatedTVSeriesDataSource.swift`.
