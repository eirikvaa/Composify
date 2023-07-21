//
//  PersistenceController.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation
import SwiftData

@MainActor
struct PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer = {
        let schema = Schema([Project.self, Recording.self])
        let configuration = ModelConfiguration(inMemory: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])

        (0..<3).forEach {
            let project = Project(
                title: "Project \($0)"
            )
            (0..<3).forEach {
                let recording = Recording(
                    title: "\(project.title) recording \($0)",
                    url: URL(fileURLWithPath: ""),
                    project: project
                )
                container.mainContext.insert(recording)
            }
        }
        return container
    }()
}
