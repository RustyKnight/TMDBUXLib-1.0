import Testing
@testable import TMDBUXLib

private struct SelectionEntity: Identifiable, Equatable {
    let id: Int
}

@Test("select(item:) keeps exactly one selected item")
@MainActor
func selectItemReplacesPreviousSelection() async {
    let firstPage = [SelectionEntity(id: 1), SelectionEntity(id: 2)]
    let dataSource = InMemorySearchablePaginatedDataSource(
        refreshResult: .success(.page(firstPage)),
        refreshState: .noMorePage
    )
    let model = SearchViewModel(dataSource: dataSource)
    model.searchTerm = "Selectables"
    await model.submitSearch()

    model.select(item: firstPage[0])
    #expect(model.selectedItem == firstPage[0])

    model.select(item: firstPage[1])
    #expect(model.selectedItem == firstPage[1])
}
