import Testing

@Test("hasMorePages transitions from true to false when exhausted")
func paginatedDataSourceHasMorePagesTransitionsAtExhaustion() async {
    let dataSource = InMemoryPaginatedDataSource.orderedPages([
        [1],
        [2],
    ])

    #expect(dataSource.hasMorePages)
    _ = await dataSource.nextPage()
    #expect(dataSource.hasMorePages)
    _ = await dataSource.nextPage()
    #expect(!dataSource.hasMorePages)
}

@Test("isLoading is false before and after each load")
func paginatedDataSourceIsLoadingResetsAfterRequest() async {
    let dataSource = InMemoryPaginatedDataSource.orderedPages([
        [1],
    ])

    #expect(!dataSource.isLoading)
    _ = await dataSource.nextPage()
    #expect(!dataSource.isLoading)
    _ = await dataSource.nextPage()
    #expect(!dataSource.isLoading)
}

@Test("hasLoadedResults distinguishes not-yet-loaded from exhausted")
func paginatedDataSourceTracksInitialAndAttemptedLoadState() async {
    let dataSource = InMemoryPaginatedDataSource<Int>.orderedPages([])

    #expect(!dataSource.hasMorePages)
    #expect(!dataSource.hasLoadedResults)

    let outcome = await dataSource.nextPage()
    expectNoMorePages(outcome)

    #expect(!dataSource.hasMorePages)
    #expect(dataSource.hasLoadedResults)
}
