//
//  AudioPlayerService.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

/// Errors for errors occurring before or during playing a playable object.
enum AudioPlayerServiceError: Error {
    /// The playable object was not found in the file system.
    case unableToFindPlayable
    case unableToConfigurePlayingSession
}

/// An `AudioPlayable` object is something that can be played, and corresponds
/// to recordings.
protocol AudioPlayable {
    var id: String { get }
    var title: String { get set }
    var url: URL { get }
    var dateRecorded: Date { get }
    var fileExtension: String { get set }
}

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
