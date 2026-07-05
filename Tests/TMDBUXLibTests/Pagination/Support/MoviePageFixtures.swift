import Foundation

struct MoviePageFixture {
    let payload: Data
}

enum MoviePageFixtures {
    static func page(
        number: Int,
        totalPages: Int,
        ids: [Int],
        titlePrefix: String = "Movie"
    ) throws -> MoviePageFixture {
        let results = ids.map { id in
            moviePayload(id: id, title: "\(titlePrefix)-\(id)")
        }

        let payloadObject: [String: Any] = [
            "page": number,
            "results": results,
            "total_pages": totalPages,
            "total_results": max(ids.count, totalPages * max(ids.count, 1)),
        ]

        let payload = try JSONSerialization.data(withJSONObject: payloadObject)
        return MoviePageFixture(payload: payload)
    }

    private static func moviePayload(id: Int, title: String) -> [String: Any] {
        [
            "id": id,
            "title": title,
            "original_title": title,
            "overview": "Overview for \(title)",
            "release_date": "2010-07-16",
            "poster_path": NSNull(),
            "backdrop_path": NSNull(),
            "genre_ids": [18],
            "original_language": "en",
            "popularity": 1.0,
            "vote_average": 7.0,
            "vote_count": 100,
            "adult": false,
            "video": false,
        ]
    }
}
