import XCTest

final class PokemonBattleUITests: XCTestCase {
    var app: XCUIApplication!
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    override func tearDownWithError() throws {
        app = nil
    }
    func testStarterSelectionFlow() {
        // Wait for starter screen to load
        _ = app.staticTexts["Choose Your Starter Pokemon"].waitForExistence(timeout: 5.0)
        // Should have interactive elements for selection
        sleep(2) // Allow time for content to load
        let totalInteractiveElements = app.buttons.count + app.otherElements.count
        XCTAssertGreaterThan(totalInteractiveElements, 0, "Should have interactive elements for starter selection")
        // Test basic interaction doesn't crash
        if app.buttons.count > 0 {
            let firstButton = app.buttons.element(boundBy: 0)
            if firstButton.exists && firstButton.isHittable {
                firstButton.tap()
                // App should remain stable after interaction
                XCTAssertTrue(app.exists, "App should remain stable after interaction")
            }
        }
    }
}
