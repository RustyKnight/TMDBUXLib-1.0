import Testing

@Test("Exhausted pagination returns noMorePages repeatedly")
func paginatedDataSourceStaysTerminalAfterExhaustion() async throws {
    let dataSource = InMemoryPaginatedDataSource.orderedPages([
        [42],
    ])

    _ = try await dataSource.nextPage()
    let firstTerminal = try await dataSource.nextPage()
    let secondTerminal = try await dataSource.nextPage()

    expectNoMorePages(firstTerminal)
    expectNoMorePages(secondTerminal)
}
