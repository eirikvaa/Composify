//
//  CFileManagerTests.swift
//  ComposifyTests
//
//  Created by Eirik Vale Aase on 10.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

@testable import Composify
import XCTest

/*
 PIEFileManagerTests tests both PIEFileManager and AudioRecorder; it tests renaming of recordings, so you kind of need recordings, so you kind of need AudioRecorder.
 */
class FileManagerTests: XCTestCase {
    var project: Project!
    var section: Section!
    var recording: Recording!
    let fileManager = FileManager.default

    var project2: Project!
    var section2: Section!

    let userProjcts: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(FileSystemDirectories.userProjects.rawValue)
    }()

    override func setUp() {
        super.setUp()

        project = Project()
        project.title = "UnitTestProject"

        project2 = Project()
        project2.title = "UnitTestProject2"

        section = Section()
        section.title = "UnitTestSection"
        section.project = project

        section2 = Section()
        section2.title = "UnitTestSection2"
        section2.project = project2

        recording = Recording()
        recording.title = "UnitTestRecording"
        recording.dateRecorded = Date()
        recording.project = project
        recording.section = section
        recording.fileExtension = FileSystemExtensions.caf.rawValue

        try! fileManager.save(project)
        try! fileManager.save(section)
        try! fileManager.save(project2)
        try! fileManager.save(section2)
        _ = try! AudioRecorderServiceFactory.defaultService(withURL: recording.url)
    }

    override func tearDown() {
        super.tearDown()
        project = nil
        project2 = nil
        section = nil
        section2 = nil
        recording = nil

        do {
            let unitTestProjects = try fileManager.contentsOfDirectory(atPath: userProjcts.path).filter { $0.hasPrefix("UnitTest") }
            for file in unitTestProjects {
                try fileManager.removeItem(at: userProjcts.appendingPathComponent(file))
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func testSave() {
        XCTAssertTrue(fileManager.fileExists(atPath: project.url.path))
        XCTAssertTrue(fileManager.fileExists(atPath: section.url.path))
        XCTAssertTrue(fileManager.fileExists(atPath: recording.url.path))
    }

    func testDelete() {
        try! fileManager.delete(project)
        try! fileManager.delete(section)
        try! fileManager.delete(recording)

        XCTAssertFalse(fileManager.fileExists(atPath: project.url.path))
        XCTAssertFalse(fileManager.fileExists(atPath: section.url.path))
        XCTAssertFalse(fileManager.fileExists(atPath: recording.url.path))
    }
}
