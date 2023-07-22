//
//  ProjectView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftData
import SwiftUI

struct ProjectView: View {
    @EnvironmentObject var workingProjectState: WorkingProjectState
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var audioPlayer: AudioPlayer
    @Query
    private var recordings: [Recording]

    @State private var projectTitle = ""

    private let project: Project

    init(project: Project) {
        self.project = project
        self._projectTitle = .init(initialValue: project.title)

        // The #Predicate macro returns an error when referencing a model object inside the closure.
        // Ref: https://stackoverflow.com/a/76632341/5609988.
        let id = project.id

        self._recordings = .init(
            filter: #Predicate { recording in
                recording.project?.id == id
            },
            sort: \.createdAt,
            order: .forward
        )
    }

    private var createdAt: String {
        project.createdAt.prettyDate
    }

    var body: some View {
        List {
            Section(header: Text("Title")) {
                TextField("Project title", text: $projectTitle)
            }
            Section(header: Text("Recordings")) {
                ForEach(recordings, id: \.id) { recording in
                    PlayableRowItem(
                        isPlaying: rowIsPlaying(recording: recording),
                        title: recording.title
                    ) {
                        audioPlayer.play(recording: recording)
                    }
                    .contextMenu {
                        Button(action: {
                            recording.project = nil
                            try! modelContext.save()
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
            Section(header: Text("Working project")) {
                Button(action: {
                    if workingProjectState.workingProject == project {
                        workingProjectState.clearWorkingProject()
                    } else {
                        workingProjectState.storeWorkingProject(project: project, moc: modelContext)
                    }
                }, label: {
                    if workingProjectState.workingProject == project {
                        Text("Clear working project")
                    } else {
                        Text("Set as working project")
                    }
                })
            }
        }
        .toolbar {
            EditButton()
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(project.title)
        .onDisappear {
            project.title = projectTitle
            try! modelContext.save()
        }
    }

    private func removeRecordings(at indexes: IndexSet) {
        for index in indexes {
            let recording = recordings[index]
            modelContext.delete(recording)
        }

        try! modelContext.save()
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
        let project = Project(title: "Project 1")

        Group {
            NavigationView {
                ProjectView(project: project)
            }

            NavigationView {
                ProjectView(project: project)
            }
            .previewInterfaceOrientation(.landscapeLeft)
        }
        .environmentObject(WorkingProjectState())
    }
}

extension Notification.Name {
    static var didSelectDeleteItem: Notification.Name {
        Notification.Name("Delete Item")
    }
}
