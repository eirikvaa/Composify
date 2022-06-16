//
//  WorkingProjectState.swift
//  Composify
//
//  Created by Eirik Vale Aase on 25/09/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import CoreData
import SwiftUI

final class WorkingProjectState: ObservableObject {
    @Published var workingProject: Project?

    private let userDefaults = UserDefaults.standard

    func fetchWorkingProject(moc: NSManagedObjectContext) {
        if let uuidString = userDefaults.object(forKey: "project.id") as? String,
           let uuid = UUID(uuidString: uuidString) {
            let fetchRequest = NSFetchRequest<Project>(entityName: "Project")
            fetchRequest.predicate = NSPredicate(format: "%K = %@", "id", uuid as CVarArg)

            do {
                workingProject = try moc.fetch(fetchRequest).first
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func storeWorkingProject(project: Project, moc: NSManagedObjectContext) {
        workingProject = project
        userDefaults.set(project.id?.description, forKey: "project.id")
    }

    func clearWorkingProject() {
        workingProject = nil
        userDefaults.set(nil, forKey: "project.id")
    }

    func openSettings() {
        if let settings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settings)
        }
    }
}
