//
//  AudioRecorderService.swift
//  Composify
//
//  Created by Eirik Vale Aase on 12.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

/// An AudioRecorderService can record audio.
protocol AudioRecorderService {
    /// Initialize the recorder with a URL to the place where the resulting audio should be saved.
    init(url: URL) throws

    /// Start recording audio.
    func record()

    /// Stop recording audio.
    func stop()

    /// Ask the user for permissions to use the microphone
    /// - returns: Whether access was granted or denied
    func askForMicrophonePermissions() -> Bool
}
