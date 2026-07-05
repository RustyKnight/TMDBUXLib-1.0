# Tasks: Paginated Movie Series Data Source

**Input**: Design documents from `/specs/003-paginated-movie-series-source/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Include Swift Testing coverage (`swift test`) because the feature spec and quickstart define explicit validation scenarios and acceptance checks.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the feature file/test layout in the existing Swift package structure.

- [X] T001 Create movie pagination source scaffold in `Sources/TMDBUXLib/Pagination/PaginatedMovieSeriesDataSource.swift`
- [X] T002 Create movie pagination test suite scaffolds in `Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceSearchTests.swift`, `Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceMissingTermTests.swift`, `Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceTermResetTests.swift`, `Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceFiltersTests.swift`, and `Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceInitializationTests.swift`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared movie-pagination test infrastructure and base implementation required by all stories.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T003 [P] Implement deterministic movie search client spy in `Tests/TMDBUXLibTests/Pagination/Support/TMDBSearchMoviesClientSpy.swift`
- [X] T004 [P] Implement movie page fixture builders in `Tests/TMDBUXLibTests/Pagination/Support/MoviePageFixtures.swift`
- [X] T005 [P] Implement movie pagination assertion helpers in `Tests/TMDBUXLibTests/Pagination/Support/PaginatedMovieSeriesAssertions.swift`
- [X] T006 Implement base movie data-source types/properties (`PaginatedMovieSeriesDataSourceError`, `PaginatedMovieSeriesDataSource`, state, initializer, request builder) in `Sources/TMDBUXLib/Pagination/PaginatedMovieSeriesDataSource.swift`
- [X] T007 Add initialization/default behavior coverage in `Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceInitializationTests.swift`

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Search movie data by term (Priority: P1) 🎯 MVP

**Goal**: Retrieve first and subsequent movie pages for a valid term using ordered TMDB pagination outcomes.

**Independent Test**: Set `searchTerm`, call `nextPage()` against deterministic 3-page fixtures, verify ordered `.page(...)` responses followed by stable `.noMorePages`.

### Tests for User Story 1

- [X] T008 [US1] Add first-page and sequential-page retrieval tests in `Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceSearchTests.swift`
- [X] T009 [US1] Add exhaustion and empty-page-success tests in `Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceSearchTests.swift`

### Implementation for User Story 1

- [X] T010 [US1] Implement `nextPage()` movie retrieval, page-index progression, and `.noMorePages` handling in `Sources/TMDBUXLib/Pagination/PaginatedMovieSeriesDataSource.swift`

**Checkpoint**: User Story 1 is independently functional and testable.

---

## Phase 4: User Story 2 - Enforce required search term (Priority: P1)

**Goal**: Return explicit `missingSearchTerm` failures for retrieval attempts without a valid non-whitespace term.

**Independent Test**: Leave `searchTerm` unset/blank, call both `nextPage()` and `refresh()`, verify `PaginatedMovieSeriesDataSourceError.missingSearchTerm`.

### Tests for User Story 2

- [X] T011 [US2] Add missing-term validation tests for `nextPage()`, `refresh()`, and whitespace terms in `Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceMissingTermTests.swift`

### Implementation for User Story 2

- [X] T012 [US2] Implement validated-search-term guard and explicit `missingSearchTerm` failures in `Sources/TMDBUXLib/Pagination/PaginatedMovieSeriesDataSource.swift`

**Checkpoint**: User Story 2 is independently functional and testable.

---

## Phase 5: User Story 3 - Reset paging on term updates (Priority: P2)

**Goal**: Reset pagination/session state when `searchTerm` changes and keep term assignment side-effect free.

**Independent Test**: Load pages for term A, change to term B, verify state reset to `.beforeFirstPage` and next request starts from page 1 for term B without implicit fetch on assignment.

### Tests for User Story 3

- [X] T013 [US3] Add term-change reset and page-one restart tests in `Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceTermResetTests.swift`
- [X] T014 [US3] Add no-implicit-fetch and refresh-restart tests in `Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceTermResetTests.swift`

### Implementation for User Story 3

- [X] T015 [US3] Implement `searchTerm` change reset semantics and `refresh()` restart flow in `Sources/TMDBUXLib/Pagination/PaginatedMovieSeriesDataSource.swift`

**Checkpoint**: User Story 3 is independently functional and testable.

---

## Phase 6: User Story 4 - Apply optional movie search filters (Priority: P3)

**Goal**: Forward optional `language`, `region`, `includeAdult`, `firstAirDateYear`, and `primaryReleaseYear` on every movie search request.

**Independent Test**: Configure filters, execute `nextPage()`/`refresh()`, and verify captured requests include all configured filter values across pages.

### Tests for User Story 4

- [X] T016 [US4] Add optional-filter forwarding tests for `nextPage()` and `refresh()` in `Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceFiltersTests.swift`
- [X] T017 [US4] Add multi-page filter persistence tests in `Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceFiltersTests.swift`

### Implementation for User Story 4

- [X] T018 [US4] Implement filter storage and forwarding (`language`, `region`, `includeAdult`, `firstAirDateYear`, `primaryReleaseYear`) in `Sources/TMDBUXLib/Pagination/PaginatedMovieSeriesDataSource.swift`

**Checkpoint**: User Story 4 is independently functional and testable.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency, docs alignment, and full regression validation.

- [X] T019 [P] Align movie-source public contract notes with implemented behavior in `specs/003-paginated-movie-series-source/contracts/paginated-movie-series-data-source.md`
- [X] T020 [P] Align runnable validation steps with final test coverage in `specs/003-paginated-movie-series-source/quickstart.md`
- [X] T021 Run full package regression (`swift test`) and resolve any failures in `Sources/TMDBUXLib/Pagination/PaginatedMovieSeriesDataSource.swift` and `Tests/TMDBUXLibTests/Pagination/`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies.
- **Phase 2 (Foundational)**: Depends on Phase 1 and blocks all user stories.
- **Phase 3 (US1)**: Depends on Phase 2.
- **Phase 4 (US2)**: Depends on Phase 2 (independent of US1 implementation details).
- **Phase 5 (US3)**: Depends on Phase 2 and benefits from US1 retrieval flow being complete.
- **Phase 6 (US4)**: Depends on Phase 2 and US1 retrieval flow.
- **Phase 7 (Polish)**: Depends on completion of targeted user stories.

### User Story Dependencies

- **US1 (P1)**: Starts immediately after Foundational phase.
- **US2 (P1)**: Starts immediately after Foundational phase; independently testable without successful retrieval.
- **US3 (P2)**: Requires reset behavior plus paginated retrieval context; execute after US1 for fastest validation.
- **US4 (P3)**: Requires retrieval path to verify filter forwarding; execute after US1.

### Within Each User Story

- Write tests first and confirm they fail before implementation changes.
- Implement source behavior in `PaginatedMovieSeriesDataSource.swift`.
- Re-run story-specific tests before moving to the next story.

### Parallel Opportunities

- **Foundation**: T003, T004, T005 can run in parallel.
- **P1 stories**: US1 and US2 can be developed in parallel after Phase 2.
- **Polish**: T019 and T020 can run in parallel.

---

## Parallel Example: User Story 1

```bash
# Parallel test-support work before US1
Task: "T003 Implement deterministic movie search client spy in Tests/TMDBUXLibTests/Pagination/Support/TMDBSearchMoviesClientSpy.swift"
Task: "T004 Implement movie page fixture builders in Tests/TMDBUXLibTests/Pagination/Support/MoviePageFixtures.swift"
Task: "T005 Implement movie pagination assertion helpers in Tests/TMDBUXLibTests/Pagination/Support/PaginatedMovieSeriesAssertions.swift"

# After support is complete, US1 test + implementation flow
Task: "T008 Add first-page and sequential-page retrieval tests in Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceSearchTests.swift"
Task: "T009 Add exhaustion and empty-page-success tests in Tests/TMDBUXLibTests/Pagination/PaginatedMovieSeriesDataSourceSearchTests.swift"
Task: "T010 Implement nextPage() movie retrieval and pagination state flow in Sources/TMDBUXLib/Pagination/PaginatedMovieSeriesDataSource.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup).
2. Complete Phase 2 (Foundational).
3. Complete Phase 3 (US1).
4. Validate US1 independently with targeted tests.
5. Demo/deploy MVP behavior.

### Incremental Delivery

1. Setup + Foundational complete.
2. Deliver US1 (core retrieval).
3. Deliver US2 (missing-term enforcement).
4. Deliver US3 (term-reset behavior).
5. Deliver US4 (optional filters).
6. Finish polish + full regression.

### Parallel Team Strategy

1. One engineer completes Phase 1 and coordinates Phase 2 shared assets.
2. After Phase 2:
   - Engineer A: US1
   - Engineer B: US2
3. After US1 lands:
   - Engineer A/B split US3 and US4
4. Run Phase 7 polish/regression before merge.

---

## Notes

- All tasks use the required checklist format with task ID, optional `[P]`, optional story label, and exact file paths.
- Story labels appear only on user story tasks (US1-US4).
- Setup/foundational/polish tasks intentionally omit story labels.
