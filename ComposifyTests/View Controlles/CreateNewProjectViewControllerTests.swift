//
//  CreateNewProjectViewControllerTests.swift
//  ComposifyTests
//
//  Created by Eirik Vale Aase on 08/12/2019.
//  Copyright © 2019 Eirik Vale Aase. All rights reserved.
//

import RealmSwift
import XCTest

@testable import Composify

class CreateNewProjectViewControllerTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = name
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitializeVCShouldCreateProject() {
        let vc = CreateNewProjectViewController()
        vc.loadViewIfNeeded()

        let objectCount = fetchProjectDatabaseCount()
        XCTAssertEqual(objectCount, 1)
    }

    func testDismissWithoutSavingShouldDeleteMadeProject() {
        let vc = CreateNewProjectViewController()
        vc.loadViewIfNeeded()

        vc.dismissWithoutSaving()

        let objectCount = fetchProjectDatabaseCount()
        XCTAssertEqual(objectCount, 0)
    }

    func testSaveAndDismissShouldKeepMadeProject() {
        let vc = CreateNewProjectViewController()
        vc.loadViewIfNeeded()

        vc.saveAndDismiss()

        let objectCount = fetchProjectDatabaseCount()
        XCTAssertEqual(objectCount, 1)
    }
}

private extension CreateNewProjectViewControllerTests {
    func fetchProjectDatabaseCount() -> Int {
        let realm = try! Realm()
        return realm.objects(Project.self).count
    }
}
