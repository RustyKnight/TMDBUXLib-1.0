import Testing
@testable import TMDBUXLib

private struct ResultsEntity: Identifiable, Equatable {
    let id: Int
}

@Test("first-page page payload maps to loadedResults state")
@MainActor
func firstPageResultsMapToLoadedResults() async {
    let firstPage = [ResultsEntity(id: 1), ResultsEntity(id: 2)]
    let dataSource = InMemorySearchablePaginatedDataSource(
        refreshResult: .success(.page(firstPage)),
        refreshState: .morePages
    )
    let model = SearchViewModel(dataSource: dataSource)
    model.searchTerm = "Query"

    await model.submitSearch()

    guard case .loadedResults(let loadedItems) = model.state else {
        Issue.record("Expected .loadedResults")
        return
    }

    #expect(loadedItems == firstPage)
}

@Test("new valid search clears previous selection before loading results")
@MainActor
func newValidSearchClearsSelection() async {
    let firstPage = [ResultsEntity(id: 1), ResultsEntity(id: 2)]
    let secondPage = [ResultsEntity(id: 3)]
    let dataSource = InMemorySearchablePaginatedDataSource(
        refreshResult: .success(.page(firstPage)),
        refreshState: .noMorePage
    )
    let model = SearchViewModel(dataSource: dataSource)
    model.searchTerm = "First"

    await model.submitSearch()
    model.select(item: firstPage[0])
    #expect(model.selectedItem == firstPage[0])

    dataSource.updateRefreshResult(.success(.page(secondPage)), state: .noMorePage)
    model.searchTerm = "Second"
    await model.submitSearch()

    #expect(model.selectedItem == nil)
    guard case .loadedResults(let loadedItems) = model.state else {
        Issue.record("Expected .loadedResults for second valid search")
        return
    }
    #expect(loadedItems == secondPage)
}
