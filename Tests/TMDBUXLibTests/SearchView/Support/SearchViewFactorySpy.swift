import SwiftUI
@testable import TMDBUXLib

struct SearchViewFactorySpy<Entity>: SearchViewFactory {
    let searchPrompt: String

    init(searchPrompt: String = "Search") {
        self.searchPrompt = searchPrompt
    }

    func makeInitialView() -> Text {
        Text("initial")
    }

    func makeEmptyResultsView() -> Text {
        Text("empty")
    }

    func makeInitialSearchErrorView(error: Error) -> Text {
        Text("error: \(error.localizedDescription)")
    }

    func makeRowView(item: Entity, isSelected: Bool) -> Text {
        Text("row-\(isSelected)")
    }
}
