# Data Model: Paginated Data Source

## Entity: PaginatedDataSource\<Entity>
- **Purpose**: Contract for forward-only sequential pagination.
- **Core members**:
  - `hasMorePages: Bool` (read-only indicator)
  - `nextPage() async -> PageResult<Entity>`
- **Validation rules**:
  - Must preserve ordering across sequential `nextPage()` calls (FR-007).
  - Must only allow retrieval of the next page in sequence (FR-003).
  - `hasMorePages` must reflect whether additional pages remain (FR-002).

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
- **Validation rules**:
  - `nextIndex` increments only when a page is successfully emitted.
  - Terminal transition sets `hasMorePages` to `false` and remains terminal.

## State Transitions
1. **Initial**: `hasMorePages = true` or `false` depending on source availability.
2. **PageEmitted**: `nextPage()` returns `.page(...)`; session advances to next sequential position.
3. **Exhausted**: `nextPage()` returns `.noMorePages`; `hasMorePages = false`.
4. **Post-Exhaustion**: Additional `nextPage()` calls continue returning `.noMorePages`.
