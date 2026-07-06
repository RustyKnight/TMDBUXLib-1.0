import Combine
import Foundation

/// Observable contract for driving a generic search view.
public protocol SearchViewModeling: ObservableObject {
    associatedtype Entity
    associatedtype DataSource: SearchablePaginatedDataSource where DataSource.Entity == Entity

    @MainActor
    var searchTerm: String { get set }
    @MainActor
    var state: SearchViewState<Entity> { get }
    @MainActor
    var selectedItem: Entity? { get }

    @MainActor
    func submitSearch() async
    @MainActor
    func loadNextPageIfNeeded(currentItem: Entity) async
    @MainActor
    func select(item: Entity)
}

/// Default search view model that coordinates submission, pagination, and selection.
public final class SearchViewModel<DataSource: SearchablePaginatedDataSource>: SearchViewModeling
where DataSource.Entity: Identifiable {
    public typealias Entity = DataSource.Entity

    @MainActor @Published public var searchTerm: String = ""
    @MainActor @Published public private(set) var state: SearchViewState<Entity> = .noSearch
    @MainActor @Published public private(set) var selectedItem: Entity?

    nonisolated(unsafe) private var dataSource: DataSource
    private var items: [Entity] = []

    public init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

    /// Submits the current search term after trimming whitespace.
    @MainActor
    public func submitSearch() async {
        guard let validatedSearchTerm = normalized(searchTerm) else {
            return
        }

        dataSource.searchTerm = validatedSearchTerm
        items = []
        selectedItem = nil
        state = .loadingFirstPage

        do {
            let pageResult = try await dataSource.refresh()
            switch pageResult {
            case .page(let firstPageItems):
                items = firstPageItems
                state = firstPageItems.isEmpty ? .loadedEmpty : .loadedResults(firstPageItems)
            case .noMorePages:
                items = []
                state = .loadedEmpty
            }
        } catch {
            state = .initialSearchError(error)
        }
    }

    /// Requests the next page when the current row is the last visible item.
    @MainActor
    public func loadNextPageIfNeeded(currentItem: Entity) async {
        guard dataSource.state == .morePages else {
            return
        }
        guard dataSource.isLoading == false else {
            return
        }
        guard let visibleItems = visibleItems() else {
            return
        }
        guard let lastVisibleItem = visibleItems.last else {
            return
        }
        guard id(for: currentItem) == id(for: lastVisibleItem) else {
            return
        }

        state = .loadingNextPage(visibleItems)

        do {
            let nextPageResult = try await dataSource.nextPage()
            switch nextPageResult {
            case .page(let nextPageItems):
                let appendedItems = visibleItems + nextPageItems
                items = appendedItems
                state = .loadedResults(appendedItems)
            case .noMorePages:
                items = visibleItems
                state = .loadedResults(visibleItems)
            }
        } catch {
            items = visibleItems
            state = .nextPageError(items: visibleItems, error: error)
        }
    }

    /// Marks a row as selected, replacing any previous selection.
    @MainActor
    public func select(item: Entity) {
        selectedItem = item
    }

    @MainActor
    private func visibleItems() -> [Entity]? {
        switch state {
        case .loadedResults(let loadedItems):
            return loadedItems
        case .loadingNextPage(let loadedItems):
            return loadedItems
        case .nextPageError(let loadedItems, _):
            return loadedItems
        default:
            return nil
        }
    }

    private func normalized(_ searchTerm: String) -> String? {
        let trimmed = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func id(for item: Entity) -> AnyHashable {
        AnyHashable(item.id)
    }
}
