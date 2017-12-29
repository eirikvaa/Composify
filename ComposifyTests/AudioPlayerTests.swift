//
//  AudioPlayerTests.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import XCTest
import CoreData
import Darwin
import AVFoundation
@testable import Composify

class AudioPlayerTests: XCTestCase {
	var audioPlayer: AudioPlayer!
	var audioRecorder: AudioRecorder!
	var project: Project!
	var section: Section!
	var recording: Recording!
	let managedContext = CoreDataStack.sharedInstance.viewContext
	let userProjcts: URL = {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(FileSystemDirectories.userProjects.rawValue)
	}()
    let pieFileManager = CFileManager()
	let fileManager = FileManager.default
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		project = NSEntityDescription.insertNewObject(forEntityName: "Project", into: managedContext) as! Project
		project.title = "UnitTestProject"
		
		section = NSEntityDescription.insertNewObject(forEntityName: "Section", into: managedContext) as! Section
		section.title = "UnitTestSection"
		section.project = project
		
		recording = NSEntityDescription.insertNewObject(forEntityName: "Recording", into: managedContext) as! Recording
		recording.title = "UnitTestRecording"
		recording.section = section
		recording.project = project
		recording.fileExtension = FileSystemExtensions.caf.rawValue
		recording.dateRecorded = Date()
		
		pieFileManager.save(project)
		pieFileManager.save(section)
		audioRecorder = AudioRecorder(url: recording.url)
    }
    
	override func tearDown() {
		super.tearDown()
		project = nil
		section = nil
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
	
    func testPlayRecordedAudio() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		
		audioRecorder.recorder.record()
		sleep(4)
		audioRecorder.recorder.stop()
		
		audioPlayer = AudioPlayer(url: recording.url)
		
		XCTAssertTrue(fileManager.fileExists(atPath: userProjcts
			.appendingPathComponent(recording.project.title)
			.appendingPathComponent(recording.section.title)
			.appendingPathComponent(recording.title)
			.appendingPathExtension(recording.fileExtension).path))
		
		let audioAsset = AVURLAsset(url: recording.url)
		let assetDuration = audioAsset.duration
		let duration = CMTimeGetSeconds(assetDuration)
		XCTAssertTrue(3...5 ~= duration)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
