//
//  AudioPlayer.swift
//  Piece
//
//  Created by Eirik Vale Aase on 22.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import AVFoundation

/**
A class for playing audio from Recording objects.
- Author: Eirik Vale Aase
*/
class AudioPlayer {

	// MARK: Properties
	private(set) var player = AVAudioPlayer()
	private var session = AVAudioSession.sharedInstance()

	// MARK: Initialization
	/**
	Initializes the AudioPlayer class with a recording.
	- Parameter url: url of the recording to be played.
	*/
	convenience init?(url: URL) {
		self.init()

		guard PIEFileManager().fileManager.fileExists(atPath: url.path) else { return nil }

		do {
			try session.setCategory(AVAudioSessionCategoryPlayback)
			try player = AVAudioPlayer(contentsOf: url)

		} catch {
			print(error.localizedDescription)
			return nil
		}

		player.prepareToPlay()
	}
}
