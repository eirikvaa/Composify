//
//  AudioRecorderTests.swift
//  ComposifyTests
//
//  Created by Eirik Vale Aase on 10.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

@testable import Composify
import XCTest

final class AudioRecorderTests: XCTestCase {
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

private extension AudioRecorderTests {
    /// Create project
    /// - parameter title: Title for object
    func createProject(withTitle title: String) -> Project {
        Project(title: title)
    }

    /// Create section
    /// - parameter title: Title for object
    func createSection(withTitle title: String, in project: Project) -> Section {
        Section(title: title, project: project)
    }

    /// Create a recording
    /// - parameter title: Title that the recording will have
    /// - parameter section: Section to which the recording will be saved to
    func createRecording(withTitle title: String) -> Recording {
        let project = createProject(withTitle: "Project")
        let section = createSection(withTitle: "Section", in: project)
        let recording = Recording(title: title, section: section)

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
