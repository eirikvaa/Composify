//
//  AVAudioPlayerService.swift
//  Composify
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

class AVAudioPlayerService: NSObject, AudioPlayerService, AVAudioPlayerDelegate {
    var audioDidFinishBlock: ((Bool) -> Void)?
    
    private var player: AVAudioPlayer?
    private let session = AVAudioSession.sharedInstance()
    private var playableObject: AudioPlayable?
    
    convenience required init(_ object: AudioPlayable) throws {
        self.init()
        try setup(withObject: object)
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.stop()
    }
    
    func setup(withObject object: AudioPlayable) throws {
        guard player == nil else { return }
        guard FileManager.default.fileExists(atPath: object.url.path) else { throw AudioPlayerServiceError.unableToFindPlayable }
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            player = try AVAudioPlayer(contentsOf: object.url, fileTypeHint: object.fileExtension)
        } catch {
            throw AudioPlayerServiceError.unableToConfigurePlayingSession
        }
        
        player?.prepareToPlay()
        player?.delegate = self
        
        self.playableObject = object
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
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
