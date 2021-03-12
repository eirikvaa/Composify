//
//  ComposifyObject.swift
//  Composify
//
//  Created by Eirik Vale Aase on 22/12/2018.
//  Copyright © 2018 Eirik Vale Aase. All rights reserved.
//

import Foundation

/**
 The `ComposifyObject` protocol gives information about where
 a `FileSystemComposifyObject` instance is in the file system.
 - Author: Eirik Vale Aase
 */
protocol ComposifyObject {
    var id: String { get }
    var title: String { get }
    var dateCreated: Date { get }
}
