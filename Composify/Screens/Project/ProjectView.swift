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
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject private var audioPlayer: AudioPlayer
    @FetchRequest(
        entity: Recording.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Recording.createdAt, ascending: true)
        ]
    ) private var recordings: FetchedResults<Recording>

    @State private var projectTitle = ""

    private let project: Project

    init(project: Project) {
        self.project = project
        self._projectTitle = .init(initialValue: project.title ?? "")
    }

    private var createdAt: String {
        project.createdAt?.prettyDate ?? ""
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
                ForEach(recordings.filter { $0.project == project }, id: \.id) { recording in
                    PlayableRowItem(
                        isPlaying: rowIsPlaying(recording: recording),
                        title: recording.title ?? ""
                    ) {
                        audioPlayer.play(recording: recording)
                    }
                }
                .onDelete(perform: removeRecordings)
            }
            Section(header: Text("Created At")) {
                Text(createdAt)
            }
            Section(header: Text("Danger Zone")) {
                // TODO:
                //   It is currently possible to crash the app if the delete a project
                //   when there are at least one recording. I'm not sure why yet. The
                //   crash is related to the number of rows in section 1, which is the
                //   recordings section. Specifically, there are wrong number of rows
                //   after deleting the project. Deleting projects will cascadingly delete
                //   all recordings attached to it, so will need to debug this further.
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    moc.delete(project)
                    try! moc.save()
                }, label: {
                    Text("Delete project")
                }).buttonStyle(DeleteButtonStyle())
            }
        }
        .toolbar {
            EditButton()
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(project.title ?? "")
        .onDisappear {
            try! moc.save()
        }
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
