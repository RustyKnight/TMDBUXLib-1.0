import Testing
@testable import TMDBUXLib

@Test("changing searchTerm resets state to beforeFirstPage")
func paginatedMovieSeriesDataSourceResetsStateWhenSearchTermChanges() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let termAPage1 = try MoviePageFixtures.page(number: 1, totalPages: 2, ids: [11, 12])
    await clientSpy.enqueueResponse(termAPage1.payload)

    let dataSource = TMDBPaginatedMovieDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        region: nil,
        includeAdult: nil,
        firstAirDateYear: nil,
        primaryReleaseYear: nil
    )

    dataSource.searchTerm = "Term A"
    _ = try await dataSource.nextPage()
    #expect(dataSource.state == .morePages)

    dataSource.searchTerm = "Term B"
    #expect(dataSource.state == .beforeFirstPage)
}

@Test("changing term discards old session and restarts from page one")
func paginatedMovieSeriesDataSourceRestartsFromPageOneForNewTerm() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let termAPage1 = try MoviePageFixtures.page(number: 1, totalPages: 3, ids: [21, 22])
    let termBPage1 = try MoviePageFixtures.page(number: 1, totalPages: 1, ids: [31, 32])
    await clientSpy.enqueueResponse(termAPage1.payload)
    await clientSpy.enqueueResponse(termBPage1.payload)

    let dataSource = TMDBPaginatedMovieDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        region: nil,
        includeAdult: nil,
        firstAirDateYear: nil,
        primaryReleaseYear: nil
    )

    dataSource.searchTerm = "Old Term"
    expectMoviePage(try await dataSource.nextPage(), ids: [21, 22])

    dataSource.searchTerm = "New Term"
    expectMoviePage(try await dataSource.nextPage(), ids: [31, 32])

    let requests = await clientSpy.requests()
    #expect(requests.count == 2)
    expectMovieRequest(requests[0], query: "Old Term", page: 1)
    expectMovieRequest(requests[1], query: "New Term", page: 1)
}

@Test("refresh resets current term pagination and loads page one")
func paginatedMovieSeriesDataSourceRefreshRestartsCurrentTerm() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let page1 = try MoviePageFixtures.page(number: 1, totalPages: 2, ids: [101])
    let page2 = try MoviePageFixtures.page(number: 2, totalPages: 2, ids: [102])
    let refreshedPage1 = try MoviePageFixtures.page(number: 1, totalPages: 2, ids: [201])
    await clientSpy.enqueueResponse(page1.payload)
    await clientSpy.enqueueResponse(page2.payload)
    await clientSpy.enqueueResponse(refreshedPage1.payload)

    let dataSource = TMDBPaginatedMovieDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        region: nil,
        includeAdult: nil,
        firstAirDateYear: nil,
        primaryReleaseYear: nil
    )
    dataSource.searchTerm = "Refreshable"

    expectMoviePage(try await dataSource.nextPage(), ids: [101])
    expectMoviePage(try await dataSource.nextPage(), ids: [102])
    expectMoviePage(try await dataSource.refresh(), ids: [201])

    let requests = await clientSpy.requests()
    #expect(requests.count == 3)
    expectMovieRequest(requests[0], query: "Refreshable", page: 1)
    expectMovieRequest(requests[1], query: "Refreshable", page: 2)
    expectMovieRequest(requests[2], query: "Refreshable", page: 1)
}
