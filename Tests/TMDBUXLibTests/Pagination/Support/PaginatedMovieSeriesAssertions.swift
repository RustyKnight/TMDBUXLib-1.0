import Testing
import TMDBLib
@testable import TMDBUXLib

func expectMoviePage(
    _ outcome: PageResult<MovieListResult>,
    ids expectedIDs: [Int]
) {
    switch outcome {
    case .page(let entities):
        #expect(entities.map(\.id) == expectedIDs)
    case .noMorePages:
        Issue.record("Expected .page but received .noMorePages")
    }
}

func expectNoMoreMoviePages(
    _ outcome: PageResult<MovieListResult>
) {
    switch outcome {
    case .page(let entities):
        Issue.record("Expected .noMorePages but received page: \(entities.map(\.id))")
    case .noMorePages:
        #expect(Bool(true))
    }
}

func expectMovieMissingSearchTerm(
    _ operation: () async throws -> PageResult<MovieListResult>
) async {
    do {
        _ = try await operation()
        Issue.record("Expected missing search term error")
    } catch {
        #expect(error as? PaginatedMovieSeriesDataSourceError == .missingSearchTerm)
    }
}

func expectMovieRequest(
    _ request: TMDBSearchMoviesClientSpy.Request,
    query: String,
    page: Int,
    language: String? = nil,
    region: String? = nil,
    includeAdult: Bool? = nil,
    firstAirDateYear: Int? = nil,
    primaryReleaseYear: Int? = nil
) {
    #expect(request.query == query)
    #expect(request.page == page)
    #expect(request.language == language)
    #expect(request.region == region)
    #expect(request.includeAdult == includeAdult)
    #expect(request.firstAirDateYear == firstAirDateYear)
    #expect(request.primaryReleaseYear == primaryReleaseYear)
}
