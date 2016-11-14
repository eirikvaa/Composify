//
//  TestInitializerTests.swift
//  Piece
//
//  Created by Eirik Vale Aase on 14.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import XCTest
@testable import Piece

class TestInitializerTests: XCTestCase {
	
	var testInitializer: TestInitializer!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
		testInitializer = nil
    }
    
    func testProjectMode() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		testInitializer = TestInitializer(arguments: ["UI_TEST_MODE_PROJECTS"])
		testInitializer.setupTestingMode()
		XCTAssertNil(testInitializer.project)
		XCTAssertNil(testInitializer.section)
		XCTAssertTrue(testInitializer.active)
    }
	
	func testSectionMode() {
		testInitializer = TestInitializer(arguments: ["UI_TEST_MODE_SECTIONS"])
		testInitializer.setupTestingMode()
		XCTAssertNotNil(testInitializer.project)
		XCTAssertNil(testInitializer.section)
		XCTAssertTrue(testInitializer.active)
	}
	
	func testRecordingMode() {
		testInitializer = TestInitializer(arguments: ["UI_TEST_MODE_RECORDINGS"])
		testInitializer.setupTestingMode()
		XCTAssertNotNil(testInitializer.project)
		XCTAssertNotNil(testInitializer.section)
		XCTAssertTrue(testInitializer.active)
	}
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
