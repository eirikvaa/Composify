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
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Project.title, ascending: true)
        ]
    ) var projects: FetchedResults<Project>
    @FetchRequest(
        entity: Recording.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Recording.createdAt, ascending: true)
        ],
        predicate: NSPredicate(format: "project = nil")
    ) var recordings: FetchedResults<Recording>

    var body: some View {
        List {
            Section(header: Text("Projects")) {
                ForEach(projects, id: \.id) { project in
                    NavigationLink(destination: ProjectView(project: project)) {
                        Text(project.title ?? "")
                    }
                }
                .onDelete(perform: removeProjects)
            }
            Section(header: Text("Standalone recordings")) {
                ForEach(recordings, id: \.id) { recording in
                    Text(recording.title ?? "")
                        .onTapGesture {
                            audioPlayer.play(recording: recording)
                        }
                }
                .onDelete(perform: removeRecordings)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Library")
        .navigationBarItems(trailing: trailingButton)
    }

    private var trailingButton: some View {
        Button(action: {
            ProjectFactory.create(
                title: "Project \(Date().prettyDate)",
                context: PersistenceController.shared.container.viewContext
            )
        }, label: {
            Image(systemName: "plus")
        })
    }

    private func removeProjects(at indexes: IndexSet) {
        for index in indexes {
            let project = projects[index]
            moc.delete(project)
        }

        try! moc.save()
    }

    private func removeRecordings(at indexes: IndexSet) {
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

        Group {
            NavigationView {
                LibraryView()
                    .environment(\.managedObjectContext, context)
            }
            NavigationView {
                LibraryView()
            }
        }
    }
}
