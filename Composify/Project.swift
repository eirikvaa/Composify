//
//  Project.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Project {
    @Attribute(.unique)
    var id = UUID()

    var createdAt = Date()
    var title: String

    @Relationship(.cascade, inverse: \Recording.project)
    var recordings: [Recording] = []

    init(title: String) {
        self.title = title
    }
}
