//
//  PieceUITests.swift
//  PieceUITests
//
//  Created by Eirik Vale Aase on 12.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import XCTest
import CoreData
@testable import Piece

class ProjectsTableTests: XCTestCase {
	
	let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
		app.launchArguments = [
			"UI_TEST_MODE",
			"-AppleLanguages", "(nb-NO)",
			"-AppleLocale", "\"nb-NO\""
		]
        app.launch()

		// In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
	}
    
    func testEmptyApplicationProjectsList() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
	
	func testAddProject() {
		
		let app = XCUIApplication()
		let prosjekterNavigationBar = app.navigationBars["Prosjekter"]
		prosjekterNavigationBar.buttons["Rediger"].tap()
		prosjekterNavigationBar.buttons["Legg til"].tap()
		
		let nyttProsjektAlert = app.alerts["Nytt prosjekt"]
		nyttProsjektAlert.collectionViews.textFields["tittel på prosjekt"].typeText("Something New")
		nyttProsjektAlert.buttons["Lagre"].tap()
		prosjekterNavigationBar.buttons["Ferdig"].tap()
		
		
		let table = app.tables.element
		
		XCTAssertTrue(table.staticTexts["Something New"].exists)
	}
	
	func testRemoveProject() {
		let prosjekterNavigationBar = app.navigationBars["Prosjekter"]
		prosjekterNavigationBar.buttons["Rediger"].tap()
		prosjekterNavigationBar.buttons["Legg til"].tap()
		
		let nyttProsjektAlert = app.alerts["Nytt prosjekt"]
		nyttProsjektAlert.collectionViews.textFields["tittel på prosjekt"].typeText("Into The West")
		nyttProsjektAlert.buttons["Lagre"].tap()
		
		let tablesQuery = app.tables
		tablesQuery.buttons["Slett Into The West"].tap()
		tablesQuery.buttons["Slett"].tap()
		prosjekterNavigationBar.buttons["Ferdig"].tap()
		
		
		let table = app.tables.element
		XCTAssertFalse(table.staticTexts["Into the West"].exists)
	}
	
	func testRenameProject() {
		let prosjekterNavigationBar = app.navigationBars["Prosjekter"]
		prosjekterNavigationBar.buttons["Rediger"].tap()
		prosjekterNavigationBar.buttons["Legg til"].tap()
		
		let nyttProsjektAlert = app.alerts["Nytt prosjekt"]
		nyttProsjektAlert.collectionViews.textFields["tittel på prosjekt"].typeText("Here I Am")
		nyttProsjektAlert.buttons["Lagre"].tap()
		
		let tablesQuery = app.tables
		tablesQuery.buttons["Slett Here I Am"].tap()
		tablesQuery.buttons["Gi nytt navn"].tap()
		
		let giNyttNavnAlert = app.alerts["Gi nytt navn"]
		let nyttNavnTilProsjektTextField = giNyttNavnAlert.collectionViews.textFields.element
		nyttNavnTilProsjektTextField.tap()
		nyttNavnTilProsjektTextField.typeText("I Am Not Here")
		giNyttNavnAlert.buttons["Lagre"].tap()
		prosjekterNavigationBar.buttons["Ferdig"].tap()
		
		let table = app.tables.element
		XCTAssertFalse(table.staticTexts["Here I Am"].exists)
		XCTAssertTrue(table.staticTexts["I Am Not Here"].exists)
		
	}
    
}
