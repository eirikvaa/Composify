//
//  AudioPlayer.swift
//  Composify
//
//  Created by Eirik Vale Aase on 22.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioPlayerError: Error {
    case unableToConfigurePlayingSession
    case unableToPlayRecording
}

/**
A class for playing audio from Recording objects.
- Author: Eirik Vale Aase
*/

struct AudioPlayer {
    // MARK: Properties
    private(set) var player = AVAudioPlayer()
    private var session = AVAudioSession.sharedInstance()

    // MARK: Initialization
    /**
    Initializes the AudioPlayer class with a recording.
    - Parameter url: url of the recording to be played.
    */
    init(url: URL) throws {
        guard CFileManager().fileManager.fileExists(atPath: url.path) else {
            return
        }

        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try player = AVAudioPlayer(contentsOf: url)
        } catch {
            throw AudioPlayerError.unableToConfigurePlayingSession
        }

        player.prepareToPlay()
    }
}
