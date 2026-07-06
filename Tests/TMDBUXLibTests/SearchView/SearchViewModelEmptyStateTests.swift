import Testing
@testable import TMDBUXLib

private struct EmptyEntity: Identifiable {
    let id: Int
}

@Test("empty first-page payload maps to loadedEmpty state")
@MainActor
func emptyFirstPageMapsToLoadedEmpty() async {
    let dataSource = InMemorySearchablePaginatedDataSource<EmptyEntity>(
        refreshResult: .success(.page([])),
        refreshState: .noMorePage
    )
    let model = SearchViewModel(dataSource: dataSource)
    model.searchTerm = "No Hits"

    await model.submitSearch()

    guard case .loadedEmpty = model.state else {
        Issue.record("Expected .loadedEmpty for empty first page")
        return
    }

    #expect(dataSource.refreshCallCount == 1)
}
