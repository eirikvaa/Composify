//
//  RecordingFactory.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation
import SwiftData

struct RecordingFactory {
    @discardableResult
    static func create(
        title: String,
        fileExtension: String = "caf",
        project: Project? = nil,
        url: URL,
        context: ModelContext
    ) -> Recording {
        let recording = Recording(
            title: title,
            url: url,
            project: project
        )

        try! context.save()

        return recording
    }
}
