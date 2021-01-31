//
//  AVAudioPlayerService.swift
//  Composify
//
//  Created by Eirik Vale Aase on 22.07.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import AVFoundation
import Foundation

/**
 A class for playing audio from Recording objects.
 - Author: Eirik Vale Aase
 */

final class AVAudioPlayerService: NSObject, AudioPlayerService, AVAudioPlayerDelegate {
    var audioDidFinishBlock: ((Bool) -> Void)?

    private var player: AVAudioPlayer?
    private let session = AVAudioSession.sharedInstance()
    private var playableObject: AudioPlayable?

    required convenience init(_ object: AudioPlayable) throws {
        self.init()
        try setup(withObject: object)
    }

    func play() {
        try? session.setActive(true)
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func stop() {
        try? session.setActive(false)
        player?.stop()
    }

    func setup(withObject object: AudioPlayable) throws {
        guard player == nil else {
            return
        }

        guard FileManager.default.fileExists(atPath: object.url.path) else {
            throw AudioPlayerServiceError.unableToFindPlayable
        }

        do {
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
            player = try AVAudioPlayer(contentsOf: object.url, fileTypeHint: object.fileExtension)
        } catch {
            throw AudioPlayerServiceError.unableToConfigurePlayingSession
        }

        player?.prepareToPlay()
        player?.delegate = self

        playableObject = object
    }

    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully flag: Bool) {
        try? session.setActive(false)
        audioDidFinishBlock?(flag)
    }
}

extension AudioPlayable {
    var duration: Float64 {
        let audioAsset = AVURLAsset(url: url)
        let assetDuration = audioAsset.duration
        return CMTimeGetSeconds(assetDuration)
    }
}
