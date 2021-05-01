//
//  RecordingFactory.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import CoreData
import Foundation

struct RecordingFactory {
    @discardableResult
    static func create(
        title: String,
        fileExtension: String = "caf",
        project: Project? = nil,
        url: URL,
        context: NSManagedObjectContext
    ) -> Recording {
        let recording = Recording(context: context)
        recording.id = UUID()
        recording.createdAt = Date()
        recording.title = title
        recording.fileExtension = "m4a"
        recording.project = project
        recording.url = url

        try! context.save()

        return recording
    }
}
