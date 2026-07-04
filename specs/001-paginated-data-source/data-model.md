# Data Model: Paginated Data Source

## Entity: PaginatedDataSource\<Entity>
- **Purpose**: Contract for forward-only sequential pagination.
- **Core members**:
  - `hasMorePages: Bool` (read-only indicator)
  - `isLoading: Bool` (read-only request activity indicator)
  - `hasLoadedResults: Bool` (read-only first-attempt indicator)
  - `nextPage() async throws -> PageResult<Entity>`
  - `refresh() async throws -> PageResult<Entity>`
- **Validation rules**:
  - Must preserve ordering across sequential `nextPage()` calls (FR-007).
  - Must only allow retrieval of the next page in sequence (FR-003).
  - Must propagate retrieval errors through thrown failures.
  - `hasMorePages` must reflect whether additional pages remain (FR-002).
  - `isLoading` must be `true` only while a page request is active.
  - `hasLoadedResults` must become `true` after the first load attempt.
  - `refresh()` must reset pagination to the first page and return that result.

## Entity: PageResult\<Entity>
- **Purpose**: Distinguish successful page retrieval from terminal completion.
- **Cases**:
  - `.page([Entity])`
  - `.noMorePages`
- **Validation rules**:
  - `.noMorePages` must be returned when no additional pages remain (FR-005).
  - `.noMorePages` must be clearly distinguishable from `.page(...)` (FR-006).

## Entity: PaginationSessionState (implementation-facing)
- **Purpose**: Tracks progression inside a concrete data source implementation.
- **Fields**:
  - `nextIndex: Int` (initially first page index)
  - `hasMorePages: Bool`
  - `isLoading: Bool`
  - `hasLoadedResults: Bool`
- **Validation rules**:
  - `nextIndex` increments only when a page is successfully emitted.
  - `isLoading` is set `true` at request start and reset to `false` on completion.
  - `hasLoadedResults` is `false` initially and set `true` on first load attempt.
  - Terminal transition sets `hasMorePages` to `false` and remains terminal.

## State Transitions
1. **Initial**: `hasMorePages = true` or `false` depending on source availability; `hasLoadedResults = false`.
2. **PageEmitted**: `nextPage()` returns `.page(...)`; session advances to next sequential position.
3. **Exhausted**: `nextPage()` returns `.noMorePages`; `hasMorePages = false`.
4. **Post-Exhaustion**: Additional `nextPage()` calls continue returning `.noMorePages`.
5. **RefreshReset**: `refresh()` resets state to start, loads first page, and returns that outcome.
