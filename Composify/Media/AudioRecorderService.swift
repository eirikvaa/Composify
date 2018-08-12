//
//  AudioRecorderService.swift
//  Composify
//
//  Created by Eirik Vale Aase on 12.08.2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

enum AudioRecorderServiceError {
    
}

protocol AudioRecorderService {
    init(url: URL) throws
    func record()
    func stop()
}
