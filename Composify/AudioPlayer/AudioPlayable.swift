//
//  AudioPlayable.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

/// An `AudioPlayable` object is something that can be played, and corresponds
/// to recordings.
protocol AudioPlayable: ComposifyObject {
    var url: URL { get }
    var duration: Float64 { get }
    var fileExtension: String { get set }
}
