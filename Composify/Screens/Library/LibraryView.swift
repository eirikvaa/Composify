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
    @ObservedObject private var audioPlayer = AudioPlayer()
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(
        entity: Project.entity(),
        sortDescriptors: []
    ) var projects: FetchedResults<Project>
    @FetchRequest(
        entity: Recording.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "project = nil")
    ) var recordings: FetchedResults<Recording>

    var body: some View {
        List {
            Section(header: Text("Projects")) {
                ForEach(projects, id: \.id) { project in
                    Text(project.title ?? "")
                }
                .onDelete(perform: { indexSet in
                    removeProjects(at: indexSet)
                })
            }
            Section(header: Text("Orphaned recordings")) {
                ForEach(recordings, id: \.id) { recording in
                    Text(recording.title ?? "")
                        .onTapGesture {
                            audioPlayer.play(recording: recording)
                        }
                }
                .onDelete(perform: { indexSet in
                    removeRecordings(at: indexSet)
                })
            }
        }
        .listStyle(InsetGroupedListStyle())
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

    func removeRecordings(at indexes: IndexSet) {
        for index in indexes {
            let recording = recordings[index]
            moc.delete(recording)
        }

        try! moc.save()
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        NavigationView {
            LibraryView()
                .environment(\.managedObjectContext, context)
        }
    }
}
