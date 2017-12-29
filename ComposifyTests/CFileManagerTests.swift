//
//  CFileManagerTests.swift
//  ComposifyTests
//
//  Created by Eirik Vale Aase on 10.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import XCTest
import CoreData
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
	let managedContext = CoreDataStack.sharedInstance.viewContext
	
	var project2: Project!
	var section2: Section!
	
	let userProjcts: URL = {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(FileSystemDirectories.userProjects.rawValue)
	}()

	override func setUp() {
		super.setUp()
		
		project = NSEntityDescription.insertNewObject(forEntityName: "Project", into: managedContext) as! Project
		project.title = "UnitTestProject"
		
		project2 = NSEntityDescription.insertNewObject(forEntityName: "Project", into: managedContext) as! Project
		project2.title = "UnitTestProject2"
		
		section = NSEntityDescription.insertNewObject(forEntityName: "Section", into: managedContext) as! Section
		section.title = "UnitTestSection"
		section.project = project
		
		section2 = NSEntityDescription.insertNewObject(forEntityName: "Section", into: managedContext) as! Section
		section2.title = "UnitTestSection2"
		section2.project = project2
		
		recording = NSEntityDescription.insertNewObject(forEntityName: "Recording", into: managedContext) as! Recording
		recording.title = "UnitTestRecording"
		recording.dateRecorded = Date()
		recording.project = project
		recording.section = section
		recording.fileExtension = FileSystemExtensions.caf.rawValue
		
		pieFileManager.save(project)
		pieFileManager.save(section)
		pieFileManager.save(project2)
		pieFileManager.save(section2)
		_ = AudioRecorder(url: recording.url)
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
	
	func testRename1() {
		let renamedProjectTitle = "UnitTestRenamedProject"
		let renamedSectionTitle = "UnitTestRenamedSection"
		let renamedRecordingTitle = "UnitTestRenamedRecording"
		
		pieFileManager.rename(project, from: project.title, to: renamedProjectTitle, section: nil, project: nil)
		XCTAssertFalse(fileManager.fileExists(atPath: project.url.path))
		project.title = renamedProjectTitle
		
		pieFileManager.rename(section, from: section.title, to: renamedSectionTitle, section: nil, project: nil)
		XCTAssertFalse(fileManager.fileExists(atPath: section.url.path))
		section.title = renamedSectionTitle
		
		pieFileManager.rename(recording, from: recording.title, to: renamedRecordingTitle, section: nil, project: nil)
		XCTAssertFalse(fileManager.fileExists(atPath: recording.url.path))
		recording.title = renamedRecordingTitle
		
		XCTAssertTrue(fileManager.fileExists(atPath: userProjcts
			.appendingPathComponent(renamedProjectTitle).path))
		XCTAssertTrue(fileManager.fileExists(atPath: userProjcts
			.appendingPathComponent(renamedProjectTitle)
			.appendingPathComponent(renamedSectionTitle).path))
		XCTAssertTrue(fileManager.fileExists(atPath: userProjcts
			.appendingPathComponent(renamedProjectTitle)
			.appendingPathComponent(renamedSectionTitle)
			.appendingPathComponent(renamedRecordingTitle)
			.appendingPathExtension(FileSystemExtensions.caf.rawValue).path))
	}
	
	func testRename2() {
		let renameRecordingTitle = "UnitTestRenamedRecording"
		pieFileManager.rename(recording, from: recording.title, to: renameRecordingTitle, section: section2, project: project2)
		XCTAssertFalse(fileManager.fileExists(atPath: recording.url.path))
		recording.project = project2
		recording.section = section2
		recording.title = renameRecordingTitle
		
		XCTAssertTrue(fileManager.fileExists(atPath: userProjcts
			.appendingPathComponent(recording.project.title)
			.appendingPathComponent(recording.section.title)
			.appendingPathComponent(recording.title)
			.appendingPathExtension(FileSystemExtensions.caf.rawValue).path))
	}

	func testDelete() {
		pieFileManager.delete(project)
		pieFileManager.delete(section)
		pieFileManager.delete(recording)
		
		XCTAssertFalse(pieFileManager.fileManager.fileExists(atPath: project.url.path))
		XCTAssertFalse(pieFileManager.fileManager.fileExists(atPath: section.url.path))
		XCTAssertFalse(pieFileManager.fileManager.fileExists(atPath: recording.url.path))
	}
	
	func testRest() {
		pieFileManager.reset()
		XCTAssertFalse(pieFileManager.fileManager.fileExists(atPath: userProjcts.path))
	}
}

