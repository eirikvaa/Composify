//
//  FileManagerTests.swift
//  ComposifyTests
//
//  Created by Eirik Vale Aase on 10.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

@testable import Composify
import XCTest

/*
 FileManagerTests tests both FileManager and AudioRecorder; it tests renaming of recordings, so you kind of need recordings, so you kind of need AudioRecorder.
 */
final class FileManagerTests: XCTestCase {
    override func tearDown() {
        super.tearDown()

        clearUserProjectsDirectory()
    }

    func testCreateRecording() {
        let recording = createRecording(withTitle: "Recording")

        _ = try? AudioRecorderServiceFactory.defaultService(withURL: recording.url)

        let fileManager = FileManager.default
        XCTAssertTrue(fileManager.fileExists(atPath: recording.url.path))
    }
}

private extension FileManagerTests {
    /// Create project
    /// - parameter title: Title for object
    func createProject(withTitle title: String) -> Project {
        let project = Project()
        project.title = title

        return project
    }

    /// Create section
    /// - parameter title: Title for object
    func createSection(withTitle title: String, in project: Project) -> Section {
        let section = Section()
        section.title = title
        section.project = project

        return section
    }

    /// Create a recording
    /// - parameter title: Title that the recording will have
    /// - parameter section: Section to which the recording will be saved to
    func createRecording(withTitle title: String) -> Recording {
        let project = createProject(withTitle: "Project")
        let section = createSection(withTitle: "Section", in: project)

        let recording = Recording()
        recording.title = title
        recording.section = section
        recording.project = project
        recording.fileExtension = "caf"

        return recording
    }

    /// Clear the user projects directory that objects are saved to
    func clearUserProjectsDirectory() {
        let fileManager = FileManager.default
        let userProjects = R.URLs.recordingsDirectory

        do {
            let unitTestProjects = try FileManager.default.contentsOfDirectory(atPath: userProjects.path)
            for file in unitTestProjects {
                try fileManager.removeItem(at: userProjects.appendingPathComponent(file))
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
