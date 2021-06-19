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
    @EnvironmentObject private var audioPlayer: AudioPlayer
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\Project.createdAt, order: .forward)
        ],
        animation: .default
    ) var projects: FetchedResults<Project>
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\Recording.createdAt, order: .forward)
        ],
        predicate: NSPredicate(format: "project = nil"),
        animation: .default
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
                Button(action: {
                    ProjectFactory.create(
                        title: "Project \(Date().prettyDate)",
                        context: PersistenceController.shared.container.viewContext
                    )
                }, label: {
                    HStack {
                        Image(systemName: "plus.circle").foregroundColor(.green)
                        Text("Create new project")
                    }
                })
                .buttonStyle(PlainButtonStyle())
            }

            if !recordings.isEmpty {
                Section(header: Text("Standalone recordings")) {
                    ForEach(recordings, id: \.id) { recording in
                        PlayableRowItem(
                            isPlaying: rowIsPlaying(recording: recording),
                            title: recording.title ?? "") {
                            audioPlayer.play(recording: recording)
                        }
                        .contextMenu {
                            ForEach(projects, id: \.id) { project in
                                Button(action: {
                                    recording.project = project
                                    try! moc.save()
                                }, label: {
                                    Text(project.title ?? "")
                                })
                            }
                        }
                    }
                    .onDelete(perform: removeRecordings)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Library")
        .navigationBarItems(trailing: EditButton())
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

    private func rowIsPlaying(recording: Recording) -> Binding<Bool> {
        Binding<Bool>(
            get: { audioPlayer.isPlaying && audioPlayer.recording == recording },
            set: { _ in }
        )
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
