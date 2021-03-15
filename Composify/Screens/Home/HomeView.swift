//
//  HomeView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 14/11/2020.
//  Copyright © 2020 Eirik Vale Aase. All rights reserved.
//

import SwiftUI
import SwiftUIPager

struct HomeView: View {
    @EnvironmentObject var songState: SongState
    @ObservedObject var viewModel = HomeViewModel()
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var isShowingNewProjectView = false
    @State private var isShowingEditProjectView = false
    @State private var currentSection = Section()

    var body: some View {
        NavigationView {
            VStack {
                switch (songState.currentProject, songState.currentSection) {
                case let (project?, .some):
                    loadedView(project: project)
                case (let project?, nil):
                    noSectionsView(project: project)
                case (nil, nil):
                    noProjectsView()
                case (nil, .some):
                    fatalError("Impossible ot have a section without a project.")
                }
            }
            .navigationBarTitle("Composify", displayMode: .inline)
        }
        .onAppear {
            songState.refresh()
        }
    }

    private func noProjectsView() -> some View {
        Button(action: {
            isShowingNewProjectView = true
        }, label: {
            Text("Add project")
                .padding()
                .foregroundColor(.white)
        })
        .background(Color.gray)
        .cornerRadius(10.0)
        .sheet(isPresented: $isShowingNewProjectView) {
            NewProjectView {
                songState.refresh()
            }
            .environmentObject(songState)
        }
    }

    private func noSectionsView(project: Project) -> some View {
        Button(action: {
            isShowingEditProjectView = true
        }, label: {
            Text("Add section")
                .padding()
                .foregroundColor(.white)
        })
        .background(Color.gray)
        .cornerRadius(10.0)
        .sheet(isPresented: $isShowingEditProjectView) {
            EditProjectView(project: project) { _ in
                viewModel.loadData()
            }
            .environmentObject(songState)
        }
    }

    private func loadedView(project: Project) -> some View {
        VStack {
            SectionsPager(sections: Array(project.sections), currentSection: $currentSection)
            Spacer()
            RecordButton(isRecording: $audioRecorder.isRecording) {
                if audioRecorder.isRecording {
                    let url = audioRecorder.stopRecording()
                    let recording = Recording(
                        title: url.lastPathComponent,
                        section: currentSection,
                        url: url.absoluteString
                    )
                    viewModel.save(recording: recording)
                } else {
                    audioRecorder.startRecording()
                }
            }
            .padding(.bottom, 20)
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    isShowingEditProjectView = true
                }, label: {
                    Text("Edit Project")
                })
            }
        }
        .sheet(isPresented: $isShowingEditProjectView) {
            EditProjectView(project: project) { _ in
                viewModel.loadData()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SongState())
    }
}
