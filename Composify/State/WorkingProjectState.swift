//
//  WorkingProjectState.swift
//  Composify
//
//  Created by Eirik Vale Aase on 25/09/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftData
import SwiftUI

final class WorkingProjectState: ObservableObject {
    @Published var workingProject: Project?

    init(workingProject: Project? = nil) {
        self.workingProject = workingProject
    }

    private let userDefaults = UserDefaults.standard

    func fetchWorkingProject(modelContext: ModelContext) {
        let projectId = userDefaults.object(forKey: "project.id") as? String
        if let uuidString = projectId, let uuid = UUID(uuidString: uuidString) {
            do {
                workingProject = try modelContext.fetch(.init(predicate: #Predicate { (project: Project) in
                    project.id == uuid
                })).first
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func storeWorkingProject(project: Project, moc: ModelContext) {
        workingProject = project
        userDefaults.set(project.id.description, forKey: "project.id")
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
