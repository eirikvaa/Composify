//
//  AudioPlayerTests.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import XCTest

@testable import Composify

final class AudioPlayerTests: XCTestCase {
    func testPlayRecordedAudio() {
        let recording = createObjects()
        let audioRecorder = try? AudioRecorderServiceFactory.defaultService(withURL: recording.url)

        audioRecorder?.record()
        audioRecorder?.stop()

        _ = try! AudioPlayerServiceFactory.defaultService(withObject: recording)

        XCTAssertTrue(FileManager.default.fileExists(atPath: recording.url.path))
    }
}

private extension AudioPlayerTests {
    func createProject(titled title: String) -> Project {
        Project(title: title)
    }

    func createSection(titled title: String, project: Project) -> Section {
        Section(title: title, project: project)
    }

    func createRecording(titled title: String, section: Section) -> Recording {
        Recording(title: title, section: section)
    }

    func createObjects() -> Recording {
        let project = createProject(titled: "UnitTestProject")
        let section = createSection(titled: "UnitTestSection", project: project)
        let recording = createRecording(titled: "UnitTestRecording", section: section)

        return (project, section, recording)
    }
}
