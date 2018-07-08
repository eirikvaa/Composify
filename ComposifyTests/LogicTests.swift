//
//  LogicTests.swift
//  ComposifyTests
//
//  Created by Eirik Vale Aase on 30.06.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import XCTest

@testable import Composify

class LogicTests: XCTestCase {

    func testRemoveElementMoreThanOneElement() {
        var numbers = [1, 2, 3]
        numbers.removeFirst(2)
        XCTAssertEqual(numbers, [1, 3])
    }
    
    func testRemoveElementJustOneElement() {
        var numbers = [1]
        numbers.removeFirst(1)
        XCTAssertEqual(numbers, [])
    }
    
    func testRemoveElementDidNotFoundElement() {
        var numbers = [1, 2, 3]
        numbers.removeFirst(4)
        XCTAssertEqual(numbers, [1, 2, 3])
    }
    
    func testRemoveElementReturnCorrectElement() {
        var numbers = [1, 2, 3]
        let returned = numbers.removeFirst(3)
        XCTAssertEqual(returned, 3)
    }
    
    func testRemoveElementReturnedNil() {
        var numbers = [1, 2, 3]
        let returned = numbers.removeFirst(4)
        XCTAssertNil(returned)
    }

}
