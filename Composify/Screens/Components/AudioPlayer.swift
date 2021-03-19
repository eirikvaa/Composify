//
//  AudioPlayer.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import AVFoundation
import Foundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var recording: Recording?

    private var audioPlayer: AVAudioPlayer!

    func play(recording: Recording) {
        self.recording = recording

        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(recording.title)

        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print(
                "Failed preparing audio session for audio playback of \(recording.title): \(error.localizedDescription)"
            )
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            isPlaying = true
        } catch {
            print("Failed to play recording with name: \(recording.title): \(error.localizedDescription)")
        }
    }

    func stopPlaying() {
        if audioPlayer != nil {
            audioPlayer.stop()
            isPlaying = false
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer = nil
        isPlaying = false
    }
}
