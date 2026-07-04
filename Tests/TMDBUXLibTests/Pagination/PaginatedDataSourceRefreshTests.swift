import Testing

@Test("refresh resets pagination and returns first page")
func paginatedDataSourceRefreshReturnsFirstPageAfterProgress() async throws {
    let dataSource = InMemoryPaginatedDataSource.orderedPages([
        [1, 2],
        [3, 4],
    ])

    _ = try await dataSource.nextPage()
    let refreshed = try await dataSource.refresh()
    let next = try await dataSource.nextPage()

    expectPageOutcome(refreshed, entities: [1, 2])
    expectPageOutcome(next, entities: [3, 4])
}

@Test("refresh from exhausted source reloads first page")
func paginatedDataSourceRefreshReloadsFirstPageFromTerminalState() async throws {
    let dataSource = InMemoryPaginatedDataSource.orderedPages([
        [42],
    ])

    _ = try await dataSource.nextPage()
    expectNoMorePages(try await dataSource.nextPage())

    let refreshed = try await dataSource.refresh()

    expectPageOutcome(refreshed, entities: [42])
    #expect(!dataSource.hasMorePages)
    #expect(dataSource.hasLoadedResults)
    #expect(!dataSource.isLoading)
}
