//
//  ProjectTests.swift
//  ComposifyTests
//
//  Created by Eirik Vale Aase on 27.06.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Composify

class ProjectTests: XCTestCase {
    
    let realmStore = RealmStore.shared

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = #file
        
        try! realmStore.realm.write {
            realmStore.realm.deleteAll()
        }
    }

    func testAddRecordingsToProjectSectionsAndCheckCumulativeRecordingsSet() {
        let project = Project()
        let section = Section()
        let section2 = Section()
        let recording = Recording()
        let recording2 = Recording()
        
        try! realmStore.realm.write {
            project.sectionIDs.append(objectsIn: [section.id, section2.id])
            section.recordingIDs.append(recording.id)
            section2.recordingIDs.append(recording2.id)
            realmStore.realm.add([project, section, section2, recording, recording2])
        }
        
        XCTAssertEqual(project.recordings.count, 2)
    }
}
