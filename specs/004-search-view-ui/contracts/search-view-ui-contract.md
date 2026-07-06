# Contract: Search View UI Public Interface

## Overview
This contract defines a generic SwiftUI search view surface that coordinates a searchable paginated source with caller-provided UI factories and emits single-item selection.

## Swift Contract Shape (normative)
```swift
import SwiftUI
import TMDBLib

public enum SearchViewState<Entity> {
    case noSearch
    case loadingFirstPage
    case loadedResults([Entity])
    case loadedEmpty
    case loadingNextPage([Entity])
    case nextPageError(items: [Entity], error: Error)
    case initialSearchError(Error)
}

public protocol SearchViewFactory {
    associatedtype Entity
    associatedtype InitialContent: View
    associatedtype EmptyContent: View
    associatedtype InitialErrorContent: View
    associatedtype RowContent: View

    var searchPrompt: String { get }
    @ViewBuilder func makeInitialView() -> InitialContent
    @ViewBuilder func makeEmptyResultsView() -> EmptyContent
    @ViewBuilder func makeInitialSearchErrorView(error: Error) -> InitialErrorContent
    @ViewBuilder func makeRowView(item: Entity, isSelected: Bool) -> RowContent
}

public protocol SearchViewModeling: ObservableObject {
    associatedtype Entity
    associatedtype DataSource: SearchablePaginatedDataSource where DataSource.Entity == Entity

    var searchTerm: String { get set }
    var state: SearchViewState<Entity> { get }
    var selectedItem: Entity? { get }

    func submitSearch() async
    func loadNextPageIfNeeded(currentItem: Entity) async
    func select(item: Entity)
}

public struct SearchView<Model: SearchViewModeling, Factory: SearchViewFactory>: View
where Model.Entity == Factory.Entity, Model.Entity: Identifiable {
    public init(viewModel: Model, factory: Factory, tmdbClient: TMDBClient)
}

public extension EnvironmentValues {
    var tmdbClient: TMDBClient { get set }
}
```

## Behavioral Rules (normative)
1. `submitSearch()` must not start retrieval for nil/empty/whitespace-only terms.
2. Starting a new valid search must clear prior results before entering `loadingFirstPage`.
3. First-page outcomes map as:
   - items -> `loadedResults`
   - empty -> `loadedEmpty`
   - failure -> `initialSearchError`
4. End-of-list pagination must request next page only when more pages are available and no load is already in progress.
5. While loading a subsequent page, visible state must include existing items (`loadingNextPage(items:)`).
6. Next-page failure must preserve existing results and emit `nextPageError(items:error:)`.
7. No additional request may be issued once data source reports no more pages.
8. Selection is single-item only: selecting one row replaces any prior selection.
9. Emitted/selected item must be the exact data-source entity type (`MovieListResult`, `TVSeriesListResult`, or other matching `Entity`).
10. Public naming must follow Swift conventions (camelCase, no underscores).
11. `SearchView` construction requires a non-optional `TMDBClient`.
12. `EnvironmentValues.tmdbClient` is non-optional inside `SearchView` composition scope.

## Compatibility Notes
- Platform compatibility remains aligned with `Package.swift` (macOS 14+, iOS 17+, tvOS 17+, visionOS 1+).
- Contract builds on existing `SearchablePaginatedDataSource` and does not require new package dependencies.

## Usage Notes
- Provide a concrete `SearchablePaginatedDataSource` and matching `SearchViewFactory` for the same `Entity`.
- Provide a concrete `TMDBClient` when constructing `SearchView`.
- Bind search text to `searchTerm`, call `submitSearch()` for first-page retrieval, and forward row-end events to `loadNextPageIfNeeded`.
- Use `select(item:)` to produce single-item selection suitable for host-flow continuation.
- A ready-made TV-series factory lives at `Sources/TMDBUXLib/SearchView/TVSeries/TVSeriesSearchViewFactory.swift`.
