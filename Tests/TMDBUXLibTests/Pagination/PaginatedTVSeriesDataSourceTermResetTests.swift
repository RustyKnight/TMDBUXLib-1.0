import Testing
@testable import TMDBUXLib

@Test("changing searchTerm resets state to beforeFirstPage")
func paginatedTVSeriesDataSourceResetsStateWhenSearchTermChanges() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let termAPage1 = try TVSeriesPageFixtures.page(number: 1, totalPages: 2, ids: [11, 12])
    await clientSpy.enqueueResponse(termAPage1.payload)

    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        includeAdult: nil,
        firstAirDateYear: nil
    )

    dataSource.searchTerm = "Term A"
    _ = try await dataSource.nextPage()
    #expect(dataSource.state == .morePages)

    dataSource.searchTerm = "Term B"
    #expect(dataSource.state == .beforeFirstPage)
}

@Test("changing term discards old session and restarts from page one")
func paginatedTVSeriesDataSourceRestartsFromPageOneForNewTerm() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let termAPage1 = try TVSeriesPageFixtures.page(number: 1, totalPages: 3, ids: [21, 22])
    let termBPage1 = try TVSeriesPageFixtures.page(number: 1, totalPages: 1, ids: [31, 32])
    await clientSpy.enqueueResponse(termAPage1.payload)
    await clientSpy.enqueueResponse(termBPage1.payload)

    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        includeAdult: nil,
        firstAirDateYear: nil
    )

    dataSource.searchTerm = "Old Term"
    expectTVSeriesPage(try await dataSource.nextPage(), ids: [21, 22])

    dataSource.searchTerm = "New Term"
    expectTVSeriesPage(try await dataSource.nextPage(), ids: [31, 32])

    let requests = await clientSpy.requests()
    #expect(requests.count == 2)
    expectRequest(requests[0], query: "Old Term", page: 1)
    expectRequest(requests[1], query: "New Term", page: 1)
}

@Test("refresh resets current term pagination and loads page one")
func paginatedTVSeriesDataSourceRefreshRestartsCurrentTerm() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let page1 = try TVSeriesPageFixtures.page(number: 1, totalPages: 2, ids: [101])
    let page2 = try TVSeriesPageFixtures.page(number: 2, totalPages: 2, ids: [102])
    let refreshedPage1 = try TVSeriesPageFixtures.page(number: 1, totalPages: 2, ids: [201])
    await clientSpy.enqueueResponse(page1.payload)
    await clientSpy.enqueueResponse(page2.payload)
    await clientSpy.enqueueResponse(refreshedPage1.payload)

    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        includeAdult: nil,
        firstAirDateYear: nil
    )
    dataSource.searchTerm = "Refreshable"

    expectTVSeriesPage(try await dataSource.nextPage(), ids: [101])
    expectTVSeriesPage(try await dataSource.nextPage(), ids: [102])
    expectTVSeriesPage(try await dataSource.refresh(), ids: [201])

    let requests = await clientSpy.requests()
    #expect(requests.count == 3)
    expectRequest(requests[0], query: "Refreshable", page: 1)
    expectRequest(requests[1], query: "Refreshable", page: 2)
    expectRequest(requests[2], query: "Refreshable", page: 1)
}
