//
//  AudioPlayerTests.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

@testable import Composify
import Darwin
import XCTest

class AudioPlayerTests: XCTestCase {
    var audioPlayer: AudioPlayerService!
    var audioRecorder: AudioRecorderService!
    var project: Project!
    var section: Section!
    var recording: Recording!
    let userProjcts = R.URLs.recordingsDirectory

    let fileManager = FileManager.default

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        project = Project()
        project.title = "UnitTestProject"

        section = Section()
        section.title = "UnitTestSection"
        section.project = project

        recording = Recording()
        recording.title = "UnitTestRecording"
        recording.section = section
        recording.project = project
        recording.fileExtension = "caf"
        recording.dateCreated = Date()

        audioRecorder = try! AudioRecorderServiceFactory.defaultService(withURL: recording.url)
    }

    override func tearDown() {
        super.tearDown()
        project = nil
        section = nil
        recording = nil

        do {
            let unitTestProjects = try fileManager.contentsOfDirectory(atPath: userProjcts.path)
            for file in unitTestProjects {
                try fileManager.removeItem(at: userProjcts.appendingPathComponent(file))
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func testPlayRecordedAudio() {
        audioRecorder.record()
        sleep(4)
        audioRecorder.stop()

        audioPlayer = try! AudioPlayerServiceFactory.defaultService(withObject: recording)

        XCTAssertTrue(fileManager.fileExists(atPath: recording.url.path))
        XCTAssertTrue(3 ... 5 ~= recording.duration)
    }
}
