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
                    .contextMenu {
                        Button(action: {
                            recording.project = nil
                            try! moc.save()
                        }, label: {
                            Text("Remove recording from project")
                        })
                    }
                }
                .onDelete(perform: removeRecordings)
            }
            Section(header: Text("Created At")) {
                Text(createdAt)
            }
            Section(header: Text("Danger Zone")) {
                Button(action: {
                    // If we try to delete a project that has recordings while still in the view,
                    // we will get a 'NSInternalInconsistencyException' crash, saying that the number
                    // of rows in section 1 is invalid. For some reason we're not able to update
                    // the underlying data backing. Therefore we just post a notification saying
                    // that we should delete the project, and then handle it in the `onReceive`
                    // method in this view. There we dismiss the view, wait a short moment and
                    // then delete the project. This is a hack and I hope there is a more elegant
                    // way of doing it.
                    NotificationCenter.default.post(name: .didSelectDeleteItem, object: nil)
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
        .onReceive(NotificationCenter.default.publisher(for: .didSelectDeleteItem), perform: { _ in
            self.presentationMode.wrappedValue.dismiss()

            // TODO: Try to find a time interval that works for all phones.
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                moc.delete(project)
                try! moc.save()
            }
        })
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

extension Notification.Name {
    static var didSelectDeleteItem: Notification.Name {
        Notification.Name("Delete Item")
    }
}
