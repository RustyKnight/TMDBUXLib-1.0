import SwiftUI
import TMDBLib

private struct TMDBClientEnvironmentKey: EnvironmentKey {
    static let defaultValue: TMDBClient? = nil
}

public extension EnvironmentValues {
    /// `TMDBClient` provided by `SearchView` for row and child-content composition.
    /// Accessing this value without a containing `SearchView` is a programmer error.
    var tmdbClient: TMDBClient {
        get {
            guard let client = self[TMDBClientEnvironmentKey.self] else {
                preconditionFailure("TMDBClient is missing from the environment.")
            }
            return client
        }
        set { self[TMDBClientEnvironmentKey.self] = newValue }
    }
}
