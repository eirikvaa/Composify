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
    @State private var isShowingProjectDetails = false

    var body: some View {
        NavigationView {
            VStack {
                switch (songState.currentProject, songState.currentSection) {
                case let (project?, section?):
                    loadedView(project: project, section: section)
                case (let project?, nil):
                    noSectionsView(project: project)
                case (nil, _):
                    noProjectsView()
                }
            }
            .navigationTitle(Text("Composify"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            songState.refresh()
        }
    }

    private func noProjectsView() -> some View {
        Button(action: {
            isShowingProjectDetails = true
        }, label: {
            Text("Add project")
                .padding()
                .foregroundColor(.white)
        })
        .background(Color.gray)
        .cornerRadius(10.0)
        .sheet(isPresented: $isShowingProjectDetails) {
            projectDetailsView(project: Project())
        }
    }

    private func noSectionsView(project: Project) -> some View {
        Button(action: {
            isShowingProjectDetails = true
        }, label: {
            Text("Add section")
                .padding()
                .foregroundColor(.white)
        })
        .background(Color.gray)
        .cornerRadius(10.0)
        .sheet(isPresented: $isShowingProjectDetails) {
            projectDetailsView(project: project)
        }
    }

    private func loadedView(project: Project, section: Section) -> some View {
        ZStack {
            SectionsPager(sections: Array(project.sections.freeze()), currentSection: section)
            VStack {
                Spacer()
                RecordButton(isRecording: $audioRecorder.isRecording) {
                    if audioRecorder.isRecording {
                        let url = audioRecorder.stopRecording()
                        let recording = Recording(
                            title: url.lastPathComponent,
                            section: section,
                            url: url.absoluteString
                        )
                        viewModel.save(recording: recording)
                        songState.refresh()
                    } else {
                        audioRecorder.startRecording()
                    }
                }
                .background(Color.white)
                .clipShape(Circle())
                .padding(.bottom, 20)
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    isShowingProjectDetails = true
                }, label: {
                    Text("Edit Project")
                })
            }
        }
        .sheet(isPresented: $isShowingProjectDetails) {
            projectDetailsView(project: project)
        }
    }

    private func projectDetailsView(project: Project) -> some View {
        ProjectDetailsView(project: project) {
            songState.refresh()
        }
        .environmentObject(songState)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SongState())
    }
}
