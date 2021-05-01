//
//  ProjectFactory.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import CoreData

struct ProjectFactory {
    static func create(title: String, persistenceController: PersistenceController) {
        let project = Project(context: persistenceController.container.viewContext)
        project.id = UUID()
        project.createdAt = Date()
        project.title = title

        persistenceController.save()
    }
}
