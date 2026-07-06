import Testing
@testable import TMDBUXLib

private struct SubmitEntity: Identifiable, Equatable {
    let id: Int
    let title: String
}

@Test("submitSearch with valid term transitions through loading and uses trimmed search term")
@MainActor
func submitSearchHappyPathTransitionsToLoadedResults() async {
    let results = [SubmitEntity(id: 1, title: "Batman")]
    let dataSource = InMemorySearchablePaginatedDataSource(
        refreshResult: .success(.page(results)),
        refreshState: .noMorePage,
        refreshDelayNanoseconds: 50_000_000
    )
    let model = SearchViewModel(dataSource: dataSource)
    model.searchTerm = "  Batman  "

    let task = Task {
        await model.submitSearch()
    }

    await Task.yield()
    guard case .loadingFirstPage = model.state else {
        Issue.record("Expected .loadingFirstPage while refresh is in-flight")
        return
    }

    await task.value

    guard case .loadedResults(let loadedItems) = model.state else {
        Issue.record("Expected .loadedResults after successful refresh")
        return
    }

    #expect(loadedItems == results)
    #expect(dataSource.refreshCallCount == 1)
    #expect(dataSource.requestedSearchTerms.last ?? nil == "Batman")
}
