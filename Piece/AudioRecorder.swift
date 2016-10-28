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
	Initializes the AudioPlayer class with a recording.
	- Parameter url: The url of the location that the recording will be stored.
	*/
	convenience init?(url: URL) {
		self.init()

		let session = AVAudioSession.sharedInstance()

		let settings: [String: Any] = [
			AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
			AVSampleRateKey: 12000.0,
			AVNumberOfChannelsKey: 1 as NSNumber,
			AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
		]

		do {
			try session.setCategory(AVAudioSessionCategoryRecord)
			try recorder = AVAudioRecorder(url: url, settings: settings)
		} catch {
			print(error)
			return nil
		}

		recorder.prepareToRecord()
	}
}

