//
//  AudioRecorder.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import AVFoundation
import SwiftUI

@Observable
class AudioRecorder {
    var isRecording = false

    private var audioRecorder: AVAudioRecorder!
    private var recordingTitle = UUID()

    var canRecord: Bool {
        AVAudioApplication.shared.recordPermission == .granted
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
            audioRecorder = try AVAudioRecorder(
                url: createRecordingUrl(name: recordingTitle),
                settings: settings
            )
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            isRecording = true
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() -> UUID {
        audioRecorder.stop()
        isRecording = false

        // Reset the recording title so we don't overwrite recordings
        let recordingId = recordingTitle
        recordingTitle = UUID()

        return recordingId
    }

    func askForPermission() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }
}

private extension AudioRecorder {
    func createRecordingUrl(name: UUID) -> URL {
        URL.documentsDirectory
            .appendingPathComponent(name.uuidString)
            .appendingPathExtension("m4a")
    }
}
