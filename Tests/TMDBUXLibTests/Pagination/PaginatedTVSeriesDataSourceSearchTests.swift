import Testing
@testable import TMDBUXLib

@Test("nextPage returns first page for valid search term")
func paginatedTVSeriesDataSourceReturnsFirstPageForValidTerm() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let firstFixture = try TVSeriesPageFixtures.page(number: 1, totalPages: 2, ids: [101, 102])
    await clientSpy.enqueueResponse(firstFixture.payload)

    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        includeAdult: nil,
        firstAirDateYear: nil
    )
    dataSource.searchTerm = "Star Trek"

    let firstPage = try await dataSource.nextPage()

    expectTVSeriesPage(firstPage, ids: [101, 102])
    #expect(dataSource.state == .morePages)

    let requests = await clientSpy.requests()
    #expect(requests.count == 1)
    expectRequest(requests[0], query: "Star Trek", page: 1)
}

@Test("nextPage progresses through pages in order")
func paginatedTVSeriesDataSourceProgressesThroughPages() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let firstFixture = try TVSeriesPageFixtures.page(number: 1, totalPages: 3, ids: [1, 2])
    let secondFixture = try TVSeriesPageFixtures.page(number: 2, totalPages: 3, ids: [3, 4])
    let thirdFixture = try TVSeriesPageFixtures.page(number: 3, totalPages: 3, ids: [5, 6])
    await clientSpy.enqueueResponse(firstFixture.payload)
    await clientSpy.enqueueResponse(secondFixture.payload)
    await clientSpy.enqueueResponse(thirdFixture.payload)

    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        includeAdult: nil,
        firstAirDateYear: nil
    )
    dataSource.searchTerm = "The Office"

    expectTVSeriesPage(try await dataSource.nextPage(), ids: [1, 2])
    #expect(dataSource.state == .morePages)
    expectTVSeriesPage(try await dataSource.nextPage(), ids: [3, 4])
    #expect(dataSource.state == .morePages)
    expectTVSeriesPage(try await dataSource.nextPage(), ids: [5, 6])
    #expect(dataSource.state == .noMorePage)

    let requests = await clientSpy.requests()
    #expect(requests.count == 3)
    expectRequest(requests[0], query: "The Office", page: 1)
    expectRequest(requests[1], query: "The Office", page: 2)
    expectRequest(requests[2], query: "The Office", page: 3)
}

@Test("nextPage returns noMorePages repeatedly after exhaustion")
func paginatedTVSeriesDataSourceReturnsNoMorePagesAfterExhaustion() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let singleFixture = try TVSeriesPageFixtures.page(number: 1, totalPages: 1, ids: [42])
    await clientSpy.enqueueResponse(singleFixture.payload)

    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        includeAdult: nil,
        firstAirDateYear: nil
    )
    dataSource.searchTerm = "Dark"

    expectTVSeriesPage(try await dataSource.nextPage(), ids: [42])
    expectNoMoreTVSeriesPages(try await dataSource.nextPage())
    expectNoMoreTVSeriesPages(try await dataSource.nextPage())

    let requests = await clientSpy.requests()
    #expect(requests.count == 1)
}

@Test("successful empty page is returned as .page([])")
func paginatedTVSeriesDataSourceTreatsEmptyPageAsSuccess() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let emptyFixture = try TVSeriesPageFixtures.page(number: 1, totalPages: 1, ids: [])
    await clientSpy.enqueueResponse(emptyFixture.payload)

    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        includeAdult: nil,
        firstAirDateYear: nil
    )
    dataSource.searchTerm = "Unknown"

    expectTVSeriesPage(try await dataSource.nextPage(), ids: [])
    #expect(dataSource.state == .noMorePage)
}
