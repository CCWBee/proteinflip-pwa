import XCTest

final class ProteinFlipUITests: XCTestCase {
    func testAddButtonExists() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Add"].waitForExistence(timeout: 2))
    }
}
