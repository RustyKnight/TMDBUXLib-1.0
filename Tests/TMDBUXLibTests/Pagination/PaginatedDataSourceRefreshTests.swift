import Testing

@Test("refresh resets pagination and returns first page")
func paginatedDataSourceRefreshReturnsFirstPageAfterProgress() async {
    let dataSource = InMemoryPaginatedDataSource.orderedPages([
        [1, 2],
        [3, 4],
    ])

    _ = await dataSource.nextPage()
    let refreshed = await dataSource.refresh()
    let next = await dataSource.nextPage()

    expectPageOutcome(refreshed, entities: [1, 2])
    expectPageOutcome(next, entities: [3, 4])
}

@Test("refresh from exhausted source reloads first page")
func paginatedDataSourceRefreshReloadsFirstPageFromTerminalState() async {
    let dataSource = InMemoryPaginatedDataSource.orderedPages([
        [42],
    ])

    _ = await dataSource.nextPage()
    expectNoMorePages(await dataSource.nextPage())

    let refreshed = await dataSource.refresh()

    expectPageOutcome(refreshed, entities: [42])
    #expect(!dataSource.hasMorePages)
    #expect(dataSource.hasLoadedResults)
    #expect(!dataSource.isLoading)
}
