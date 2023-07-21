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
    @Attribute(.unique) var id = UUID()
    var createdAt = Date()
    var fileExtension = "caf"
    var index: Int?
    var title: String
    var url: URL
    var project: Project?

    init(title: String, index: Int? = 0, url: URL, project: Project?) {
        self.title = title
        self.fileExtension = fileExtension
        self.index = index
        self.url = url
        self.project = project
    }
}

extension Recording {
    var isFreestanding: Bool {
        project == nil
    }
}
