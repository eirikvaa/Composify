//
//  HashableTupleTests.swift
//  ComposifyTests
//
//  Created by Eirik Vale Aase on 22/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import XCTest

@testable import Composify

class HashableTupleTests: XCTestCase {
    func testHashableTupleInitialization() {
        let tuple = HashableTuple(1, 2)

        XCTAssertEqual(tuple.first, 1)
        XCTAssertEqual(tuple.second, 2)
    }

    func testHashableTupleEquatable() {
        let tuple1 = HashableTuple(1, 2)
        let tuple2 = HashableTuple(1, 2)
        let tuple3 = HashableTuple(3, 4)

        XCTAssertEqual(tuple1, tuple2)
        XCTAssertNotEqual(tuple1, tuple3)
    }
}
