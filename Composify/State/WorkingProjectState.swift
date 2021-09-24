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

    func fetchWorkingProject(moc: NSManagedObjectContext) {
        if let uuidString = UserDefaults.standard.object(forKey: "project.id") as? String,
           let uuid = UUID(uuidString: uuidString) {
            let fetchRequest = NSFetchRequest<Project>(entityName: "Project")
            fetchRequest.predicate = NSPredicate(format: "%K = %@", "id", uuid as CVarArg)

            do {
                self.workingProject = try moc.fetch(fetchRequest).first
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func storeWorkingProject(project: Project, moc: NSManagedObjectContext) {
        moc.insert(project)

        do {
            try moc.save()
            UserDefaults.standard.set(project.id?.description, forKey: "project.id")
        } catch {
            print(error.localizedDescription)
        }
    }

    func openSettings() {
        if let settings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settings)
        }
    }
}
