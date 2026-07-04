import Foundation
@testable import TMDBUXLib

final class InMemoryPaginatedDataSource<Entity>: PaginatedDataSource {
    private struct PaginationSessionState {
        var nextIndex: Int
        var state: PaginationState
        var isLoading: Bool
    }

    private let pages: [[Entity]]
    private var sessionState: PaginationSessionState

    var state: PaginationState {
        sessionState.state
    }
    
    var isLoading: Bool {
        sessionState.isLoading
    }

    init(pages: [[Entity]]) {
        self.pages = pages
        self.sessionState = PaginationSessionState(
            nextIndex: 0,
            state: .beforeFirstPage,
            isLoading: false
        )
    }

    static func orderedPages(_ pages: [[Entity]]) -> InMemoryPaginatedDataSource<Entity> {
        InMemoryPaginatedDataSource(pages: pages)
    }

    func nextPage() async throws -> PageResult<Entity> {
        sessionState.isLoading = true
        defer { sessionState.isLoading = false }

        guard sessionState.nextIndex < pages.count else {
            sessionState.state = .noMorePage
            return .noMorePages
        }

        let page = pages[sessionState.nextIndex]
        sessionState.nextIndex += 1
        sessionState.state = sessionState.nextIndex < pages.count ? .morePages : .noMorePage

        return .page(page)
    }

    func refresh() async throws -> PageResult<Entity> {
        sessionState.nextIndex = 0
        sessionState.state = .beforeFirstPage
        return try await nextPage()
    }
}
