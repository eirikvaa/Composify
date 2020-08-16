//
//  AudioRecorder.swift
//  Composify
//
//  Created by Eirik Vale Aase on 17.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import AVFoundation
import Foundation

/// A class for recording music.
struct AVAudioRecorderService: AudioRecorderService {
    // MARK: Properties

    private var recorder: AVAudioRecorder!
    private var session = AVAudioSession.sharedInstance()

    // MARK: Initialization

    /**
     Initializes the AVAudioRecorderService class with the url to a recording.
     - Parameter url: url of recording to be played.
     */
    init(url: URL) throws {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]

        do {
            try session.setCategory(.record, mode: .default, options: [])
            try session.setActive(true)
            try recorder = AVAudioRecorder(url: url, settings: settings)
        } catch {
            throw AudioRecorderServiceError.unableToConfigureRecordingSession
        }

        recorder.prepareToRecord()
    }

    func record() {
        recorder.record()
    }

    func stop() {
        try? session.setActive(false)
        recorder.stop()
    }
}
