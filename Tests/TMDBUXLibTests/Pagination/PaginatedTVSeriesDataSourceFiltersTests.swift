import Testing
@testable import TMDBUXLib

@Test("nextPage forwards configured optional filters")
func paginatedTVSeriesDataSourceNextPageForwardsFilters() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let fixture = try TVSeriesPageFixtures.page(number: 1, totalPages: 1, ids: [88])
    await clientSpy.enqueueResponse(fixture.payload)

    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: "es-ES",
        includeAdult: true,
        firstAirDateYear: 2016
    )
    dataSource.searchTerm = "Casa"

    expectTVSeriesPage(try await dataSource.nextPage(), ids: [88])

    let requests = await clientSpy.requests()
    #expect(requests.count == 1)
    expectRequest(
        requests[0],
        query: "Casa",
        page: 1,
        language: "es-ES",
        includeAdult: true,
        firstAirDateYear: 2016
    )
}

@Test("filters persist across multi-page traversal")
func paginatedTVSeriesDataSourceFiltersPersistAcrossPages() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let first = try TVSeriesPageFixtures.page(number: 1, totalPages: 2, ids: [1])
    let second = try TVSeriesPageFixtures.page(number: 2, totalPages: 2, ids: [2])
    await clientSpy.enqueueResponse(first.payload)
    await clientSpy.enqueueResponse(second.payload)

    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: "fr-FR",
        includeAdult: false,
        firstAirDateYear: 2020
    )
    dataSource.searchTerm = "Lupin"

    _ = try await dataSource.nextPage()
    _ = try await dataSource.nextPage()

    let requests = await clientSpy.requests()
    #expect(requests.count == 2)
    expectRequest(
        requests[0],
        query: "Lupin",
        page: 1,
        language: "fr-FR",
        includeAdult: false,
        firstAirDateYear: 2020
    )
    expectRequest(
        requests[1],
        query: "Lupin",
        page: 2,
        language: "fr-FR",
        includeAdult: false,
        firstAirDateYear: 2020
    )
}

@Test("refresh forwards configured optional filters")
func paginatedTVSeriesDataSourceRefreshForwardsFilters() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let first = try TVSeriesPageFixtures.page(number: 1, totalPages: 2, ids: [1])
    let refreshed = try TVSeriesPageFixtures.page(number: 1, totalPages: 2, ids: [3])
    await clientSpy.enqueueResponse(first.payload)
    await clientSpy.enqueueResponse(refreshed.payload)

    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: "de-DE",
        includeAdult: false,
        firstAirDateYear: 2015
    )
    dataSource.searchTerm = "Dark"

    _ = try await dataSource.nextPage()
    _ = try await dataSource.refresh()

    let requests = await clientSpy.requests()
    #expect(requests.count == 2)
    expectRequest(
        requests[0],
        query: "Dark",
        page: 1,
        language: "de-DE",
        includeAdult: false,
        firstAirDateYear: 2015
    )
    expectRequest(
        requests[1],
        query: "Dark",
        page: 1,
        language: "de-DE",
        includeAdult: false,
        firstAirDateYear: 2015
    )
}
