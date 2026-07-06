import Testing
@testable import TMDBUXLib

private struct PaginationErrorEntity: Identifiable, Equatable {
    let id: Int
}

private enum PaginationFailure: Error, Equatable {
    case nextPageFailed
}

@Test("next-page failure preserves existing results and maps to nextPageError")
@MainActor
func nextPageFailurePreservesExistingResults() async {
    let firstPage = [PaginationErrorEntity(id: 1), PaginationErrorEntity(id: 2)]
    let dataSource = InMemorySearchablePaginatedDataSource(
        refreshResult: .success(.page(firstPage)),
        refreshState: .morePages,
        nextPageResults: [.failure(PaginationFailure.nextPageFailed)],
        nextPageStates: [.morePages]
    )
    let model = SearchViewModel(dataSource: dataSource)
    model.searchTerm = "Query"

    await model.submitSearch()
    await model.loadNextPageIfNeeded(currentItem: firstPage[1])

    guard case .nextPageError(let items, let error) = model.state else {
        Issue.record("Expected .nextPageError when next-page retrieval fails")
        return
    }
    #expect(items == firstPage)
    #expect((error as? PaginationFailure) == .nextPageFailed)
}

@Test("no-more-pages guard prevents pagination request")
@MainActor
func noMorePagesGuardPreventsRequest() async {
    let firstPage = [PaginationErrorEntity(id: 10)]
    let dataSource = InMemorySearchablePaginatedDataSource(
        refreshResult: .success(.page(firstPage)),
        refreshState: .noMorePage
    )
    let model = SearchViewModel(dataSource: dataSource)
    model.searchTerm = "Static"

    await model.submitSearch()
    await model.loadNextPageIfNeeded(currentItem: firstPage[0])

    #expect(dataSource.nextPageCallCount == 0)
    guard case .loadedResults(let items) = model.state else {
        Issue.record("Expected existing loaded results to remain unchanged")
        return
    }
    #expect(items == firstPage)
}
