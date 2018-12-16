//
//  AudioPlayerService.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

/// An `AudioPlayerService` performs different actions with playable objects.
protocol AudioPlayerService {
    init(_ object: AudioPlayable) throws

    /// Play an `AudioPlayable` object.
    /// - parameter object: The object that should be played.
    mutating func play()

    /// Pause an `AudioPlayable` object.
    /// - parameter object: The object that should be paused.
    mutating func pause()

    /// Stop an `AudioPlayable` object.
    /// - parameter object: The object that should be stopped.
    mutating func stop()

    var audioDidFinishBlock: ((Bool) -> Void)? { get set }
}
