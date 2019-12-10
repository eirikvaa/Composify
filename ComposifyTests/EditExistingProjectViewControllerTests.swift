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

    func testNormalizeSectionsAfterDeleteSection() {
        let project = createProject(populateWithSectionCount: 3)

        let vc = EditExistingProjectViewController(project: project)
        vc.loadViewIfNeeded()

        if let firstSection = project?.getSection(at: 2) {
            vc.deleteSection(firstSection) {}
        }

        let expectedIndices = [0, 1]
        let actualIndices = project?.sections.map { $0.index } ?? []
        XCTAssertEqual(expectedIndices, actualIndices)
    }
}

extension EditExistingProjectViewControllerTests {
    /// Create project with `count` number of sections.
    func createProject(populateWithSectionCount count: Int = 0) -> Project? {
        let project = Project.createProject(withTitle: "Test")

        for i in 0 ..< count {
            let section = Section()
            section.title = "S\(i)"
            section.index = i

            let databaseService = DatabaseServiceFactory.defaultService
            databaseService.save(section)
            databaseService.performOperation {
                project.sectionIDs.append(section.id)
            }
        }

        return project
    }
}
