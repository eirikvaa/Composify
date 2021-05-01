//
//  LibrayView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import CoreData
import SwiftUI

struct LibraryView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(
        entity: Project.entity(),
        sortDescriptors: []
    ) var projects: FetchedResults<Project>

    var body: some View {
        List {
            ForEach(projects, id: \.id) { project in
                Text(project.title ?? "")
            }
            .onDelete(perform: { indexSet in
                removeProjects(at: indexSet)
            })
        }
        .navigationTitle("Library")
        .navigationBarItems(trailing: Button(action: {
            ProjectFactory.create(
                title: "Something New",
                persistenceController: PersistenceController.shared
            )
        }, label: {
            Image(systemName: "plus")
        }))
    }

    func removeProjects(at indexes: IndexSet) {
        for index in indexes {
            let project = projects[index]
            moc.delete(project)
        }

        try! moc.save()
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
