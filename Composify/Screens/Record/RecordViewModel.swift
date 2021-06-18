//
//  RecordViewModel.swift
//  Composify
//
//  Created by Eirik Vale Aase on 19/06/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import CoreData
import SwiftUI

class RecordViewModel: ObservableObject {
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

    func openSettings() {
        if let settings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settings)
        }
    }
}
