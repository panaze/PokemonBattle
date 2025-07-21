import XCTest
@testable import PokemonApp

class BattleServiceTests: XCTestCase {
    func testDamageCalculation() {
        // A battle service and test move
        let battleService = BattleService()
        let testMove = Move(name: "Ember", power: 30, type: "fire", description: "Test move", isSpecial: false)
        // Calculate damage without critical hit
        let normalDamage = battleService.calculateDamage(move: testMove, isCritical: false)
        // Damage should be base power + random bonus (0-10)
        XCTAssertGreaterThanOrEqual(normalDamage, 30, "Normal damage should be at least base power")
        XCTAssertLessThanOrEqual(normalDamage, 40, "Normal damage should not exceed base power + 10")
        // Calculate critical hit damage
        let criticalDamage = battleService.calculateDamage(move: testMove, isCritical: true)
        // Critical damage should be 1.5x normal damage
        XCTAssertGreaterThanOrEqual(criticalDamage, 45, "Critical damage should be at least 1.5x base power")
        XCTAssertLessThanOrEqual(criticalDamage, 60, "Critical damage should not exceed 1.5x (base power + 10)")
    }
}
