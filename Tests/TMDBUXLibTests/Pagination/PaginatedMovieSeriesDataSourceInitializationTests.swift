import Testing
@testable import TMDBUXLib

@Test("Movie paginated source initializes with expected base state")
func paginatedMovieSeriesDataSourceInitialization() async throws {
    let clientSpy = TMDBSearchMoviesClientSpy()
    let dataSource = TMDBPaginatedMovieSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: "en-US",
        region: "US",
        includeAdult: false,
        firstAirDateYear: 2024,
        primaryReleaseYear: 2024
    )

    #expect(dataSource.state == .beforeFirstPage)
    #expect(!dataSource.isLoading)
    #expect(dataSource.searchTerm == nil)
}
