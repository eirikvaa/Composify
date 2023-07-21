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
    @Query(sort: \.createdAt, order: .forward)
    private var recordings: [Recording]

    @State private var projectTitle = ""

    private let project: Project

    init(project: Project) {
        self.project = project
        self._projectTitle = .init(initialValue: project.title)
    }

    private var createdAt: String {
        project.createdAt.prettyDate
    }

    var body: some View {
        List {
            Section(header: Text("Title")) {
                TextField("Project title", text: $projectTitle) { _ in
                    project.title = projectTitle
                } onCommit: {
                    try! modelContext.save()
                }
            }
            Section(header: Text("Recordings")) {
                ForEach(recordings.filter { $0.project == project }, id: \.id) { recording in
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
            Section(header: Text("Danger Zone")) {
                Button(action: {
                    audioPlayer.stopPlaying()
                    presentationMode.wrappedValue.dismiss()
                    modelContext.delete(project)
                    try! modelContext.save()
                }, label: {
                    Text("Delete project")
                })
            }
        }
        .toolbar {
            EditButton()
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(project.title)
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
