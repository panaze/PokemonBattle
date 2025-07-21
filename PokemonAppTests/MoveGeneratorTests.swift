import XCTest
@testable import PokemonApp

class MoveGeneratorTests: XCTestCase {
    func testMoveGenerationForDifferentTypes() {
        // Different Pokemon types
        let fireType = "fire"
        let waterType = "water"
        let unknownType = "unknown"
        // Generate moves for each type
        let fireMoves = MoveGenerator.generateMoves(for: fireType)
        let waterMoves = MoveGenerator.generateMoves(for: waterType)
        let unknownMoves = MoveGenerator.generateMoves(for: unknownType)
        // Should always generate exactly 4 moves
        XCTAssertEqual(fireMoves.count, 4)
        XCTAssertEqual(waterMoves.count, 4)
        XCTAssertEqual(unknownMoves.count, 4)
        // Fire moves should include type-specific moves
        let fireMoveNames = fireMoves.map { $0.name }
        XCTAssertTrue(fireMoveNames.contains("Fire Attack"))
        XCTAssertTrue(fireMoveNames.contains("Tackle"))
        XCTAssertTrue(fireMoveNames.contains("Quick Attack"))
        XCTAssertTrue(fireMoveNames.contains("Rest"))
        // Water moves should include type-specific moves
        let waterMoveNames = waterMoves.map { $0.name }
        XCTAssertTrue(waterMoveNames.contains("Water Attack"))
        // Unknown type should default to normal type moves
        let unknownMoveNames = unknownMoves.map { $0.name }
        XCTAssertTrue(unknownMoveNames.contains("Normal Attack"))
    }
}
