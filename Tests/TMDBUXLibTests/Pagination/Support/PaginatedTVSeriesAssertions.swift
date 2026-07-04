import Testing
import TMDBLib
@testable import TMDBUXLib

func expectTVSeriesPage(
    _ outcome: PageResult<TVSeriesListResult>,
    ids expectedIDs: [Int]
) {
    switch outcome {
    case .page(let entities):
        #expect(entities.map(\.id) == expectedIDs)
    case .noMorePages:
        Issue.record("Expected .page but received .noMorePages")
    }
}

func expectNoMoreTVSeriesPages(
    _ outcome: PageResult<TVSeriesListResult>
) {
    switch outcome {
    case .page(let entities):
        Issue.record("Expected .noMorePages but received page: \(entities.map(\.id))")
    case .noMorePages:
        #expect(Bool(true))
    }
}

func expectMissingSearchTerm(
    _ operation: () async throws -> PageResult<TVSeriesListResult>
) async {
    do {
        _ = try await operation()
        Issue.record("Expected missing search term error")
    } catch {
        #expect(error as? PaginatedTVSeriesDataSourceError == .missingSearchTerm)
    }
}

func expectRequest(
    _ request: TMDBSearchTVClientSpy.Request,
    query: String,
    page: Int,
    language: String? = nil,
    includeAdult: Bool? = nil,
    firstAirDateYear: Int? = nil
) {
    #expect(request.query == query)
    #expect(request.page == page)
    #expect(request.language == language)
    #expect(request.includeAdult == includeAdult)
    #expect(request.firstAirDateYear == firstAirDateYear)
}
