import Testing
@testable import TMDBUXLib

@Test("nextPage forwards configured optional filters")
func paginatedMovieSeriesDataSourceNextPageForwardsFilters() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let fixture = try MoviePageFixtures.page(number: 1, totalPages: 1, ids: [88])
    await clientSpy.enqueueResponse(fixture.payload)

    let dataSource = TMDBPaginatedMovieSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: "es-ES",
        region: "ES",
        includeAdult: true,
        firstAirDateYear: 2016,
        primaryReleaseYear: 2016
    )
    dataSource.searchTerm = "Casa"

    expectMoviePage(try await dataSource.nextPage(), ids: [88])

    let requests = await clientSpy.requests()
    #expect(requests.count == 1)
    expectMovieRequest(
        requests[0],
        query: "Casa",
        page: 1,
        language: "es-ES",
        region: "ES",
        includeAdult: true,
        firstAirDateYear: 2016,
        primaryReleaseYear: 2016
    )
}

@Test("filters persist across multi-page traversal")
func paginatedMovieSeriesDataSourceFiltersPersistAcrossPages() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let first = try MoviePageFixtures.page(number: 1, totalPages: 2, ids: [1])
    let second = try MoviePageFixtures.page(number: 2, totalPages: 2, ids: [2])
    await clientSpy.enqueueResponse(first.payload)
    await clientSpy.enqueueResponse(second.payload)

    let dataSource = TMDBPaginatedMovieSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: "fr-FR",
        region: "FR",
        includeAdult: false,
        firstAirDateYear: 2020,
        primaryReleaseYear: 2020
    )
    dataSource.searchTerm = "Lupin"

    _ = try await dataSource.nextPage()
    _ = try await dataSource.nextPage()

    let requests = await clientSpy.requests()
    #expect(requests.count == 2)
    expectMovieRequest(
        requests[0],
        query: "Lupin",
        page: 1,
        language: "fr-FR",
        region: "FR",
        includeAdult: false,
        firstAirDateYear: 2020,
        primaryReleaseYear: 2020
    )
    expectMovieRequest(
        requests[1],
        query: "Lupin",
        page: 2,
        language: "fr-FR",
        region: "FR",
        includeAdult: false,
        firstAirDateYear: 2020,
        primaryReleaseYear: 2020
    )
}

@Test("refresh forwards configured optional filters")
func paginatedMovieSeriesDataSourceRefreshForwardsFilters() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let first = try MoviePageFixtures.page(number: 1, totalPages: 2, ids: [1])
    let refreshed = try MoviePageFixtures.page(number: 1, totalPages: 2, ids: [3])
    await clientSpy.enqueueResponse(first.payload)
    await clientSpy.enqueueResponse(refreshed.payload)

    let dataSource = TMDBPaginatedMovieSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: "de-DE",
        region: "DE",
        includeAdult: false,
        firstAirDateYear: 2015,
        primaryReleaseYear: 2015
    )
    dataSource.searchTerm = "Dark"

    _ = try await dataSource.nextPage()
    _ = try await dataSource.refresh()

    let requests = await clientSpy.requests()
    #expect(requests.count == 2)
    expectMovieRequest(
        requests[0],
        query: "Dark",
        page: 1,
        language: "de-DE",
        region: "DE",
        includeAdult: false,
        firstAirDateYear: 2015,
        primaryReleaseYear: 2015
    )
    expectMovieRequest(
        requests[1],
        query: "Dark",
        page: 1,
        language: "de-DE",
        region: "DE",
        includeAdult: false,
        firstAirDateYear: 2015,
        primaryReleaseYear: 2015
    )
}
