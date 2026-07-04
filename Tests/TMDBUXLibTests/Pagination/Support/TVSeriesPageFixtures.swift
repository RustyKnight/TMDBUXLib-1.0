import Foundation
import TMDBLib

struct TVSeriesPageFixture {
    let page: Page<TVSeriesListResult>
    let payload: Data
}

enum TVSeriesPageFixtures {
    static func page(
        number: Int,
        totalPages: Int,
        ids: [Int],
        namePrefix: String = "Series"
    ) throws -> TVSeriesPageFixture {
        let results = ids.map { id in
            seriesPayload(id: id, name: "\(namePrefix)-\(id)")
        }

        let payloadObject: [String: Any] = [
            "page": number,
            "results": results,
            "total_pages": totalPages,
            "total_results": max(ids.count, totalPages * max(ids.count, 1)),
        ]

        let payload = try JSONSerialization.data(withJSONObject: payloadObject)
        let page = try JSONDecoder().decode(Page<TVSeriesListResult>.self, from: payload)
        return TVSeriesPageFixture(page: page, payload: payload)
    }

    private static func seriesPayload(id: Int, name: String) -> [String: Any] {
        [
            "id": id,
            "name": name,
            "original_name": name,
            "overview": "Overview for \(name)",
            "first_air_date": "",
            "poster_path": NSNull(),
            "backdrop_path": NSNull(),
            "genre_ids": [18],
            "original_language": "en",
            "origin_country": ["US"],
            "popularity": 1.0,
            "vote_average": 7.0,
            "vote_count": 100,
            "adult": false,
        ]
    }
}
