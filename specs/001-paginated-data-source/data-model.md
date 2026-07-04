# Data Model: Paginated Data Source

## Entity: PaginatedDataSource\<Entity>
- **Purpose**: Contract for forward-only sequential pagination.
- **Core members**:
  - `state: PaginationState` (read-only pagination progress indicator)
  - `isLoading: Bool` (read-only request activity indicator)
  - `nextPage() async throws -> PageResult<Entity>`
  - `refresh() async throws -> PageResult<Entity>`
- **Validation rules**:
  - Must preserve ordering across sequential `nextPage()` calls (FR-007).
  - Must only allow retrieval of the next page in sequence (FR-003).
  - Must propagate retrieval errors through thrown failures.
  - `state` must transition through `.beforeFirstPage`, `.morePages`, and `.noMorePage` appropriately.
  - `isLoading` must be `true` only while a page request is active.
  - `refresh()` must reset pagination to the first page and return that result.

## Entity: PaginationState
- **Purpose**: Represent paginated progress without separate booleans.
- **Cases**:
  - `.beforeFirstPage` (no load attempt yet)
  - `.morePages` (additional pages available)
  - `.noMorePage` (last page loaded, or exhausted after load attempt)

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
  - `state: PaginationState`
  - `isLoading: Bool`
- **Validation rules**:
  - `nextIndex` increments only when a page is successfully emitted.
  - `isLoading` is set `true` at request start and reset to `false` on completion.
  - Initial state is `.beforeFirstPage`.
  - Terminal transition sets state to `.noMorePage` and remains terminal.

## State Transitions
1. **Initial**: `state = .beforeFirstPage`.
2. **PageEmitted**: `nextPage()` returns `.page(...)`; state becomes `.morePages` or `.noMorePage` based on remaining data.
3. **Exhausted**: `nextPage()` returns `.noMorePages`; `state = .noMorePage`.
4. **Post-Exhaustion**: Additional `nextPage()` calls continue returning `.noMorePages`.
5. **RefreshReset**: `refresh()` resets state to start, loads first page, and returns that outcome.
