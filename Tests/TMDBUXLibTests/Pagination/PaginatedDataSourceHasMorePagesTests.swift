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
