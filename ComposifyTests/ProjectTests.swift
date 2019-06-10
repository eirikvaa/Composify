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
    var databaseService = DatabaseServiceFactory.defaultService

    override func setUp() {
        super.setUp()

        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = name
    }

    func testAddRecordingsToProjectSectionsAndCheckCumulativeRecordingsSet() {
        let realm = try! Realm()

        let project = Project()
        let section = Section()
        let section2 = Section()
        let recording = Recording()
        let recording2 = Recording()

        try! realm.write {
            project.sectionIDs.append(objectsIn: [section.id, section2.id])
            section.recordingIDs.append(recording.id)
            section2.recordingIDs.append(recording2.id)
        }

        databaseService.save(project)
        databaseService.save(section)
        databaseService.save(section2)
        databaseService.save(recording)
        databaseService.save(recording2)

        XCTAssertEqual(project.recordings.count, 2)
    }
}
