# TMDBUXLib

SwiftUI search and pagination helpers for TMDB result browsing.

## What’s included

- `PaginatedDataSource` and `SearchablePaginatedDataSource`
- `SearchViewState`
- `SearchViewFactory`
- `SearchViewModel`
- `SearchView`
- `TVSeriesSearchViewFactory`

## Build and test

```bash
swift build
swift test
```

## Search view usage

1. Provide a `SearchablePaginatedDataSource` for the same `Entity` type.
2. Provide a matching `SearchViewFactory`.
3. Bind a `SearchViewModel` to `SearchView`.

The TV-series example factory lives at:

`Sources/TMDBUXLib/SearchView/TVSeries/TVSeriesSearchViewFactory.swift`

## Documentation

- Feature spec: `specs/004-search-view-ui/spec.md`
- Contract: `specs/004-search-view-ui/contracts/search-view-ui-contract.md`
- Quickstart: `specs/004-search-view-ui/quickstart.md`
