# Phase 0 Research: Paginated Data Source

## Decision 1: Expose pagination via async protocol contract
- **Decision**: Define pagination as a forward-only async contract (`nextPage() async`) rather than synchronous callbacks.
- **Rationale**: Source plan explicitly requires async/await concurrency and the consuming data sources are likely network-backed.
- **Alternatives considered**:
  - Completion-handler API: rejected due to weaker readability and less idiomatic Swift 6 style.
  - Synchronous API: rejected because it does not fit asynchronous page retrieval.

## Decision 2: Represent terminal pagination state with explicit outcome type
- **Decision**: Use a distinct terminal outcome (`.noMorePages`) instead of throwing an error for normal completion.
- **Rationale**: The spec requires no-more-pages to be distinguishable from successful page data and to support graceful completion flow.
- **Alternatives considered**:
  - Throwing terminal error: rejected because end-of-pagination is a valid control path, not an exceptional failure.
  - Returning optional page (`Page?`): rejected due to lower semantic clarity in contract docs.

## Decision 3: Keep entity payload generic and unconstrained
- **Decision**: Model page payload as generic ordered entities without imposing entity schema constraints.
- **Rationale**: Spec assumption states entity shape is owned by each concrete data source.
- **Alternatives considered**:
  - Shared base entity protocol: rejected as unnecessary coupling.
  - Dictionary/loosely typed payloads: rejected due to reduced type safety.

## Decision 4: Testing strategy uses Swift Testing with deterministic fake data source
- **Decision**: Validate contract behavior via Swift Testing tests using deterministic in-memory page fixtures.
- **Rationale**: Source plan prefers Swift Testing; deterministic fixtures prove order, completion, and empty-page semantics without network variance.
- **Alternatives considered**:
  - Integration-only tests against remote API: rejected for flakiness and slower feedback.
  - XCTest-only strategy: rejected in favor of project preference for Swift Testing.

## Decision 5: Dependency and platform posture
- **Decision**: Introduce no new package dependencies and maintain existing package platform minimums.
- **Rationale**: Source plan requires minimal dependencies and current package already declares supported Apple platforms.
- **Alternatives considered**:
  - Add third-party pagination helper library: rejected as unnecessary abstraction overhead.
