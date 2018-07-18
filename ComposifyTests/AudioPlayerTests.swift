//
//  AudioPlayerTests.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.11.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import XCTest
import Darwin
import AVFoundation
@testable import Composify

class AudioPlayerTests: XCTestCase {
	var audioPlayer: AudioPlayer!
	var audioRecorder: AudioRecorder!
	var project: Project!
	var section: Section!
	var recording: Recording!
	let userProjcts: URL = {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(FileSystemDirectories.userProjects.rawValue)
	}()
    let cFileManager = CFileManager()
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
		recording.fileExtension = FileSystemExtensions.caf.rawValue
		recording.dateRecorded = Date()
		
		try! cFileManager.save(project)
		try! cFileManager.save(section)
		audioRecorder = try! AudioRecorder(url: recording.url)
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
		audioRecorder.recorder.record()
		sleep(4)
		audioRecorder.recorder.stop()
		
        audioPlayer = try! AudioPlayer(url: recording.url)
		
		XCTAssertTrue(fileManager.fileExists(atPath: recording.url.path))
		
		let audioAsset = AVURLAsset(url: recording.url)
		let assetDuration = audioAsset.duration
		let duration = CMTimeGetSeconds(assetDuration)
		XCTAssertTrue(3...5 ~= duration)
    }
}
