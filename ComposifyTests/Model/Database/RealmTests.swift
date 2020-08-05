//
//  RealmTests.swift
//  ComposifyTests
//
//  Created by Eirik Vale Aase on 27.06.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import RealmSwift
import XCTest

@testable import Composify

final class RealmTests: XCTestCase {
    var databaseService = DatabaseServiceFactory.defaultService

    override func setUp() {
        super.setUp()

        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = name
    }

    func testCreateProject() {
        let realm = try! Realm()
        let project = Project()

        XCTAssertEqual(realm.objects(Project.self).count, 0)

        databaseService.save(project)

        XCTAssertEqual(realm.objects(Project.self).count, 1)
    }

    func testDeleteProject() {
        let realm = try! Realm()
        let project = Project()
        databaseService.save(project)

        XCTAssertEqual(realm.objects(Project.self).count, 1)

        databaseService.delete(project)

        XCTAssertEqual(realm.objects(Project.self).count, 0)
    }

    func testDeleteProjectWhichAlsoDeletesSections() {
        let realm = try! Realm()
        let project = Project()
        let section = Section()
        let section2 = Section()

        try! realm.write {
            project.sections.append(objectsIn: [section, section2])
            realm.add([project, section, section2])
        }

        XCTAssertEqual(realm.objects(Project.self).count, 1)
        XCTAssertEqual(realm.objects(Section.self).count, 2)

        databaseService.delete(project)

        XCTAssertEqual(realm.objects(Project.self).count, 0)
        XCTAssertEqual(realm.objects(Section.self).count, 0)
    }

    func testDeleteProjectWhichAlsoDeletesSectionsAndRecordings() {
        let realm = try! Realm()
        let project = Project()
        let section = Section()
        let recording = Recording()

        try! realm.write {
            project.sections.append(objectsIn: [section])
            section.recordings.append(recording)
            realm.add([project, section, recording])
        }

        XCTAssertEqual(realm.objects(Project.self).count, 1)
        XCTAssertEqual(realm.objects(Section.self).count, 1)
        XCTAssertEqual(realm.objects(Recording.self).count, 1)

        databaseService.delete(project)

        XCTAssertEqual(realm.objects(Project.self).count, 0)
        XCTAssertEqual(realm.objects(Section.self).count, 0)
        XCTAssertEqual(realm.objects(Recording.self).count, 0)
    }

    func testDeleteSectionWhichAlsoDeletesRecordings() {
        let realm = try! Realm()
        let project = Project()
        let section = Section()
        let recording = Recording()

        try! realm.write {
            project.sections.append(objectsIn: [section])
            section.recordings.append(recording)
            realm.add([project, section, recording])
        }

        XCTAssertEqual(realm.objects(Project.self).count, 1)
        XCTAssertEqual(realm.objects(Section.self).count, 1)
        XCTAssertEqual(realm.objects(Recording.self).count, 1)

        databaseService.delete(section)

        XCTAssertEqual(realm.objects(Project.self).count, 1)
        XCTAssertEqual(realm.objects(Section.self).count, 0)
        XCTAssertEqual(realm.objects(Recording.self).count, 0)
    }

    func testDeleteRecording() {
        let realm = try! Realm()
        let project = Project()
        let section = Section()
        let recording = Recording()

        try! realm.write {
            project.sections.append(objectsIn: [section])
            section.recordings.append(recording)
            realm.add([project, section, recording])
        }

        XCTAssertEqual(realm.objects(Project.self).count, 1)
        XCTAssertEqual(realm.objects(Section.self).count, 1)
        XCTAssertEqual(realm.objects(Recording.self).count, 1)

        databaseService.delete(recording)

        XCTAssertEqual(realm.objects(Project.self).count, 1)
        XCTAssertEqual(realm.objects(Section.self).count, 1)
        XCTAssertEqual(realm.objects(Recording.self).count, 0)
    }

    func testRenameProject() {
        let realm = try! Realm()
        let oldTitle = "Tittel"
        let newTitle = "New Title"

        let project = Project()
        project.title = oldTitle

        databaseService.save(project)

        XCTAssertTrue(realm.objects(Project.self).contains(where: { $0.title == oldTitle }))
        XCTAssertFalse(realm.objects(Project.self).contains(where: { $0.title == newTitle }))

        databaseService.rename(project, to: newTitle)

        XCTAssertFalse(realm.objects(Project.self).contains(where: { $0.title == oldTitle }))
        XCTAssertTrue(realm.objects(Project.self).contains(where: { $0.title == newTitle }))
    }

    func testRenameSection() {
        let realm = try! Realm()
        let oldTitle = "Tittel"
        let newTitle = "New Title"

        let section = Section()
        section.title = oldTitle

        databaseService.save(section)

        XCTAssertTrue(realm.objects(Section.self).contains(where: { $0.title == oldTitle }))
        XCTAssertFalse(realm.objects(Section.self).contains(where: { $0.title == newTitle }))

        databaseService.rename(section, to: newTitle)

        XCTAssertFalse(realm.objects(Section.self).contains(where: { $0.title == oldTitle }))
        XCTAssertTrue(realm.objects(Section.self).contains(where: { $0.title == newTitle }))
    }

    func testRenameRecording() {
        let realm = try! Realm()
        let oldTitle = "Tittel"
        let newTitle = "New Title"

        let recording = Recording()
        recording.title = oldTitle

        databaseService.save(recording)

        XCTAssertTrue(realm.objects(Recording.self).contains(where: { $0.title == oldTitle }))
        XCTAssertFalse(realm.objects(Recording.self).contains(where: { $0.title == newTitle }))

        databaseService.rename(recording, to: newTitle)

        XCTAssertFalse(realm.objects(Recording.self).contains(where: { $0.title == oldTitle }))
        XCTAssertTrue(realm.objects(Recording.self).contains(where: { $0.title == newTitle }))
    }
}
