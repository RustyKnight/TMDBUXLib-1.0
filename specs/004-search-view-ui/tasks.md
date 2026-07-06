# Tasks: Search View UI

**Input**: Design documents from `/specs/004-search-view-ui/`

**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/search-view-ui-contract.md, quickstart.md

**Tests**: Include Swift Testing coverage for each user story (`swift test`) per plan and quickstart validation scenarios.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no direct dependency)
- **[Story]**: User story label (`[US1]`, `[US2]`, `[US3]`, `[US4]`)
- Every task includes an exact target file path

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish SearchView source/test layout and reusable test scaffolding.

- [X] T001 Create SearchView source directory scaffold and baseline file in `Sources/TMDBUXLib/SearchView/SearchView.swift`
- [X] T002 [P] Create SearchView test support scaffold in `Tests/TMDBUXLibTests/SearchView/Support/InMemorySearchablePaginatedDataSource.swift`
- [X] T003 [P] Create SearchView factory stub scaffold in `Tests/TMDBUXLibTests/SearchView/Support/SearchViewFactorySpy.swift`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Define shared contracts and state model required by all stories.

**⚠️ CRITICAL**: Complete this phase before starting user story implementation.

- [X] T004 Implement FR-008 state machine enum in `Sources/TMDBUXLib/SearchView/SearchViewState.swift`
- [X] T005 [P] Implement caller-provided view factory protocol in `Sources/TMDBUXLib/SearchView/SearchViewFactory.swift`
- [X] T006 Implement base search session/view-model contract in `Sources/TMDBUXLib/SearchView/SearchViewModel.swift`
- [X] T007 [P] Add contract-shape tests for state/factory/view-model signatures in `Tests/TMDBUXLibTests/SearchView/SearchViewContractShapeTests.swift`
- [X] T008 Update package API entrypoint notes for SearchView surface in `Sources/TMDBUXLib/TMDBUXLib.swift`

**Checkpoint**: Shared SearchView contracts and foundational test scaffolding are ready.

---

## Phase 3: User Story 1 - Run a search and view results (Priority: P1) 🎯 MVP

**Goal**: Support valid search submission and show loaded result rows.

**Independent Test**: Enter a valid term, run search, and verify loading transitions to visible results list when matches exist.

### Tests for User Story 1

- [X] T009 [P] [US1] Add submit-search happy-path transition tests in `Tests/TMDBUXLibTests/SearchView/SearchViewModelSubmitSearchTests.swift`
- [X] T010 [P] [US1] Add first-page loaded-results state tests in `Tests/TMDBUXLibTests/SearchView/SearchViewModelResultsStateTests.swift`

### Implementation for User Story 1

- [X] T011 [US1] Implement valid-term `submitSearch()` flow with pre-load result reset in `Sources/TMDBUXLib/SearchView/SearchViewModel.swift`
- [X] T012 [US1] Implement loaded-results list rendering in `Sources/TMDBUXLib/SearchView/SearchView.swift`
- [X] T013 [US1] Wire caller-provided row view + prompt binding in `Sources/TMDBUXLib/SearchView/SearchView.swift`

**Checkpoint**: US1 is independently functional and testable as MVP behavior.

---

## Phase 4: User Story 2 - Handle empty and error outcomes (Priority: P1)

**Goal**: Surface clear empty/error feedback and reject invalid search submissions.

**Independent Test**: Run a no-results search and a first-page failure search, then verify empty/error states and invalid-term no-op behavior.

### Tests for User Story 2

- [X] T014 [P] [US2] Add empty first-page outcome tests in `Tests/TMDBUXLibTests/SearchView/SearchViewModelEmptyStateTests.swift`
- [X] T015 [P] [US2] Add initial-search error and empty-term guard tests in `Tests/TMDBUXLibTests/SearchView/SearchViewModelErrorGuardTests.swift`

### Implementation for User Story 2

- [X] T016 [US2] Implement `loadedEmpty` first-page outcome handling in `Sources/TMDBUXLib/SearchView/SearchViewModel.swift`
- [X] T017 [US2] Implement `initialSearchError` mapping and invalid-term guard path in `Sources/TMDBUXLib/SearchView/SearchViewModel.swift`
- [X] T018 [US2] Implement factory-driven initial/empty/error body rendering in `Sources/TMDBUXLib/SearchView/SearchView.swift`

**Checkpoint**: US2 outcomes are independently testable with deterministic empty/error coverage.

---

## Phase 5: User Story 3 - Load additional pages while scrolling (Priority: P2)

**Goal**: Load/append next pages at list end and show proper next-page loading/error feedback.

**Independent Test**: Run a multi-page search, trigger end-of-list loads, verify append behavior, and verify preserved results on next-page failure.

### Tests for User Story 3

- [X] T019 [P] [US3] Add end-of-list trigger and append-order tests in `Tests/TMDBUXLibTests/SearchView/SearchViewModelPaginationTests.swift`
- [X] T020 [P] [US3] Add next-page error preservation and no-more-pages guard tests in `Tests/TMDBUXLibTests/SearchView/SearchViewModelPaginationErrorTests.swift`

### Implementation for User Story 3

- [X] T021 [US3] Implement `loadNextPageIfNeeded(currentItem:)` request guards in `Sources/TMDBUXLib/SearchView/SearchViewModel.swift`
- [X] T022 [US3] Implement next-page append and `nextPageError(items:error:)` transitions in `Sources/TMDBUXLib/SearchView/SearchViewModel.swift`
- [X] T023 [US3] Implement end-of-list loading/error indicators in `Sources/TMDBUXLib/SearchView/SearchView.swift`

**Checkpoint**: US3 pagination behavior is independently functional and deterministic.

---

## Phase 6: User Story 4 - Select a single result (Priority: P3)

**Goal**: Allow selecting exactly one result item and expose selected entity output.

**Independent Test**: Load results, select one item, then another, and verify only one selected value remains.

### Tests for User Story 4

- [X] T024 [P] [US4] Add single-selection replacement tests in `Tests/TMDBUXLibTests/SearchView/SearchViewModelSelectionTests.swift`

### Implementation for User Story 4

- [X] T025 [US4] Implement single-item `select(item:)` semantics in `Sources/TMDBUXLib/SearchView/SearchViewModel.swift`
- [X] T026 [US4] Implement selected-row state binding in `Sources/TMDBUXLib/SearchView/SearchView.swift`

**Checkpoint**: US4 selection semantics are independently testable and aligned with contract typing.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Validate integrated behavior and finalize feature-level documentation/verification.

- [X] T027 [P] Add quickstart-aligned validation notes and command examples in `specs/004-search-view-ui/quickstart.md`
- [X] T028 Execute full package regression and record final validation checklist in `specs/004-search-view-ui/tasks.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: no dependencies.
- **Phase 2 (Foundational)**: depends on Phase 1 and blocks all stories.
- **Phases 3-6 (User Stories)**: depend on Phase 2 completion.
- **Phase 7 (Polish)**: depends on completion of selected user stories.

### User Story Dependencies

- **US1 (P1)**: starts after Foundational; no dependency on other stories.
- **US2 (P1)**: starts after Foundational; logically independent of US1 but may reuse US1 core submit flow.
- **US3 (P2)**: starts after Foundational and assumes first-page success behavior from US1.
- **US4 (P3)**: starts after Foundational and requires visible results from US1.

### Suggested Delivery Order

1. Complete Phase 1 + Phase 2
2. Deliver US1 (MVP), validate with `swift test`
3. Add US2 outcome handling
4. Add US3 pagination
5. Add US4 single selection
6. Run Phase 7 polish/regression

---

## Parallel Opportunities

- **Setup**: T002 and T003 can run in parallel after T001.
- **Foundational**: T005 and T007 can run in parallel after T004/T006 scaffolding is defined.
- **US1**: T009 and T010 run in parallel; implementation starts after failing tests are confirmed.
- **US2**: T014 and T015 run in parallel.
- **US3**: T019 and T020 run in parallel.
- **US4**: T024 can run while US3 implementation is in progress, then finalize with T025/T026.

## Parallel Example: User Story 1

```bash
# Parallel test authoring
Task: "T009 [US1] submit-search happy-path tests in Tests/TMDBUXLibTests/SearchView/SearchViewModelSubmitSearchTests.swift"
Task: "T010 [US1] first-page loaded-results tests in Tests/TMDBUXLibTests/SearchView/SearchViewModelResultsStateTests.swift"
```

## Parallel Example: User Story 2

```bash
# Parallel outcome-path tests
Task: "T014 [US2] empty state tests in Tests/TMDBUXLibTests/SearchView/SearchViewModelEmptyStateTests.swift"
Task: "T015 [US2] error + invalid-term guard tests in Tests/TMDBUXLibTests/SearchView/SearchViewModelErrorGuardTests.swift"
```

## Parallel Example: User Story 3

```bash
# Parallel pagination-path tests
Task: "T019 [US3] pagination append tests in Tests/TMDBUXLibTests/SearchView/SearchViewModelPaginationTests.swift"
Task: "T020 [US3] pagination error/no-more-pages tests in Tests/TMDBUXLibTests/SearchView/SearchViewModelPaginationErrorTests.swift"
```

## Parallel Example: User Story 4

```bash
Task: "T024 [US4] selection replacement tests in Tests/TMDBUXLibTests/SearchView/SearchViewModelSelectionTests.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Complete Phase 1 and Phase 2.
2. Deliver Phase 3 (US1) and verify independent acceptance criteria.
3. Pause for review/demo before adding remaining stories.

### Incremental Delivery

1. US1: core search + results list.
2. US2: empty/error + invalid-term guard.
3. US3: pagination loading/append/error handling.
4. US4: single-item selection.
5. Polish with final quickstart/regression validation.

### Validation Command

- `swift test`



## Final Validation Record

- `swift test` executed successfully on 2026-07-06 (52 tests passed).
- SearchView phases (Setup, Foundational, US1-US4, Polish) completed with tasks marked done.
