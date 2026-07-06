import SwiftUI

/// Rendering contract for a generic search view.
public protocol SearchViewFactory {
    /// The entity type produced by the search source and rendered by rows.
    associatedtype Entity
    /// View shown before the first valid search runs.
    associatedtype InitialContent: View
    /// View shown when the first search returns no items.
    associatedtype EmptyContent: View
    /// View shown when the first search fails.
    associatedtype InitialErrorContent: View
    /// View used for each result row.
    associatedtype RowContent: View

    /// Placeholder text for the search field.
    var searchPrompt: String { get }

    /// Builds the initial body content.
    @ViewBuilder func makeInitialView() -> InitialContent
    /// Builds the empty-results body content.
    @ViewBuilder func makeEmptyResultsView() -> EmptyContent
    /// Builds the initial-search error body content.
    @ViewBuilder func makeInitialSearchErrorView(error: Error) -> InitialErrorContent
    /// Builds one result row.
    @ViewBuilder func makeRowView(item: Entity, isSelected: Bool) -> RowContent
}
