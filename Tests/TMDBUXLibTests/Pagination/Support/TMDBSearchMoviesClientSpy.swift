import Foundation
import HTTPClientLib
import SupportLib
import TMDBLib

final class TMDBSearchMoviesClientSpy {
    struct Request: Equatable {
        let query: String?
        let page: Int?
        let language: String?
        let region: String?
        let includeAdult: Bool?
        let firstAirDateYear: Int?
        let primaryReleaseYear: Int?
    }

    private let backend = Backend()
    let tmdbClient: TMDBClient

    init() {
        tmdbClient = TMDBClient(
            apiKey: "test-api-key",
            httpClient: backend,
            baseURL: URL(string: "https://example.test/3")!
        )
    }

    func enqueueResponse(_ payload: Data) async {
        await backend.enqueue(payload: payload)
    }

    func requests() async -> [Request] {
        await backend.requests()
    }

    private actor Backend: HTTPClient {
        private enum BackendError: Error {
            case unsupportedMethod
            case missingResponse
        }

        private struct StubHTTPResponse: HTTPResponse {
            let url: URL
            let method: HTTPMethod
            let headers: [String: String]
            let statusCode: Int
            let body: Data?
        }

        private var payloads: [Data] = []
        private var capturedRequests: [Request] = []

        func enqueue(payload: Data) {
            payloads.append(payload)
        }

        func requests() -> [Request] {
            capturedRequests
        }

        func get(
            _ url: URL,
            headers: [String : String]?,
            progress: SupportLib.ProgressTracker?
        ) async throws -> any HTTPResponse {
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
            capturedRequests.append(
                Request(
                    query: value(named: "query", in: queryItems),
                    page: intValue(named: "page", in: queryItems),
                    language: value(named: "language", in: queryItems),
                    region: value(named: "region", in: queryItems),
                    includeAdult: boolValue(named: "include_adult", in: queryItems),
                    firstAirDateYear: intValue(named: "year", in: queryItems),
                    primaryReleaseYear: intValue(named: "primary_release_year", in: queryItems)
                )
            )

            guard !payloads.isEmpty else {
                throw BackendError.missingResponse
            }

            let payload = payloads.removeFirst()
            return StubHTTPResponse(
                url: url,
                method: .get,
                headers: headers ?? [:],
                statusCode: 200,
                body: payload
            )
        }

        func post(
            _ url: URL,
            body: RequestBody?,
            headers: [String : String]?,
            progress: SupportLib.ProgressTracker?
        ) async throws -> any HTTPResponse {
            throw BackendError.unsupportedMethod
        }

        func put(
            _ url: URL,
            body: RequestBody?,
            headers: [String : String]?,
            progress: SupportLib.ProgressTracker?
        ) async throws -> any HTTPResponse {
            throw BackendError.unsupportedMethod
        }

        func post(
            _ url: URL,
            formItems: [FormItem],
            headers: [String : String]?,
            progress: SupportLib.ProgressTracker?
        ) async throws -> any HTTPResponse {
            throw BackendError.unsupportedMethod
        }

        func delete(
            _ url: URL,
            body: RequestBody?,
            headers: [String : String]?,
            progress: SupportLib.ProgressTracker?
        ) async throws -> any HTTPResponse {
            throw BackendError.unsupportedMethod
        }

        private func value(named key: String, in queryItems: [URLQueryItem]) -> String? {
            queryItems.first(where: { $0.name == key })?.value
        }

        private func intValue(named key: String, in queryItems: [URLQueryItem]) -> Int? {
            guard let raw = value(named: key, in: queryItems) else {
                return nil
            }
            return Int(raw)
        }

        private func boolValue(named key: String, in queryItems: [URLQueryItem]) -> Bool? {
            guard let raw = value(named: key, in: queryItems) else {
                return nil
            }
            return Bool(raw)
        }
    }
}
