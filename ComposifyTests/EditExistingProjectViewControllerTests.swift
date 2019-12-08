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
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = name
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEditExistingProjectAndPopulateBackingDataCheckTitle() {
        let project = createProject()

        let vc = EditExistingProjectViewController(project: project)
        vc.loadViewIfNeeded()

        let tableSections = vc.tableSections

        XCTAssertEqual(tableSections[0].values, ["Test"])
    }

    func testEditExistingProjectAndPopulateBackingDataCheckSections() {
        let project = createProject()

        let vc = EditExistingProjectViewController(project: project)
        vc.loadViewIfNeeded()

        let tableSections = vc.tableSections

        XCTAssertEqual(tableSections[1].values, [])
    }
}

extension EditExistingProjectViewControllerTests {
    func createProject() -> Project? {
        var project: Project?
        Project.createProject(withTitle: "Test") { _project in
            project = _project
        }

        return project
    }
}
