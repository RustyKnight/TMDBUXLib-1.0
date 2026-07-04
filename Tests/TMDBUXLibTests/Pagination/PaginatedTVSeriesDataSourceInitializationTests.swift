import Testing
@testable import TMDBUXLib

@Test("TV series paginated source initializes with expected base state")
func paginatedTVSeriesDataSourceInitialization() async throws {
    let clientSpy = TMDBSearchTVClientSpy()
    let dataSource = TMDBPaginatedTVSeriesDataSource(
        tmdbClient: clientSpy.tmdbClient,
        language: "en-US",
        includeAdult: false,
        firstAirDateYear: 2024
    )

    #expect(dataSource.state == .beforeFirstPage)
    #expect(!dataSource.isLoading)
    #expect(dataSource.searchTerm == nil)
}
