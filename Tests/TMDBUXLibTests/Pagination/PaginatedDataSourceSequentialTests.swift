import Testing

@Test("Sequential nextPage calls return consecutive pages")
func paginatedDataSourceReturnsSequentialPages() async throws {
    let dataSource = InMemoryPaginatedDataSource.orderedPages([
        [1, 2],
        [3, 4],
    ])

    let first = try await dataSource.nextPage()
    let second = try await dataSource.nextPage()

    expectPageOutcome(first, entities: [1, 2])
    expectPageOutcome(second, entities: [3, 4])
}
