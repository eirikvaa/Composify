//
//  EditExistingProjectViewControllerTests.swift
//  ComposifyTests
//
//  Created by Eirik Vale Aase on 08/12/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import RealmSwift
import XCTest

@testable import Composify

class EditExistingProjectViewControllerTests: XCTestCase {
    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = name
    }

    func testEditExistingProjectAndPopulateBackingDataCheckTitle() {
        let project = Project()
        project.title = "Test"
        RealmRepository().save(object: project)

        let viewController = EditExistingProjectViewController(project: project)
        viewController.loadViewIfNeeded()

        let tableSections = viewController.tableSections

        XCTAssertEqual(tableSections[0].values, ["Test"])
    }

    func testEditExistingProjectAndPopulateBackingDataCheckSections() {
        let project = Project.createProject()

        let viewController = EditExistingProjectViewController(project: project)
        viewController.loadViewIfNeeded()

        let tableSections = viewController.tableSections

        XCTAssertEqual(tableSections[1].values, [])
    }
}
