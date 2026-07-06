import Testing
@testable import TMDBUXLib

private struct ErrorEntity: Identifiable {
    let id: Int
}

private enum SearchModelError: Error, Equatable {
    case initialFailure
}

@Test("first-page failure maps to initialSearchError")
@MainActor
func firstPageFailureMapsToInitialSearchError() async {
    let dataSource = InMemorySearchablePaginatedDataSource<ErrorEntity>(
        refreshResult: .failure(SearchModelError.initialFailure),
        refreshState: .beforeFirstPage
    )
    let model = SearchViewModel(dataSource: dataSource)
    model.searchTerm = "Batman"

    await model.submitSearch()

    guard case .initialSearchError(let error) = model.state else {
        Issue.record("Expected .initialSearchError after refresh failure")
        return
    }
    #expect((error as? SearchModelError) == .initialFailure)
}

@Test("nil/empty/whitespace search term does not trigger refresh")
@MainActor
func invalidSearchTermDoesNotTriggerSearch() async {
    let dataSource = InMemorySearchablePaginatedDataSource<ErrorEntity>(
        refreshResult: .success(.page([]))
    )
    let model = SearchViewModel(dataSource: dataSource)

    await model.submitSearch()
    model.searchTerm = ""
    await model.submitSearch()
    model.searchTerm = "   "
    await model.submitSearch()

    #expect(dataSource.refreshCallCount == 0)
    guard case .noSearch = model.state else {
        Issue.record("Expected .noSearch to remain unchanged for invalid input")
        return
    }
}
