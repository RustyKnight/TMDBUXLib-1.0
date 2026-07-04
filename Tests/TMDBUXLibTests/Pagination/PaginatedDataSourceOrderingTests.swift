import Testing

@Test("Page ordering is preserved across 3+ page retrieval")
func paginatedDataSourcePreservesPageOrdering() async {
    let expectedPages = [
        [10, 11],
        [20, 21],
        [30, 31],
    ]
    let dataSource = InMemoryPaginatedDataSource.orderedPages(expectedPages)

    var observedPages: [[Int]] = []

    for _ in 0..<expectedPages.count {
        let outcome = await dataSource.nextPage()
        switch outcome {
        case .page(let entities):
            observedPages.append(entities)
        case .noMorePages:
            Issue.record("Expected page while traversing ordered fixture.")
        }
    }

    #expect(observedPages == expectedPages)
}
