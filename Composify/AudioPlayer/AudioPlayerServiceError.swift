//
//  AudioPlayerServiceError.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

/// Errors for errors occurring before or during playing a playable object.
enum AudioPlayerServiceError: Error {
    /// The playable object was not found in the file system.
    case unableToFindPlayable
    case unableToConfigurePlayingSession
}
