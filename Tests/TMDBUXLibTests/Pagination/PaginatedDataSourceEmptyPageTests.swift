import Testing

@Test("Empty page is returned as valid page outcome")
func paginatedDataSourceTreatsEmptyPageAsValidResult() async throws {
    let dataSource = InMemoryPaginatedDataSource.orderedPages([
        [],
        [99],
    ])

    let first = try await dataSource.nextPage()
    let second = try await dataSource.nextPage()

    expectPageOutcome(first, entities: [])
    expectPageOutcome(second, entities: [99])
}
