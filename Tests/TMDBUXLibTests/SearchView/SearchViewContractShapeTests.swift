import Testing
import SwiftUI
@testable import TMDBUXLib

private struct FixtureEntity: Identifiable, Equatable {
    let id: Int
    let value: String
}

private enum ContractError: Error, Equatable {
    case sample
}

@Test("SearchViewState exposes required contract cases")
func searchViewStateContractCasesCompile() {
    let states: [SearchViewState<FixtureEntity>] = [
        .noSearch,
        .loadingFirstPage,
        .loadedResults([FixtureEntity(id: 1, value: "A")]),
        .loadedEmpty,
        .loadingNextPage([FixtureEntity(id: 2, value: "B")]),
        .nextPageError(items: [FixtureEntity(id: 3, value: "C")], error: ContractError.sample),
        .initialSearchError(ContractError.sample),
    ]

    #expect(states.count == 7)
}

@Test("SearchViewFactory and SearchViewModel contract shapes are usable")
@MainActor
func searchViewFactoryAndModelContractsCompile() async {
    let dataSource = InMemorySearchablePaginatedDataSource<FixtureEntity>(
        refreshResult: .success(.page([]))
    )
    let model = SearchViewModel(dataSource: dataSource)
    let factory = SearchViewFactorySpy<FixtureEntity>(searchPrompt: "Find")
    let _: SearchView<SearchViewModel<InMemorySearchablePaginatedDataSource<FixtureEntity>>, SearchViewFactorySpy<FixtureEntity>> =
        SearchView(viewModel: model, factory: factory)

    #expect(model.searchTerm == "")
    #expect(factory.searchPrompt == "Find")
}
