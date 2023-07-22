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
    var fileExtension = "caf"
    var index: Int?
    var title: String
    var project: Project?

    init(id: UUID, title: String, index: Int? = 0, project: Project?) {
        self.id = id
        self.createdAt = Date()
        self.title = title
        self.fileExtension = fileExtension
        self.index = index
        self.project = project
    }
}

extension Recording {
    var isFreestanding: Bool {
        project == nil
    }

    var url: URL {
        URL.documentsDirectory
            .appendingPathComponent(id.uuidString)
            .appendingPathExtension("m4a")
    }
}
