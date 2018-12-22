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
    override func tearDown() {
        super.tearDown()

        clearUserProjectsDirectory()
    }

    func testSave() {
        let (project, section, recording) = createTestObjects()

        let fileManager = FileManager.default
        try? fileManager.save(project)
        try? fileManager.save(section)
        _ = try? AudioRecorderServiceFactory.defaultService(withURL: recording.url)

        XCTAssertTrue(fileManager.fileExists(atPath: project.url.path))
        XCTAssertTrue(fileManager.fileExists(atPath: section.url.path))
        XCTAssertTrue(fileManager.fileExists(atPath: recording.url.path))
    }

    func testDelete() {
        let (project, section, recording) = createTestObjects()

        let fileManager = FileManager.default
        try? fileManager.save(project)
        try? fileManager.save(section)
        _ = try? AudioRecorderServiceFactory.defaultService(withURL: recording.url)

        XCTAssertTrue(fileManager.fileExists(atPath: project.url.path))
        XCTAssertTrue(fileManager.fileExists(atPath: section.url.path))
        XCTAssertTrue(fileManager.fileExists(atPath: recording.url.path))

        XCTAssertNoThrow(try fileManager.delete(project))
        XCTAssertNoThrow(try fileManager.delete(section))
        XCTAssertNoThrow(try fileManager.delete(recording))

        XCTAssertFalse(fileManager.fileExists(atPath: project.url.path))
        XCTAssertFalse(fileManager.fileExists(atPath: section.url.path))
        XCTAssertFalse(fileManager.fileExists(atPath: recording.url.path))
    }
}

private extension FileManagerTests {
    /// Create a project
    /// - parameter title: Title that the project will have
    func createProject(withTitle title: String) -> Project {
        let project = Project()
        project.title = title
        return project
    }

    /// Create a section
    /// - parameter title: Title that the section will have
    /// - parameter project: Project to which the section will be saved to
    func createSection(withTitle title: String, in project: Project) -> Section {
        let section = Section()
        section.title = title
        section.project = project
        return section
    }

    /// Create a recording
    /// - parameter title: Title that the recording will have
    /// - parameter section: Section to which the recording will be saved to
    func createRecording(withTitle title: String, in section: Section) -> Recording {
        let recording = Recording()
        recording.title = title
        recording.section = section
        recording.project = section.project
        recording.dateRecorded = Date()
        recording.fileExtension = "caf"
        return recording
    }

    /// Clear the user projects directory that objects are saved to
    func clearUserProjectsDirectory() {
        let fileManager = FileManager.default
        let userProjects = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(FileSystemDirectories.userProjects.rawValue)

        do {
            let unitTestProjects = try FileManager.default.contentsOfDirectory(atPath: userProjects.path).filter { $0.hasPrefix("UnitTest") }
            for file in unitTestProjects {
                try fileManager.removeItem(at: userProjects.appendingPathComponent(file))
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    /// Create a project, a section and a recording
    func createTestObjects() -> (Project, Section, Recording) {
        let project = createProject(withTitle: "UnitTestProject")
        let section = createSection(withTitle: "UnitTestSection", in: project)
        let recording = createRecording(withTitle: "UnitTestRecording", in: section)

        return (project, section, recording)
    }
}
