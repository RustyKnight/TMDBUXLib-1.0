import Testing

@Test("Empty page is returned as valid page outcome")
func paginatedDataSourceTreatsEmptyPageAsValidResult() async {
    let dataSource = InMemoryPaginatedDataSource.orderedPages([
        [],
        [99],
    ])

    let first = await dataSource.nextPage()
    let second = await dataSource.nextPage()

    expectPageOutcome(first, entities: [])
    expectPageOutcome(second, entities: [99])
}
