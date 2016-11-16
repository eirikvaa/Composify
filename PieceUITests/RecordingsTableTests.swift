//
//  RecordingsTableTests.swift
//  Piece
//
//  Created by Eirik Vale Aase on 13.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import XCTest
import Darwin
@testable import Piece

class RecordingsTableTests: XCTestCase {
	
	let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
		app.launchArguments = [
			"UI_TEST_MODE_RECORDINGS",
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
	
	func testEmptySection() {
		let tablesQuery = app.tables
		tablesQuery.staticTexts["Something New"].tap()
		tablesQuery.staticTexts["Intro"].tap()
		
		let table = app.tables.element
		
		XCTAssertTrue(table.staticTexts.count == 0)
	}
    
    func testAddRecording() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		let tablesQuery = app.tables
		tablesQuery.staticTexts["Something New"].tap()
		tablesQuery.staticTexts["Intro"].tap()
		
		let introNavigationBar = app.navigationBars["Intro"]
		introNavigationBar.buttons["Rediger"].tap()
		introNavigationBar.buttons["Legg til"].tap()
		app.buttons["Start opptak"].tap()
		app.buttons["Trykk for å stoppe opptak"].tap()
		tablesQuery.cells.containing(.button, identifier:"Spill lyd").children(matching: .textField).element.tap()
		tablesQuery.buttons["Fjern tekst"].tap()
		tablesQuery.textFields.element.typeText("Sang")
		app.navigationBars["Konfigurer og lagre opptak"].buttons["Arkiver"].tap()
		introNavigationBar.buttons["Ferdig"].tap()
		
		XCTAssertTrue(app.tables.staticTexts["Sang"].exists)
    }
	
	func testRenameRecording() {
		let tablesQuery = app.tables
		tablesQuery.staticTexts["Something New"].tap()
		tablesQuery.staticTexts["Intro"].tap()
		
		let introNavigationBar = app.navigationBars["Intro"]
		introNavigationBar.buttons["Rediger"].tap()
		introNavigationBar.buttons["Legg til"].tap()
		app.buttons["Start opptak"].tap()
		app.buttons["Trykk for å stoppe opptak"].tap()
		tablesQuery.cells.containing(.button, identifier:"Spill lyd").children(matching: .textField).element.tap()
		tablesQuery.buttons["Fjern tekst"].tap()
		tablesQuery.textFields.element.typeText("Here I Am")
		app.navigationBars["Konfigurer og lagre opptak"].buttons["Arkiver"].tap()
		tablesQuery.buttons["Slett Here I Am, 0:00/0:01"].tap()
		tablesQuery.buttons["Gi nytt navn"].tap()
		
		let giNyttNavnAlert = app.alerts["Gi nytt navn"]
		let nyttNavnTilOpptakTextField = giNyttNavnAlert.collectionViews.textFields.element
		nyttNavnTilOpptakTextField.tap()
		nyttNavnTilOpptakTextField.typeText("I Am Not Here")
		giNyttNavnAlert.buttons["Lagre"].tap()
		introNavigationBar.buttons["Ferdig"].tap()
		
		let table = app.tables.element
		XCTAssertFalse(table.staticTexts["Here I Am"].exists)
		XCTAssertTrue(table.staticTexts["I Am Not Here"].exists)
	}
	
	func testDeleteRecording() {
		let tablesQuery = app.tables
		tablesQuery.staticTexts["Something New"].tap()
		tablesQuery.staticTexts["Intro"].tap()
		
		let introNavigationBar = app.navigationBars["Intro"]
		introNavigationBar.buttons["Rediger"].tap()
		introNavigationBar.buttons["Legg til"].tap()
		app.buttons["Start opptak"].tap()
		app.buttons["Trykk for å stoppe opptak"].tap()
		tablesQuery.cells.containing(.button, identifier:"Spill lyd").children(matching: .textField).element.tap()
		tablesQuery.buttons["Fjern tekst"].tap()
		tablesQuery.textFields.element.typeText("Sang")
		app.navigationBars["Konfigurer og lagre opptak"].buttons["Arkiver"].tap()
		tablesQuery.buttons["Slett Sang, 0:00/0:01"].tap()
		tablesQuery.buttons["Slett"].tap()
		
		let table = app.tables.element
		XCTAssertFalse(table.staticTexts["Sang"].exists)
	}
    
}
