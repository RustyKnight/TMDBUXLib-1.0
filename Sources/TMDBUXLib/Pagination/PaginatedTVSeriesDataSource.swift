import Foundation
import TMDBLib

public enum PaginatedTVSeriesDataSourceError: Error, Equatable {
    case missingSearchTerm
}

public protocol PaginatedTVSeriesDataSource: SearchablePaginatedDataSource
where Entity == TVSeriesListResult {
    init(
        tmdbClient: TMDBClient,
        language: String?,
        includeAdult: Bool?,
        firstAirDateYear: Int?
    )
}

public final class TMDBPaginatedTVSeriesDataSource: PaginatedTVSeriesDataSource {
    public typealias Entity = TVSeriesListResult

    private struct SearchRequest {
        let query: String
        let page: Int
        let language: String?
        let includeAdult: Bool?
        let firstAirDateYear: Int?
    }

    private let tmdbClient: TMDBClient
    private let language: String?
    private let includeAdult: Bool?
    private let firstAirDateYear: Int?

    public private(set) var state: PaginationState = .beforeFirstPage
    public private(set) var isLoading: Bool = false

    private var nextPageIndex: Int = 1
    private var lastKnownTotalPages: Int?

    public var searchTerm: String? {
        didSet {
            guard normalized(searchTerm) != normalized(oldValue) else {
                return
            }
            resetPaginationState()
        }
    }

    public init(
        tmdbClient: TMDBClient,
        language: String? = nil,
        includeAdult: Bool? = nil,
        firstAirDateYear: Int? = nil
    ) {
        self.tmdbClient = tmdbClient
        self.language = language
        self.includeAdult = includeAdult
        self.firstAirDateYear = firstAirDateYear
    }

    public func nextPage() async throws -> PageResult<TVSeriesListResult> {
        let query = try validatedSearchTerm()

        if let totalPages = lastKnownTotalPages, nextPageIndex > totalPages {
            state = .noMorePage
            return .noMorePages
        }

        isLoading = true
        defer { isLoading = false }

        let request = makeSearchRequest(query: query, page: nextPageIndex)
        let response = try await tmdbClient.searchTV(
            query: request.query,
            page: request.page,
            language: request.language,
            includeAdult: request.includeAdult,
            firstAirDateYear: request.firstAirDateYear
        )

        lastKnownTotalPages = response.totalPages
        nextPageIndex = response.page + 1
        state = response.page < response.totalPages ? .morePages : .noMorePage

        return .page(response.results)
    }

    public func refresh() async throws -> PageResult<TVSeriesListResult> {
        _ = try validatedSearchTerm()
        resetPaginationState()
        return try await nextPage()
    }

    private func makeSearchRequest(query: String, page: Int) -> SearchRequest {
        SearchRequest(
            query: query,
            page: page,
            language: language,
            includeAdult: includeAdult,
            firstAirDateYear: firstAirDateYear
        )
    }

    private func validatedSearchTerm() throws -> String {
        guard let searchTerm = normalized(searchTerm) else {
            throw PaginatedTVSeriesDataSourceError.missingSearchTerm
        }
        return searchTerm
    }

    private func normalized(_ value: String?) -> String? {
        guard let value else {
            return nil
        }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func resetPaginationState() {
        state = .beforeFirstPage
        nextPageIndex = 1
        lastKnownTotalPages = nil
    }
}
