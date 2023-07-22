//
//  LibrayView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftData
import SwiftUI

struct LibraryView: View {
    @Environment(\.modelContext) var moc
    @EnvironmentObject var workingProjectState: WorkingProjectState
    @EnvironmentObject private var audioPlayer: AudioPlayer
    @State var viewModel = LibraryViewModel()

    @Query(sort: \.createdAt, order: .forward, animation: .default)
    var projects: [Project]

    @Query
    var recordings: [Recording]

    init() {
        var id: UUID?
        // The #Predicate macro is quite sensitive to what kind of code can be used.
        // It's important to not reference model objects, and not reference nil.
        // Ref: https://stackoverflow.com/a/76632341/5609988.
        _recordings = .init(filter: #Predicate { recording in
            recording.project?.id == id
        })
    }

    var body: some View {
        List {
            Section(header: Text("Projects")) {
                ForEach(projects, id: \.id) { project in
                    NavigationLink(value: project) {
                        HStack {
                            let isWorkingProject = workingProjectState.workingProject?.id == project.id
                            Circle()
                                .foregroundColor(isWorkingProject ? .green : .clear)
                                .frame(width: 10, height: 10)
                            Text(project.title)
                        }
                    }
                }
                .onDelete(perform: removeProjects)
                Button(action: {
                    viewModel.onProjectAddTap(modelContext: moc)
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
                            title: recording.title
                        ) {
                            viewModel.onRecordingTap(recording: recording, audioPlayer: audioPlayer)
                        }
                        .contextMenu {
                            ForEach(projects, id: \.id) { project in
                                Button(action: {
                                    viewModel.move(standaloneRecording: recording, to: project, moc: moc)
                                }, label: {
                                    Text(project.title)
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
        let context = PreviewData.shared.container

        Group {
            NavigationView {
                TabView {
                    LibraryView()
                        .modelContainer(context)
                        .environmentObject(WorkingProjectState())
                        .tabItem {
                            Label("Library", systemImage: "music.note.list")
                        }
                }
                .navigationTitle("Library")
            }
        }
    }
}
