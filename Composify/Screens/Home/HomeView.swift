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
    @StateObject private var viewModel = HomeViewModel()
    @State private var isShowingNewProjectView = false
    @State private var isShowingEditProjectView = false
    @State private var isRecording = false

    var body: some View {
        NavigationView {
            VStack {
                switch viewModel.state {
                case let .loaded(project, sections):
                    VStack {
                        SectionsPager(sections: sections)
                        Spacer()
                        RecordButton(isRecording: $isRecording) {
                            print("Add recording to \(project.title)")
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
                        EditProjectView(project: Binding<Project>(
                                            get: { project },
                                            set: { _ in })
                        ) { _ in
                            viewModel.loadData()
                        }
                    }
                case .noSections(let project):
                    Button(action: {
                        isShowingEditProjectView = true
                    }, label: {
                        Text("Edit \(project.title)")
                    })
                        .sheet(isPresented: $isShowingEditProjectView) {
                            EditProjectView(project: Binding<Project>(
                                                get: { project },
                                                set: { _ in })
                            ) { _ in
                                viewModel.loadData()
                            }
                        }
                case .noProjects:
                    Button(action: {
                        isShowingNewProjectView = true
                    }, label: {
                        Text("Add project")
                    })
                    .sheet(isPresented: $isShowingNewProjectView) {
                        NewProjectView()
                    }
                }
            }
            .navigationBarTitle("Composify", displayMode: .inline)
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
