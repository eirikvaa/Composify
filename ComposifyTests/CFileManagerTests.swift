//
//  CFileManagerTests.swift
//  ComposifyTests
//
//  Created by Eirik Vale Aase on 10.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import XCTest
@testable import Composify

/*
PIEFileManagerTests tests both PIEFileManager and AudioRecorder; it tests renaming of recordings, so you kind of need recordings, so you kind of need AudioRecorder.
*/
class CFileManagerTests: XCTestCase {
	
	var project: Project!
	var section: Section!
	var recording: Recording!
	let pieFileManager = CFileManager()
	let fileManager = FileManager()
	
	var project2: Project!
	var section2: Section!
	
	let userProjcts: URL = {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(FileSystemDirectories.userProjects.rawValue)
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
		
		try! pieFileManager.save(project)
		try! pieFileManager.save(section)
		try! pieFileManager.save(project2)
		try! pieFileManager.save(section2)
		_ = try! AudioRecorder(url: recording.url)
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
		XCTAssertTrue(pieFileManager.fileManager.fileExists(atPath: project.url.path))
		XCTAssertTrue(pieFileManager.fileManager.fileExists(atPath: section.url.path))
		XCTAssertTrue(pieFileManager.fileManager.fileExists(atPath: recording.url.path))
	}

	func testDelete() {
		try! pieFileManager.delete(project)
		try! pieFileManager.delete(section)
		try! pieFileManager.delete(recording)
		
		XCTAssertFalse(pieFileManager.fileManager.fileExists(atPath: project.url.path))
		XCTAssertFalse(pieFileManager.fileManager.fileExists(atPath: section.url.path))
		XCTAssertFalse(pieFileManager.fileManager.fileExists(atPath: recording.url.path))
	}
}

