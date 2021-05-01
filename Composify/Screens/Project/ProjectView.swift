//
//  ProjectView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import CoreData
import SwiftUI

struct ProjectView: View {
    @Environment(\.managedObjectContext) var moc
    @State private var projectTitle: String

    let project: Project

    init(project: Project) {
        self.project = project
        self.projectTitle = project.title ?? ""
    }

    private var recordings: [Recording] {
        Array(project.recordings?.array ?? []) as? [Recording] ?? []
    }

    var body: some View {
        List {
            Section(header: Text("Title")) {
                TextField("Project title", text: $projectTitle) { _ in
                    project.title = projectTitle
                } onCommit: {
                    try! moc.save()
                }
            }
            Section(header: Text("Recordings")) {
                ForEach(recordings, id: \.index) { recording in
                    Text(recording.title ?? "")
                }
                .onDelete(perform: removeRecordings)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(project.title ?? "")
        .onDisappear {
            try! moc.save()
        }
    }

    func removeRecordings(at indexes: IndexSet) {
        for index in indexes {
            let recording = recordings[index]
            moc.delete(recording)
        }

        try! moc.save()
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        let controller = PersistenceController.preview
        let project = controller
            .container
            .viewContext
            .registeredObjects
            .first(where: { $0 is Project }) as! Project

        NavigationView {
            ProjectView(project: project)
        }
    }
}
