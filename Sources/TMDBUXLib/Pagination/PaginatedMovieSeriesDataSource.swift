import Foundation
import TMDBLib

public enum PaginatedMovieSeriesDataSourceError: Error, Equatable {
    case missingSearchTerm
}

public protocol PaginatedMovieSeriesDataSource: PaginatedDataSource
where Entity == MovieListResult {
    init(
        tmdbClient: TMDBClient,
        language: String?,
        region: String?,
        includeAdult: Bool?,
        firstAirDateYear: Int?,
        primaryReleaseYear: Int?
    )

    var searchTerm: String? { get set }
}

public final class TMDBPaginatedMovieSeriesDataSource: PaginatedMovieSeriesDataSource {
    public typealias Entity = MovieListResult

    private struct SearchRequest {
        let query: String
        let page: Int
        let language: String?
        let region: String?
        let includeAdult: Bool?
        let firstAirDateYear: Int?
        let primaryReleaseYear: Int?
    }

    private let tmdbClient: TMDBClient
    private let language: String?
    private let region: String?
    private let includeAdult: Bool?
    private let firstAirDateYear: Int?
    private let primaryReleaseYear: Int?

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
        region: String? = nil,
        includeAdult: Bool? = nil,
        firstAirDateYear: Int? = nil,
        primaryReleaseYear: Int? = nil
    ) {
        self.tmdbClient = tmdbClient
        self.language = language
        self.region = region
        self.includeAdult = includeAdult
        self.firstAirDateYear = firstAirDateYear
        self.primaryReleaseYear = primaryReleaseYear
    }

    public func nextPage() async throws -> PageResult<MovieListResult> {
        let query = try validatedSearchTerm()

        if let totalPages = lastKnownTotalPages, nextPageIndex > totalPages {
            state = .noMorePage
            return .noMorePages
        }

        isLoading = true
        defer { isLoading = false }

        let request = makeSearchRequest(query: query, page: nextPageIndex)
        let response = try await tmdbClient.searchMovies(
            query: request.query,
            page: request.page,
            language: request.language,
            region: request.region,
            includeAdult: request.includeAdult,
            year: request.firstAirDateYear,
            primaryReleaseYear: request.primaryReleaseYear
        )

        lastKnownTotalPages = response.totalPages
        nextPageIndex = response.page + 1
        state = response.page < response.totalPages ? .morePages : .noMorePage

        return .page(response.results)
    }

    public func refresh() async throws -> PageResult<MovieListResult> {
        _ = try validatedSearchTerm()
        resetPaginationState()
        return try await nextPage()
    }

    private func makeSearchRequest(query: String, page: Int) -> SearchRequest {
        SearchRequest(
            query: query,
            page: page,
            language: language,
            region: region,
            includeAdult: includeAdult,
            firstAirDateYear: firstAirDateYear,
            primaryReleaseYear: primaryReleaseYear
        )
    }

    private func validatedSearchTerm() throws -> String {
        guard let searchTerm = normalized(searchTerm) else {
            throw PaginatedMovieSeriesDataSourceError.missingSearchTerm
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
