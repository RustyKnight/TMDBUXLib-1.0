import Foundation
@testable import TMDBUXLib

final class InMemoryPaginatedDataSource<Entity>: PaginatedDataSource {
    private struct PaginationSessionState {
        var nextIndex: Int
        var hasMorePages: Bool
        var isLoading: Bool
        var hasLoadedResults: Bool
    }

    private let pages: [[Entity]]
    private var state: PaginationSessionState

    var hasMorePages: Bool {
        state.hasMorePages
    }
    
    var isLoading: Bool {
        state.isLoading
    }

    var hasLoadedResults: Bool {
        state.hasLoadedResults
    }

    init(pages: [[Entity]]) {
        self.pages = pages
        self.state = PaginationSessionState(
            nextIndex: 0,
            hasMorePages: !pages.isEmpty,
            isLoading: false,
            hasLoadedResults: false
        )
    }

    static func orderedPages(_ pages: [[Entity]]) -> InMemoryPaginatedDataSource<Entity> {
        InMemoryPaginatedDataSource(pages: pages)
    }

    func nextPage() async -> PageResult<Entity> {
        state.hasLoadedResults = true
        state.isLoading = true
        defer { state.isLoading = false }

        guard state.hasMorePages else {
            return .noMorePages
        }

        guard state.nextIndex < pages.count else {
            state.hasMorePages = false
            return .noMorePages
        }

        let page = pages[state.nextIndex]
        state.nextIndex += 1
        state.hasMorePages = state.nextIndex < pages.count

        return .page(page)
    }

    func refresh() async -> PageResult<Entity> {
        state.nextIndex = 0
        state.hasMorePages = !pages.isEmpty
        return await nextPage()
    }
}
