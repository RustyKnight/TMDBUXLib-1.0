import Testing
@testable import TMDBUXLib

@Test("nextPage fails with missingSearchTerm when search term is not set")
func paginatedTVSeriesDataSourceNextPageFailsWithoutSearchTerm() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        includeAdult: nil,
        firstAirDateYear: nil
    )

    await expectMissingSearchTerm {
        try await dataSource.nextPage()
    }
}

@Test("refresh fails with missingSearchTerm when search term is not set")
func paginatedTVSeriesDataSourceRefreshFailsWithoutSearchTerm() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        includeAdult: nil,
        firstAirDateYear: nil
    )

    await expectMissingSearchTerm {
        try await dataSource.refresh()
    }
}

@Test("whitespace-only search term fails with missingSearchTerm")
func paginatedTVSeriesDataSourceWhitespaceOnlyTermFailsValidation() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        includeAdult: nil,
        firstAirDateYear: nil
    )
    dataSource.searchTerm = "   \n\t "

    await expectMissingSearchTerm {
        try await dataSource.nextPage()
    }
}

@Test("searchTerm assignment configures source without implicit I/O")
func paginatedTVSeriesDataSourceSearchTermAssignmentDoesNotFetch() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: nil,
        includeAdult: nil,
        firstAirDateYear: nil
    )

    dataSource.searchTerm = "Fargo"
    dataSource.searchTerm = "Fargo"
    dataSource.searchTerm = "   Fargo   "

    let requests = await clientSpy.requests()
    #expect(requests.isEmpty)
}
