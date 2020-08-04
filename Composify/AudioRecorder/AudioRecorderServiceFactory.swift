//
//  AudioRecorderServiceFactory.swift
//  Composify
//
//  Created by Eirik Vale Aase on 12.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

final class AudioRecorderServiceFactory {
    static func defaultService(withURL url: URL) throws -> AudioRecorderService? {
        try? AVAudioRecorderService(url: url)
    }
}
