//
//  AudioRecorder.swift
//  Piece
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import AVFoundation

/**
A class for abstracting away the details regarding simple recording of audio.
- Author: Eirik Vale Aase
*/
class AudioRecorder {

	// MARK: Properties
	private(set) var recorder: AVAudioRecorder!

	// MARK: Initialization
	/**
	Initializes the AudioPlayer class with the url to a recording.
	- Parameter url: url of recording to be played.
	*/
	convenience init(url: URL) {
		self.init()

		let session = AVAudioSession.sharedInstance()

		let settings: [String: Any] = [
			AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
			AVSampleRateKey: 12000.0,
			AVNumberOfChannelsKey: 1,
			AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
		]

		do {
			try session.setCategory(AVAudioSessionCategoryRecord)
			try session.setActive(true)
			try recorder = AVAudioRecorder(url: url, settings: settings)
		} catch {
			print(error.localizedDescription)
		}

		recorder.prepareToRecord()
	}
}

