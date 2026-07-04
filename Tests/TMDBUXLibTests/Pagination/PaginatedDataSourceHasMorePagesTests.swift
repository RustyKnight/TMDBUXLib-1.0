import Testing
@testable import TMDBUXLib

@Test("state transitions from beforeFirstPage to morePages to noMorePage")
func paginatedDataSourceStateTransitionsAtExhaustion() async throws {
    let dataSource = InMemoryPaginatedDataSource.orderedPages([
        [1],
        [2],
    ])

    #expect(dataSource.state == .beforeFirstPage)
    _ = try await dataSource.nextPage()
    #expect(dataSource.state == .morePages)
    _ = try await dataSource.nextPage()
    #expect(dataSource.state == .noMorePage)
}

@Test("isLoading is false before and after each load")
func paginatedDataSourceIsLoadingResetsAfterRequest() async throws {
    let dataSource = InMemoryPaginatedDataSource.orderedPages([
        [1],
    ])

    #expect(!dataSource.isLoading)
    _ = try await dataSource.nextPage()
    #expect(!dataSource.isLoading)
    _ = try await dataSource.nextPage()
    #expect(!dataSource.isLoading)
}

@Test("state distinguishes not-yet-loaded from exhausted when no pages exist")
func paginatedDataSourceTracksInitialAndExhaustedStateWithoutPages() async throws {
    let dataSource = InMemoryPaginatedDataSource<Int>.orderedPages([])

    #expect(dataSource.state == .beforeFirstPage)

    let outcome = try await dataSource.nextPage()
    expectNoMorePages(outcome)

    #expect(dataSource.state == .noMorePage)
}
