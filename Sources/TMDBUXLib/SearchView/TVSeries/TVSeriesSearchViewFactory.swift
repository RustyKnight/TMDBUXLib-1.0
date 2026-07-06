import SwiftUI
import TMDBLib

/// Default `SearchViewFactory` for TV series search results.
public struct TVSeriesSearchViewFactory: SearchViewFactory {
    public typealias Entity = TVSeriesListResult

    /// Placeholder prompt shown in the search field.
    public let searchPrompt: String

    /// Creates a TV series search factory with an optional custom prompt.
    public init(searchPrompt: String = "Search TV Series") {
        self.searchPrompt = searchPrompt
    }

    @ViewBuilder
    public func makeInitialView() -> some View {
        EmptyView()
    }

    @ViewBuilder
    public func makeEmptyResultsView() -> some View {
        VStack {
            Spacer()
            Text("No TV Series found matching your query.")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    @ViewBuilder
    public func makeInitialSearchErrorView(error: Error) -> some View {
        EmptyView()
    }

    @ViewBuilder
    public func makeRowView(item: TVSeriesListResult, isSelected: Bool) -> some View {
        EmptyView()
    }
}
