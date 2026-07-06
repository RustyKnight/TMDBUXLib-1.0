import Testing
@testable import TMDBUXLib

private struct PaginationEntity: Identifiable, Equatable {
    let id: Int
}

@Test("loadNextPageIfNeeded appends next-page entities in order at end-of-list")
@MainActor
func paginationAppendsWhenTriggeredAtListEnd() async {
    let firstPage = [PaginationEntity(id: 1), PaginationEntity(id: 2)]
    let secondPage = [PaginationEntity(id: 3), PaginationEntity(id: 4)]
    let dataSource = InMemorySearchablePaginatedDataSource(
        refreshResult: .success(.page(firstPage)),
        refreshState: .morePages,
        nextPageResults: [.success(.page(secondPage))],
        nextPageStates: [.noMorePage]
    )
    let model = SearchViewModel(dataSource: dataSource)
    model.searchTerm = "Batman"
    await model.submitSearch()

    await model.loadNextPageIfNeeded(currentItem: firstPage[0])
    #expect(dataSource.nextPageCallCount == 0)

    await model.loadNextPageIfNeeded(currentItem: firstPage[1])
    #expect(dataSource.nextPageCallCount == 1)

    guard case .loadedResults(let loadedItems) = model.state else {
        Issue.record("Expected .loadedResults after successful next page")
        return
    }
    #expect(loadedItems == firstPage + secondPage)
}
