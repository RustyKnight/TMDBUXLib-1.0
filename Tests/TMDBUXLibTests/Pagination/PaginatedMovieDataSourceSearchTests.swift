import Testing
@testable import TMDBUXLib

@Test("nextPage returns first page for valid search term")
func paginatedMovieSeriesDataSourceReturnsFirstPageForValidTerm() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let firstFixture = try MoviePageFixtures.page(number: 1, totalPages: 2, ids: [101, 102])
    await clientSpy.enqueueResponse(firstFixture.payload)

    let dataSource = TMDBPaginatedMovieDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        region: nil,
        includeAdult: nil,
        firstAirDateYear: nil,
        primaryReleaseYear: nil
    )
    dataSource.searchTerm = "Star Wars"

    let firstPage = try await dataSource.nextPage()

    expectMoviePage(firstPage, ids: [101, 102])
    #expect(dataSource.state == .morePages)

    let requests = await clientSpy.requests()
    #expect(requests.count == 1)
    expectMovieRequest(requests[0], query: "Star Wars", page: 1)
}

@Test("nextPage progresses through pages in order")
func paginatedMovieSeriesDataSourceProgressesThroughPages() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let firstFixture = try MoviePageFixtures.page(number: 1, totalPages: 3, ids: [1, 2])
    let secondFixture = try MoviePageFixtures.page(number: 2, totalPages: 3, ids: [3, 4])
    let thirdFixture = try MoviePageFixtures.page(number: 3, totalPages: 3, ids: [5, 6])
    await clientSpy.enqueueResponse(firstFixture.payload)
    await clientSpy.enqueueResponse(secondFixture.payload)
    await clientSpy.enqueueResponse(thirdFixture.payload)

    let dataSource = TMDBPaginatedMovieDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        region: nil,
        includeAdult: nil,
        firstAirDateYear: nil,
        primaryReleaseYear: nil
    )
    dataSource.searchTerm = "The Matrix"

    expectMoviePage(try await dataSource.nextPage(), ids: [1, 2])
    #expect(dataSource.state == .morePages)
    expectMoviePage(try await dataSource.nextPage(), ids: [3, 4])
    #expect(dataSource.state == .morePages)
    expectMoviePage(try await dataSource.nextPage(), ids: [5, 6])
    #expect(dataSource.state == .noMorePage)

    let requests = await clientSpy.requests()
    #expect(requests.count == 3)
    expectMovieRequest(requests[0], query: "The Matrix", page: 1)
    expectMovieRequest(requests[1], query: "The Matrix", page: 2)
    expectMovieRequest(requests[2], query: "The Matrix", page: 3)
}

@Test("nextPage returns noMorePages repeatedly after exhaustion")
func paginatedMovieSeriesDataSourceReturnsNoMorePagesAfterExhaustion() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let singleFixture = try MoviePageFixtures.page(number: 1, totalPages: 1, ids: [42])
    await clientSpy.enqueueResponse(singleFixture.payload)

    let dataSource = TMDBPaginatedMovieDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        region: nil,
        includeAdult: nil,
        firstAirDateYear: nil,
        primaryReleaseYear: nil
    )
    dataSource.searchTerm = "Interstellar"

    expectMoviePage(try await dataSource.nextPage(), ids: [42])
    expectNoMoreMoviePages(try await dataSource.nextPage())
    expectNoMoreMoviePages(try await dataSource.nextPage())

    let requests = await clientSpy.requests()
    #expect(requests.count == 1)
}

@Test("successful empty page is returned as .page([])")
func paginatedMovieSeriesDataSourceTreatsEmptyPageAsSuccess() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let emptyFixture = try MoviePageFixtures.page(number: 1, totalPages: 1, ids: [])
    await clientSpy.enqueueResponse(emptyFixture.payload)

    let dataSource = TMDBPaginatedMovieDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        region: nil,
        includeAdult: nil,
        firstAirDateYear: nil,
        primaryReleaseYear: nil
    )
    dataSource.searchTerm = "Unknown"

    expectMoviePage(try await dataSource.nextPage(), ids: [])
    #expect(dataSource.state == .noMorePage)
}
