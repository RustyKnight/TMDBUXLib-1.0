# Tasks: Paginated Data Source

**Input**: Design documents from `/specs/001-paginated-data-source/`

**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Include Swift Testing tasks because spec/quickstart define acceptance validation with `swift test`.

**Organization**: Tasks are grouped by user story for independent implementation and testing.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare source and test locations used by pagination contract work.

- [X] T001 Create pagination module folder placeholder in Sources/TMDBUXLib/Pagination/.gitkeep
- [X] T002 [P] Create pagination test support folder placeholder in Tests/TMDBUXLibTests/Pagination/Support/.gitkeep
- [X] T003 [P] Create pagination contract test folder placeholder in Tests/TMDBUXLibTests/Pagination/.gitkeep

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build shared contract types and reusable test fixtures required by every story.

**⚠️ CRITICAL**: Complete this phase before starting user-story work.

- [X] T004 Define `PaginatedDataSource` and `PageResult` in Sources/TMDBUXLib/Pagination/PaginatedDataSource.swift
- [X] T005 Export pagination contract symbols from Sources/TMDBUXLib/TMDBUXLib.swift
- [X] T006 [P] Add reusable in-memory fixture scaffold with session state in Tests/TMDBUXLibTests/Pagination/Support/InMemoryPaginatedDataSource.swift
- [X] T007 [P] Add shared `PageResult` assertion helpers in Tests/TMDBUXLibTests/Pagination/Support/PaginationOutcomeAssertions.swift

**Checkpoint**: Foundation complete; all stories can now be delivered independently.

---

## Phase 3: User Story 1 - Read results sequentially (Priority: P1) 🎯 MVP

**Goal**: Consumers retrieve pages in forward-only order without explicit page-number management.

**Independent Test**: Consume a 3-page deterministic fixture with repeated `nextPage()` calls and verify ordered non-duplicated `.page(...)` outcomes.

### Tests for User Story 1

- [X] T008 [P] [US1] Add sequential retrieval tests for consecutive `nextPage()` calls in Tests/TMDBUXLibTests/Pagination/PaginatedDataSourceSequentialTests.swift
- [X] T009 [P] [US1] Add page-order regression tests across 3+ pages in Tests/TMDBUXLibTests/Pagination/PaginatedDataSourceOrderingTests.swift

### Implementation for User Story 1

- [X] T010 [US1] Implement forward-only page advancement in Tests/TMDBUXLibTests/Pagination/Support/InMemoryPaginatedDataSource.swift
- [X] T011 [US1] Implement deterministic ordered page fixture builder in Tests/TMDBUXLibTests/Pagination/Support/InMemoryPaginatedDataSource.swift

**Checkpoint**: US1 is a usable MVP slice and independently testable.

---

## Phase 4: User Story 2 - Detect pagination completion safely (Priority: P2)

**Goal**: Consumers can stop gracefully via `hasMorePages` and the `.noMorePages` terminal outcome.

**Independent Test**: Exhaust a finite fixture, verify `hasMorePages` flips to `false`, and confirm repeated terminal calls stay `.noMorePages`.

### Tests for User Story 2

- [X] T012 [P] [US2] Add completion outcome tests for `.noMorePages` in Tests/TMDBUXLibTests/Pagination/PaginatedDataSourceCompletionTests.swift
- [X] T013 [P] [US2] Add `hasMorePages` transition tests before/after exhaustion in Tests/TMDBUXLibTests/Pagination/PaginatedDataSourceHasMorePagesTests.swift

### Implementation for User Story 2

- [X] T014 [US2] Implement stable terminal-state behavior for post-exhaustion calls in Tests/TMDBUXLibTests/Pagination/Support/InMemoryPaginatedDataSource.swift
- [X] T015 [US2] Implement `hasMorePages` terminal transition updates in Tests/TMDBUXLibTests/Pagination/Support/InMemoryPaginatedDataSource.swift

**Checkpoint**: US2 completion signaling is unambiguous and independently testable.

---

## Phase 5: User Story 3 - Handle empty-but-valid pages (Priority: P3)

**Goal**: Empty entity pages are treated as successful page outcomes.

**Independent Test**: Retrieve a configured empty page and verify `.page(PageResult(entities: []))` is returned instead of `.noMorePages`.

### Tests for User Story 3

- [X] T016 [P] [US3] Add empty-page success behavior tests in Tests/TMDBUXLibTests/Pagination/PaginatedDataSourceEmptyPageTests.swift

### Implementation for User Story 3

- [X] T017 [US3] Update fixture behavior to emit empty pages as valid `.page` results in Tests/TMDBUXLibTests/Pagination/Support/InMemoryPaginatedDataSource.swift
- [X] T018 [US3] Confirm `PageResult` preserves empty arrays as valid payloads in Sources/TMDBUXLib/Pagination/PaginatedDataSource.swift

**Checkpoint**: US3 preserves predictable behavior for empty-but-valid page data.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final documentation and validation updates across all stories.

- [X] T019 [P] Add usage examples and behavior notes to contract docs in specs/001-paginated-data-source/contracts/paginated-data-source.md
- [X] T020 [P] Align quickstart verification steps with implemented tests in specs/001-paginated-data-source/quickstart.md
- [X] T021 Record public API usage note in Sources/TMDBUXLib/TMDBUXLib.swift

---

## Dependencies & Execution Order

### Phase Dependencies

- Phase 1 (Setup) → Phase 2 (Foundational) → Phase 3 (US1) → Phase 4 (US2) → Phase 5 (US3) → Phase 6 (Polish)

### User Story Dependencies

- **US1 (P1)**: Depends only on Foundational phase.
- **US2 (P2)**: Depends on Foundational; does not require US1 completion for testing.
- **US3 (P3)**: Depends on Foundational; does not require US2 completion for testing.

### Task Dependency Graph (Story Order)

- **US1 chain**: T008/T009 → T010/T011
- **US2 chain**: T012/T013 → T014/T015
- **US3 chain**: T016 → T017/T018

---

## Parallel Opportunities

- **Setup**: T002 and T003 can run in parallel.
- **Foundational**: T006 and T007 can run in parallel after T004 starts.
- **US1**: T008 and T009 can run in parallel.
- **US2**: T012 and T013 can run in parallel.
- **US3**: T017 and T018 can run in parallel after T016.
- **Polish**: T019 and T020 can run in parallel.

## Parallel Example: User Story 1

```bash
Task: "T008 [US1] Add sequential retrieval tests in Tests/TMDBUXLibTests/Pagination/PaginatedDataSourceSequentialTests.swift"
Task: "T009 [US1] Add ordering regression tests in Tests/TMDBUXLibTests/Pagination/PaginatedDataSourceOrderingTests.swift"
```

## Parallel Example: User Story 2

```bash
Task: "T012 [US2] Add completion tests in Tests/TMDBUXLibTests/Pagination/PaginatedDataSourceCompletionTests.swift"
Task: "T013 [US2] Add hasMorePages transition tests in Tests/TMDBUXLibTests/Pagination/PaginatedDataSourceHasMorePagesTests.swift"
```

## Parallel Example: User Story 3

```bash
Task: "T017 [US3] Update fixture empty-page behavior in Tests/TMDBUXLibTests/Pagination/Support/InMemoryPaginatedDataSource.swift"
Task: "T018 [US3] Confirm PageResult empty payload behavior in Sources/TMDBUXLib/Pagination/PaginatedDataSource.swift"
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete US1 tasks (T008–T011).
3. Validate US1 independently with `swift test`.

### Incremental Delivery

1. Deliver US1 (sequential retrieval).
2. Deliver US2 (safe completion signaling).
3. Deliver US3 (empty-page handling).
4. Finish with Phase 6 documentation/quickstart polish.

### Parallel Team Strategy

1. Team completes Setup + Foundational together.
2. After Foundational completion, split US1/US2/US3 across developers.
3. Merge each story after its independent tests pass.
