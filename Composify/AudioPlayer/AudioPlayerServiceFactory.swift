//
//  AudioPlayerServiceFactory.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

class AudioPlayerServiceFactory {
    static func defaultService(withObject object: AudioPlayable) throws -> AudioPlayerService? {
        return try AVAudioPlayerService(object)
    }
}
