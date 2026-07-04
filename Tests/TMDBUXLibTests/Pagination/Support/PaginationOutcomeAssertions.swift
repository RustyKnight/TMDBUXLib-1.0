import Testing
@testable import TMDBUXLib

func expectPageOutcome<Entity: Equatable>(
    _ outcome: PageResult<Entity>,
    entities expectedEntities: [Entity]
) {
    switch outcome {
    case .page(let entities):
        #expect(entities == expectedEntities)
    case .noMorePages:
        Issue.record("Expected page outcome but received .noMorePages")
    }
}

func expectNoMorePages<Entity>(_ outcome: PageResult<Entity>) {
    switch outcome {
    case .page(let entities):
        Issue.record("Expected .noMorePages but received page: \(entities)")
    case .noMorePages:
        #expect(Bool(true))
    }
}
