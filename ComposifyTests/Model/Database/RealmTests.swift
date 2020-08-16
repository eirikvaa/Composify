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
    override func setUp() {
        super.setUp()

        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = name
    }

    func testCreateProject() {
        let realm = try! Realm()
        let project = Project(title: "Stuff")

        XCTAssertEqual(realm.objects(Project.self).count, 0)

        RealmRepository().save(object: project)

        XCTAssertEqual(realm.objects(Project.self).count, 1)
    }

    func testDeleteProject() {
        let realm = try! Realm()
        let project = Project(title: "Stuff")
        RealmRepository().save(object: project)

        XCTAssertEqual(realm.objects(Project.self).count, 1)

        RealmRepository().delete(object: project)

        XCTAssertEqual(realm.objects(Project.self).count, 0)
    }

    func testDeleteProjectWhichAlsoDeletesSections() {
        let realm = try! Realm()
        let project = Project(title: "Stuff")
        let section = Section(title: "Stuff", project: project)
        let section2 = Section(title: "Stuff 2", project: project)

        try! realm.write {
            project.sections.append(objectsIn: [section, section2])
            realm.add([project, section, section2])
        }

        XCTAssertEqual(realm.objects(Project.self).count, 1)
        XCTAssertEqual(realm.objects(Section.self).count, 2)

        RealmRepository().delete(object: project)

        XCTAssertEqual(realm.objects(Project.self).count, 0)
        XCTAssertEqual(realm.objects(Section.self).count, 0)
    }

    func testDeleteProjectWhichAlsoDeletesSectionsAndRecordings() {
        let realm = try! Realm()
        let project = Project(title: "Stuff")
        let section = Section(title: "Stuff", project: project)
        let recording = Recording(title: "Stuff", section: section)

        try! realm.write {
            project.sections.append(objectsIn: [section])
            section.recordings.append(recording)
            realm.add([project, section, recording])
        }

        XCTAssertEqual(realm.objects(Project.self).count, 1)
        XCTAssertEqual(realm.objects(Section.self).count, 1)
        XCTAssertEqual(realm.objects(Recording.self).count, 1)

        RealmRepository().delete(object: project)

        XCTAssertEqual(realm.objects(Project.self).count, 0)
        XCTAssertEqual(realm.objects(Section.self).count, 0)
        XCTAssertEqual(realm.objects(Recording.self).count, 0)
    }

    func testDeleteSectionWhichAlsoDeletesRecordings() {
        let realm = try! Realm()
        let project = Project(title: "Stuff")
        let section = Section(title: "Stuff", project: project)
        let recording = Recording(title: "Stuff", section: section)

        try! realm.write {
            project.sections.append(objectsIn: [section])
            section.recordings.append(recording)
            realm.add([project, section, recording])
        }

        XCTAssertEqual(realm.objects(Project.self).count, 1)
        XCTAssertEqual(realm.objects(Section.self).count, 1)
        XCTAssertEqual(realm.objects(Recording.self).count, 1)

        RealmRepository().delete(object: section)

        XCTAssertEqual(realm.objects(Project.self).count, 1)
        XCTAssertEqual(realm.objects(Section.self).count, 0)
        XCTAssertEqual(realm.objects(Recording.self).count, 0)
    }

    func testDeleteRecording() {
        let realm = try! Realm()
        let project = Project(title: "Stuff")
        let section = Section(title: "Stuff", project: project)
        let recording = Recording(title: "Stuff", section: section)

        try! realm.write {
            project.sections.append(objectsIn: [section])
            section.recordings.append(recording)
            realm.add([project, section, recording])
        }

        XCTAssertEqual(realm.objects(Project.self).count, 1)
        XCTAssertEqual(realm.objects(Section.self).count, 1)
        XCTAssertEqual(realm.objects(Recording.self).count, 1)

        RealmRepository().delete(object: recording)

        XCTAssertEqual(realm.objects(Project.self).count, 1)
        XCTAssertEqual(realm.objects(Section.self).count, 1)
        XCTAssertEqual(realm.objects(Recording.self).count, 0)
    }

    func testRenameProject() {
        let realm = try! Realm()
        let oldTitle = "Tittel"
        let newTitle = "New Title"

        var project = Project(title: oldTitle)
        project.title = oldTitle

        RealmRepository().save(object: project)

        XCTAssertTrue(realm.objects(Project.self).contains(where: { $0.title == oldTitle }))
        XCTAssertFalse(realm.objects(Project.self).contains(where: { $0.title == newTitle }))

        RealmRepository().update(object: &project, value: newTitle, keyPath: \.title)

        XCTAssertFalse(realm.objects(Project.self).contains(where: { $0.title == oldTitle }))
        XCTAssertTrue(realm.objects(Project.self).contains(where: { $0.title == newTitle }))
    }

    func testRenameSection() {
        let realm = try! Realm()
        let oldTitle = "Tittel"
        let newTitle = "New Title"
        let project = Project(title: "Project")

        var section = Section(title: oldTitle, project: project)

        RealmRepository().save(object: section)

        XCTAssertTrue(realm.objects(Section.self).contains(where: { $0.title == oldTitle }))
        XCTAssertFalse(realm.objects(Section.self).contains(where: { $0.title == newTitle }))

        RealmRepository().update(object: &section, value: newTitle, keyPath: \.title)

        XCTAssertFalse(realm.objects(Section.self).contains(where: { $0.title == oldTitle }))
        XCTAssertTrue(realm.objects(Section.self).contains(where: { $0.title == newTitle }))
    }

    func testRenameRecording() {
        let realm = try! Realm()
        let oldTitle = "Tittel"
        let newTitle = "New Title"
        let project = Project(title: "Project")
        let section = Section(title: "Section", project: project)

        var recording = Recording(title: oldTitle, section: section)
        recording.title = oldTitle

        RealmRepository().save(object: recording)

        XCTAssertTrue(realm.objects(Recording.self).contains(where: { $0.title == oldTitle }))
        XCTAssertFalse(realm.objects(Recording.self).contains(where: { $0.title == newTitle }))

        RealmRepository().update(object: &recording, value: newTitle, keyPath: \.title)

        XCTAssertFalse(realm.objects(Recording.self).contains(where: { $0.title == oldTitle }))
        XCTAssertTrue(realm.objects(Recording.self).contains(where: { $0.title == newTitle }))
    }
}
