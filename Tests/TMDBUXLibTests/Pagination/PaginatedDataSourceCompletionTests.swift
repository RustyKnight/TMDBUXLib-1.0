import Testing

@Test("Exhausted pagination returns noMorePages repeatedly")
func paginatedDataSourceStaysTerminalAfterExhaustion() async {
    let dataSource = InMemoryPaginatedDataSource.orderedPages([
        [42],
    ])

    _ = await dataSource.nextPage()
    let firstTerminal = await dataSource.nextPage()
    let secondTerminal = await dataSource.nextPage()

    expectNoMorePages(firstTerminal)
    expectNoMorePages(secondTerminal)
}
