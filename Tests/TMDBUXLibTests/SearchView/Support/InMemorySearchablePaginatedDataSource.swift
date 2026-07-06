import Foundation
@testable import TMDBUXLib

final class InMemorySearchablePaginatedDataSource<Entity>: SearchablePaginatedDataSource {
    typealias TimedResult = (delayNanoseconds: UInt64, result: Result<PageResult<Entity>, Error>)

    var state: PaginationState = .beforeFirstPage
    var isLoading: Bool = false
    var searchTerm: String?

    private(set) var refreshCallCount: Int = 0
    private(set) var nextPageCallCount: Int = 0
    private(set) var requestedSearchTerms: [String?] = []

    private var refreshResult: TimedResult
    private var refreshState: PaginationState
    private var nextPageResults: [TimedResult]
    private var nextPageStates: [PaginationState]

    init(
        refreshResult: Result<PageResult<Entity>, Error>,
        refreshState: PaginationState = .noMorePage,
        refreshDelayNanoseconds: UInt64 = 0,
        nextPageResults: [Result<PageResult<Entity>, Error>] = [],
        nextPageStates: [PaginationState] = [],
        nextPageDelaysNanoseconds: [UInt64] = []
    ) {
        self.refreshResult = (refreshDelayNanoseconds, refreshResult)
        self.refreshState = refreshState
        self.nextPageResults = nextPageResults.enumerated().map { index, result in
            let delay = index < nextPageDelaysNanoseconds.count ? nextPageDelaysNanoseconds[index] : 0
            return (delay, result)
        }
        self.nextPageStates = nextPageStates
    }

    func updateRefreshResult(
        _ result: Result<PageResult<Entity>, Error>,
        state: PaginationState,
        delayNanoseconds: UInt64 = 0
    ) {
        refreshResult = (delayNanoseconds, result)
        refreshState = state
    }

    func refresh() async throws -> PageResult<Entity> {
        refreshCallCount += 1
        requestedSearchTerms.append(searchTerm)
        isLoading = true
        defer { isLoading = false }

        if refreshResult.delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: refreshResult.delayNanoseconds)
        }

        state = refreshState
        return try refreshResult.result.get()
    }

    func nextPage() async throws -> PageResult<Entity> {
        nextPageCallCount += 1
        requestedSearchTerms.append(searchTerm)
        isLoading = true
        defer { isLoading = false }

        guard !nextPageResults.isEmpty else {
            state = .noMorePage
            return .noMorePages
        }

        let nextResult = nextPageResults.removeFirst()
        if nextResult.delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: nextResult.delayNanoseconds)
        }

        if !nextPageStates.isEmpty {
            state = nextPageStates.removeFirst()
        }

        return try nextResult.result.get()
    }
}
