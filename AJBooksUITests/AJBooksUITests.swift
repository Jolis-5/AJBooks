//
//  AJBooksUITests.swift
//  AJBooksUITests
//
//  Created by Jolette Rivera on 26/09/26.
//

import XCTest

final class AJBooksUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Recorre la navegación principal sin depender de la red:
    /// Bienvenida → Inicio → Buscar → Mis libros → Explorar
    @MainActor
    func testMainNavigationFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // Bienvenida
        let enter = app.buttons["Entrar"]
        XCTAssertTrue(enter.waitForExistence(timeout: 5))
        enter.tap()

        // Pestañas
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(tabBar.buttons["Inicio"].exists)

        // Buscar: existe el campo de búsqueda y las sugerencias
        tabBar.buttons["Buscar"].tap()
        XCTAssertTrue(app.textFields["Buscar libro"].waitForExistence(timeout: 5))

        // Mis libros: se ve el estado vacío o el filtro de libros guardados
        tabBar.buttons["Mis libros"].tap()
        let emptyState = app.staticTexts["Tu estante está vacío"]
        let filter = app.textFields["Filtrar mis libros"]
        XCTAssertTrue(emptyState.waitForExistence(timeout: 5) || filter.exists)

        // Explorar: aparecen los chips de categorías
        tabBar.buttons["Explorar"].tap()
        XCTAssertTrue(app.buttons["Categoría Novela"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
