//
//  AudioPlayerTests.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import RealmSwift
import XCTest

@testable import Composify

final class AudioPlayerTests: XCTestCase {
    override func setUp() {
        super.setUp()

        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = name
    }

    func testPlayRecordedAudio() {
        let (_, _, recording, _) = createObjects()
        let audioRecorder = try! AudioRecorderServiceFactory.defaultService(withURL: recording.url)

        audioRecorder?.record()
        audioRecorder?.stop()

        _ = try! AudioPlayerServiceFactory.defaultService(withObject: recording)

        XCTAssertTrue(FileManager.default.fileExists(atPath: recording.url.path))
    }
}

private extension AudioPlayerTests {
    func createProject(titled title: String) -> Project {
        let project = Project()
        project.title = title
        return project
    }

    func createSection(titled title: String, project: Project) -> Section {
        let section = Section()
        section.title = title
        section.project = project
        return section
    }

    func createRecording(titled title: String, section: Section) -> Recording {
        let recording = Recording()
        recording.title = title
        recording.section = section
        recording.project = section.project
        recording.fileExtension = "caf"
        recording.dateCreated = Date()
        return recording
    }

    func createObjects() -> (Project, Section, Recording, Realm) {
        let project = createProject(titled: "UnitTestProject")
        let section = createSection(titled: "UnitTestSection", project: project)
        let recording = createRecording(titled: "UnitTestRecording", section: section)
        let realm = try! Realm()

        return (project, section, recording, realm)
    }
}
