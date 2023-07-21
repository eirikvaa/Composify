//
//  RecordView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftData
import SwiftUI

struct RecordView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var workingProjectState: WorkingProjectState
    @ObservedObject private var audioRecorder = AudioRecorder()
    @State private var viewModel = RecordViewModel()
    @State private var isRecording = false
    @State private var showProjectSheet = false
    @State private var showRecordingDeniedAlert = false

    @Query
    var projects: [Project]

    var body: some View {
        ZStack {
            Color.clear
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer().frame(height: 20)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Add new recordings to")
                            .font(.subheadline)
                        Group {
                            if let workingProject = workingProjectState.workingProject {
                                Text(workingProject.title)
                                    .font(.headline)
                            } else {
                                Text("Standalone recordings")
                                    .font(.headline)
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                RecordButton(isRecording: $viewModel.isRecording) {
                    viewModel.onRecordButtonTap(
                        audioRecorder: audioRecorder,
                        workingProjectState: workingProjectState,
                        modelContext: modelContext
                    )
                }
                .shadow(radius: 1)

                Spacer()

                Button(
                    action: {
                        viewModel.onProjectSheetTap()
                    },
                    label: {
                        Text("Set working project")
                            .foregroundColor(.red)
                            .font(.body)
                            .bold()
                    }
                )
            }
            .padding()
            .actionSheet(isPresented: $viewModel.showProjectSheet) {
                ActionSheet(
                    title: Text("Projects"),
                    message: Text("Select a project to record audio in"),
                    buttons: actionSheetButtons
                )
            }
            .alert(isPresented: $viewModel.showRecordingDeniedAlert, content: {
                let title = "Microphone usage denied"
                let message =
                    "Composify does not have access " +
                    "to your microphone. Please enable " +
                    "it in Settings to record audio."

                return Alert(
                    title: Text(title),
                    message: Text(message),
                    primaryButton: .default(Text("Settings"), action: {
                        viewModel.openSettings()
                    }),
                    secondaryButton: .cancel()
                )
            })
            .onAppear {
                viewModel.onAppear(workingProjectState: workingProjectState, modelContext: modelContext)
            }
        }
    }

    private var recordingText: String {
        let text: String
        if isRecording {
            text = "Recording …"
        } else if workingProjectState.workingProject != nil {
            text = "Create recording in working project"
        } else {
            text = "Create standalone recording"
        }
        return text
    }

    var actionSheetButtons: [Alert.Button] {
        let projects = projects.map { project in
            Alert.Button.default(Text(project.title)) {
                workingProjectState.storeWorkingProject(project: project, moc: modelContext)
            }
        }

        let newProject = Alert.Button.default(Text("Create new project")) {
            let project = Project(
                title: "Project \(Date().prettyDate)"
            )
            workingProjectState.storeWorkingProject(project: project, moc: modelContext)
        }

        let reset = Alert.Button.destructive(Text("Reset working project")) {
            workingProjectState.workingProject = nil
            UserDefaults.standard.set(nil, forKey: "project.id")
        }

        let cancel = Alert.Button.cancel()

        return projects + [newProject, reset, cancel]
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
            .environmentObject(WorkingProjectState())

        let context = PreviewData.shared.container
        RecordView()
            .modelContainer(context)
    }
}
