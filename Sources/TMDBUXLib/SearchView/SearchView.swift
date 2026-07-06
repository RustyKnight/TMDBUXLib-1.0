import SwiftUI

/// Reusable search UI that binds a view model to caller-provided factory views.
public struct SearchView<Model: SearchViewModeling, Factory: SearchViewFactory>: View
where Model.Entity == Factory.Entity, Model.Entity: Identifiable {
    @ObservedObject private var viewModel: Model
    private let factory: Factory

    public init(viewModel: Model, factory: Factory) {
        self.viewModel = viewModel
        self.factory = factory
    }

    public var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                TextField(factory.searchPrompt, text: searchTermBinding)
                    .textFieldStyle(.roundedBorder)

                Button("Search") {
                    Task { @MainActor in
                        await viewModel.submitSearch()
                    }
                }
            }

            content
        }
    }

    private var searchTermBinding: Binding<String> {
        Binding(
            get: { viewModel.searchTerm },
            set: { viewModel.searchTerm = $0 }
        )
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .noSearch:
            factory.makeInitialView()

        case .loadingFirstPage:
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }

        case .loadedResults(let items):
            resultsList(items: items, showNextPageLoading: false, nextPageError: nil)

        case .loadedEmpty:
            factory.makeEmptyResultsView()

        case .loadingNextPage(let items):
            resultsList(items: items, showNextPageLoading: true, nextPageError: nil)

        case .nextPageError(let items, let error):
            resultsList(items: items, showNextPageLoading: false, nextPageError: error)

        case .initialSearchError(let error):
            factory.makeInitialSearchErrorView(error: error)
        }
    }

    @ViewBuilder
    private func resultsList(items: [Model.Entity], showNextPageLoading: Bool, nextPageError: Error?) -> some View {
        List {
            ForEach(items, id: \.id) { item in
                Button {
                    viewModel.select(item: item)
                } label: {
                    factory.makeRowView(item: item, isSelected: isSelected(item))
                }
                .buttonStyle(.plain)
                .onAppear {
                    Task { @MainActor in
                        await viewModel.loadNextPageIfNeeded(currentItem: item)
                    }
                }
            }

            if showNextPageLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }

            if let nextPageError {
                Text(nextPageError.localizedDescription)
                    .foregroundStyle(.red)
            }
        }
        .listStyle(.plain)
    }

    private func isSelected(_ item: Model.Entity) -> Bool {
        viewModel.selectedItem?.id == item.id
    }
}
