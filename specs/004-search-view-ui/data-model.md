# Data Model: Search View UI

## Entity: SearchViewSession<Entity>
- **Purpose**: Runtime search-session aggregate used by the search view model.
- **Core fields**:
  - `searchTerm: String?`
  - `state: SearchViewState<Entity>`
  - `results: [Entity]`
  - `selectedItem: Entity?`
  - `hasMorePages: Bool`
  - `isLoading: Bool`
- **Validation rules**:
  - A valid search term is trimmed and must be non-empty before retrieval starts.
  - Starting a new valid search clears `results` and `selectedItem` before first-page load.
  - `selectedItem` must either be `nil` or one value present in current `results`.
  - Only one selected item may exist at a time.

## Entity: SearchViewState<Entity>
- **Purpose**: User-visible state machine for primary and pagination outcomes.
- **Cases**:
  - `noSearch`
  - `loadingFirstPage`
  - `loadedResults(items: [Entity])`
  - `loadedEmpty`
  - `loadingNextPage(items: [Entity])`
  - `nextPageError(items: [Entity], error: Error)`
  - `initialSearchError(error: Error)`
- **Validation rules**:
  - States must map one-to-one with FR-008 requirements.
  - `nextPageError` must preserve already loaded `items`.
  - `loadingNextPage` and `nextPageError` are only valid after at least one successful page.

## Entity: SearchViewFactory<Entity, InitialView, EmptyView, ErrorView, RowView>
- **Purpose**: Caller-provided rendering contract for prompt and view customization.
- **Core fields/requirements**:
  - `searchPrompt: String`
  - `makeInitialView() -> InitialView`
  - `makeEmptyResultsView() -> EmptyView`
  - `makeInitialSearchErrorView(error: Error) -> ErrorView`
  - `makeRowView(item: Entity, isSelected: Bool) -> RowView`
- **Validation rules**:
  - Factory output must be type-compatible with the same `Entity` used by data source.
  - Prompt text is provided by caller and surfaced unchanged in search input.
  - Concrete examples include `TVSeriesSearchViewFactory` under `Sources/TMDBUXLib/SearchView/TVSeries/`.

## Entity: SearchViewContext
- **Purpose**: Shared construction-time dependencies required by `SearchView` and its composed children.
- **Core fields**:
  - `tmdbClient: TMDBClient`
- **Validation rules**:
  - `tmdbClient` is required and non-optional at `SearchView` initialization.
  - Child content receives `tmdbClient` via `EnvironmentValues.tmdbClient`.

## Entity: SearchSelectionEvent<Entity>
- **Purpose**: Output event representing user choice.
- **Core fields**:
  - `selected: Entity`
  - `timestamp` (optional internal diagnostic)
- **Validation rules**:
  - Event must emit exactly one selected entity.
  - Emitted entity must be one of current results from the active search session.

## State Transitions
1. **Initial**: `state = .noSearch`, `results = []`, `selectedItem = nil`.
2. **BeginSearch**: Valid submit -> clear prior session -> `state = .loadingFirstPage`.
3. **FirstPageSuccessWithItems**: `state = .loadedResults(items)`, `hasMorePages` set from source state.
4. **FirstPageSuccessEmpty**: `state = .loadedEmpty`, `results = []`.
5. **FirstPageFailure**: `state = .initialSearchError(error)`.
6. **BeginNextPage**: End-of-list trigger while more pages available and not loading -> `state = .loadingNextPage(items)`.
7. **NextPageSuccess**: Append items preserving order -> `state = .loadedResults(appendedItems)`.
8. **NextPageFailure**: Preserve previously loaded items -> `state = .nextPageError(items, error)`.
9. **SelectionChanged**: User taps item -> `selectedItem = tappedItem` and previous selection cleared.
