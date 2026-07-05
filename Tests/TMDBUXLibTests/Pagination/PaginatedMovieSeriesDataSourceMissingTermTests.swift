import Testing
@testable import TMDBUXLib

@Test("nextPage fails with missingSearchTerm when search term is not set")
func paginatedMovieSeriesDataSourceNextPageFailsWithoutSearchTerm() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let dataSource = TMDBPaginatedMovieSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        region: nil,
        includeAdult: nil,
        firstAirDateYear: nil,
        primaryReleaseYear: nil
    )

    await expectMovieMissingSearchTerm {
        try await dataSource.nextPage()
    }
}

@Test("refresh fails with missingSearchTerm when search term is not set")
func paginatedMovieSeriesDataSourceRefreshFailsWithoutSearchTerm() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let dataSource = TMDBPaginatedMovieSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        region: nil,
        includeAdult: nil,
        firstAirDateYear: nil,
        primaryReleaseYear: nil
    )

    await expectMovieMissingSearchTerm {
        try await dataSource.refresh()
    }
}

@Test("whitespace-only search term fails with missingSearchTerm")
func paginatedMovieSeriesDataSourceWhitespaceOnlyTermFailsValidation() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let dataSource = TMDBPaginatedMovieSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        region: nil,
        includeAdult: nil,
        firstAirDateYear: nil,
        primaryReleaseYear: nil
    )
    dataSource.searchTerm = "   \n\t "

    await expectMovieMissingSearchTerm {
        try await dataSource.nextPage()
    }
}

@Test("searchTerm assignment configures source without implicit I/O")
func paginatedMovieSeriesDataSourceSearchTermAssignmentDoesNotFetch() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let dataSource = TMDBPaginatedMovieSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        region: nil,
        includeAdult: nil,
        firstAirDateYear: nil,
        primaryReleaseYear: nil
    )

    dataSource.searchTerm = "Fargo"
    dataSource.searchTerm = "Fargo"
    dataSource.searchTerm = "   Fargo   "

    let requests = await clientSpy.requests()
    #expect(requests.isEmpty)
}
