//
//  AudioRecorder.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import AVFoundation
import SwiftUI

class AudioRecorder: ObservableObject {
    @Published var isRecording = false
    private var audioRecorder: AVAudioRecorder!
    private var recordingTitle = UUID().uuidString
    private var recordingUrl: URL {
        createFileAndGetURL(name: recordingTitle)
    }

    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to initialize recording session: \(error.localizedDescription)")
        }

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12_000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: recordingUrl, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            isRecording = true
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() -> URL {
        audioRecorder.stop()
        isRecording = false

        // Reset the recording title so we don't overwrite recordings
        let previousRecordingURL = recordingUrl
        recordingTitle = UUID().uuidString

        return previousRecordingURL
    }
}

private extension AudioRecorder {
    func createFileAndGetURL(name: String) -> URL {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        return documentDirectory
            .appendingPathComponent(name)
            .appendingPathExtension("m4a")
    }
}
