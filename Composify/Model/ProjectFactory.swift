//
//  ProjectFactory.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftData

struct ProjectFactory {
    @discardableResult
    static func create(title: String, modelContext: ModelContext) -> Project {
        let project = Project(title: title)
        project.title = title

        modelContext.insert(project)
        try! modelContext.save()

        return project
    }
}
