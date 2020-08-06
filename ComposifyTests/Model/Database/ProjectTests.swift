//
//  ProjectTests.swift
//  ComposifyTests
//
//  Created by Eirik Vale Aase on 27.06.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import RealmSwift
import XCTest

@testable import Composify

final class ProjectTests: XCTestCase {
    override func setUp() {
        super.setUp()

        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = name
    }

    func testNormalizeSectionsAfterDeleteSection() {
        let project = Project.createProject(populateWithSectionCount: 3)

        project?.deleteSection(at: 1)

        let expectedIndices = [0, 1]
        let actualIndices = project?.sections.map { $0.index } ?? []
        XCTAssertEqual(expectedIndices, actualIndices)
    }
}
