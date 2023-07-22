//
//  Recording.swift
//  Composify
//
//  Created by Eirik Vale Aase on 10.08.2016.
//  Copyright © 2016 Eirik Vale Aase. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Recording {
    @Attribute(.unique)
    var id: UUID
    var createdAt: Date
    var index: Int?
    var title: String
    var project: Project?

    init(id: UUID, title: String, index: Int? = 0, project: Project?) {
        self.id = id
        self.createdAt = Date()
        self.title = title
        self.index = index
        self.project = project
    }
}

extension Recording {
    @Transient
    var isFreestanding: Bool {
        project == nil
    }

    @Transient
    var url: URL {
        URL.documentsDirectory
            .appendingPathComponent(id.uuidString)
            .appendingPathExtension("m4a")
    }
}
