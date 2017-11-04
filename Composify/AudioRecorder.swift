//
//  AudioRecorder.swift
//  Composify
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

struct AudioRecorder {
    // MARK: Properties
    private(set) var recorder: AVAudioRecorder!
    private var session = AVAudioSession.sharedInstance()

    // MARK: Initialization
    /**
    Initializes the AudioPlayer class with the url to a recording.
    - Parameter url: url of recording to be played.
    */
    init(url: URL) {
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

    /**
    Asks the user for permission to use the microphone, and returns the answer.
    - Returns: `true` if the user has permitted the use of the microphone, `false` otherwise.
    */
    func askForPermissions() -> Bool {
        var permission = false

        session.requestRecordPermission { bool in
            permission = bool
        }

        return permission
    }
}
