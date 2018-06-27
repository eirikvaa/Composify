//
//  RealmTests.swift
//  ComposifyTests
//
//  Created by Eirik Vale Aase on 27.06.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Composify

class RealmTests: XCTestCase {

    let realmStore = RealmStore.shared
    
    override func setUp() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = #file
        
        try! realmStore.realm.write {
            realmStore.realm.deleteAll()
        }
    }

    func testCreateProject() {
        let project = Project()
        
        XCTAssertEqual(realmStore.realm.objects(Project.self).count, 0)
        
        realmStore.save(project)
        
        XCTAssertEqual(realmStore.realm.objects(Project.self).count, 1)
    }
    
    func testDeleteProject() {
        let project = Project()
        realmStore.save(project)
        
        XCTAssertEqual(realmStore.realm.objects(Project.self).count, 1)
        
        realmStore.delete(project)
        
        XCTAssertEqual(realmStore.realm.objects(Project.self).count, 0)
    }
    
    func testDeleteProjectWhichAlsoDeletesSections() {
        let project = Project()
        let section = Section()
        let section2 = Section()
        
        try! realmStore.realm.write {
            project.sectionIDs.append(objectsIn: [section.id, section2.id])
            realmStore.realm.add([project, section, section2])
        }
        
        XCTAssertEqual(realmStore.realm.objects(Project.self).count, 1)
        XCTAssertEqual(realmStore.realm.objects(Section.self).count, 2)
        
        realmStore.delete(project)
        
        XCTAssertEqual(realmStore.realm.objects(Project.self).count, 0)
        XCTAssertEqual(realmStore.realm.objects(Section.self).count, 0)
    }
    
    func testDeleteProjectWhichAlsoDeletesSectionsAndRecordings() {
        let project = Project()
        let section = Section()
        let recording = Recording()
        
        try! realmStore.realm.write {
            project.sectionIDs.append(objectsIn: [section.id])
            section.recordingIDs.append(recording.id)
            realmStore.realm.add([project, section, recording])
        }
        
        XCTAssertEqual(realmStore.realm.objects(Project.self).count, 1)
        XCTAssertEqual(realmStore.realm.objects(Section.self).count, 1)
        XCTAssertEqual(realmStore.realm.objects(Recording.self).count, 1)
        
        realmStore.delete(project)
        
        XCTAssertEqual(realmStore.realm.objects(Project.self).count, 0)
        XCTAssertEqual(realmStore.realm.objects(Section.self).count, 0)
        XCTAssertEqual(realmStore.realm.objects(Recording.self).count, 0)
    }
    
    func testDeleteSectionWhichAlsoDeletesRecordings() {
        let project = Project()
        let section = Section()
        let recording = Recording()
        
        try! realmStore.realm.write {
            project.sectionIDs.append(objectsIn: [section.id])
            section.recordingIDs.append(recording.id)
            realmStore.realm.add([project, section, recording])
        }
        
        XCTAssertEqual(realmStore.realm.objects(Project.self).count, 1)
        XCTAssertEqual(realmStore.realm.objects(Section.self).count, 1)
        XCTAssertEqual(realmStore.realm.objects(Recording.self).count, 1)
        
        realmStore.delete(section)
        
        XCTAssertEqual(realmStore.realm.objects(Project.self).count, 1)
        XCTAssertEqual(realmStore.realm.objects(Section.self).count, 0)
        XCTAssertEqual(realmStore.realm.objects(Recording.self).count, 0)
    }
    
    func testDeleteRecording() {
        let project = Project()
        let section = Section()
        let recording = Recording()
        
        try! realmStore.realm.write {
            project.sectionIDs.append(objectsIn: [section.id])
            section.recordingIDs.append(recording.id)
            realmStore.realm.add([project, section, recording])
        }
        
        XCTAssertEqual(realmStore.realm.objects(Project.self).count, 1)
        XCTAssertEqual(realmStore.realm.objects(Section.self).count, 1)
        XCTAssertEqual(realmStore.realm.objects(Recording.self).count, 1)
        
        realmStore.delete(recording)
        
        XCTAssertEqual(realmStore.realm.objects(Project.self).count, 1)
        XCTAssertEqual(realmStore.realm.objects(Section.self).count, 1)
        XCTAssertEqual(realmStore.realm.objects(Recording.self).count, 0)
    }
    
    func testRenameProject() {
        let oldTitle = "Tittel"
        let newTitle = "New Title"
        
        let project = Project()
        project.title = oldTitle
        
        realmStore.save(project, update: true)
        
        XCTAssertTrue(realmStore.realm.objects(Project.self).contains(where: { $0.title == oldTitle }))
        XCTAssertFalse(realmStore.realm.objects(Project.self).contains(where: { $0.title == newTitle }))
        
        realmStore.rename(project, to: newTitle)
        
        XCTAssertFalse(realmStore.realm.objects(Project.self).contains(where: { $0.title == oldTitle }))
        XCTAssertTrue(realmStore.realm.objects(Project.self).contains(where: { $0.title == newTitle }))
    }
    
    func testRenameSection() {
        let oldTitle = "Tittel"
        let newTitle = "New Title"
        
        let section = Section()
        section.title = oldTitle
        
        realmStore.save(section, update: true)
        
        XCTAssertTrue(realmStore.realm.objects(Section.self).contains(where: { $0.title == oldTitle }))
        XCTAssertFalse(realmStore.realm.objects(Section.self).contains(where: { $0.title == newTitle }))
        
        realmStore.rename(section, to: newTitle)
        
        XCTAssertFalse(realmStore.realm.objects(Section.self).contains(where: { $0.title == oldTitle }))
        XCTAssertTrue(realmStore.realm.objects(Section.self).contains(where: { $0.title == newTitle }))
    }
    
    func testRenameRecording() {
        let oldTitle = "Tittel"
        let newTitle = "New Title"
        
        let recording = Recording()
        recording.title = oldTitle
        
        realmStore.save(recording, update: true)
        
        XCTAssertTrue(realmStore.realm.objects(Recording.self).contains(where: { $0.title == oldTitle }))
        XCTAssertFalse(realmStore.realm.objects(Recording.self).contains(where: { $0.title == newTitle }))
        
        realmStore.rename(recording, to: newTitle)
        
        XCTAssertFalse(realmStore.realm.objects(Recording.self).contains(where: { $0.title == oldTitle }))
        XCTAssertTrue(realmStore.realm.objects(Recording.self).contains(where: { $0.title == newTitle }))
    }
}
