//
//  ProjectFactory.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import CoreData

struct ProjectFactory {
    @discardableResult
    static func create(title: String, context: NSManagedObjectContext) -> Project {
        let project = Project(context: context)
        project.id = UUID()
        project.createdAt = Date()
        project.title = title

        try! context.save()

        return project
    }
}
