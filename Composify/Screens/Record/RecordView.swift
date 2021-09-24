//
//  RecordView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import CoreData
import SwiftUI

struct RecordView: View {
    @EnvironmentObject var workingProjectState: WorkingProjectState
    @Environment(\.managedObjectContext) var moc
    @ObservedObject private var audioRecorder = AudioRecorder()
    @ObservedObject private var viewModel = RecordViewModel()
    @State private var isRecording = false
    @State private var showProjectSheet = false
    @State private var showRecordingDeniedAlert = false

    @FetchRequest(sortDescriptors: [])
    var projects: FetchedResults<Project>

    var body: some View {
        VStack {
            Spacer().frame(height: 20)

            Button(action: {
                showProjectSheet.toggle()
            }, label: {
                if let workingProject = workingProjectState.workingProject {
                    VStack {
                        Text("Working project")
                            .font(.caption)
                        HStack {
                            Text(workingProject.title ?? "")
                                .font(.headline)
                            Image(systemName: "hand.tap")
                        }
                    }
                } else {
                    VStack {
                        Text("No working project")
                            .font(.caption)
                        HStack {
                            Text("Tap to select working project")
                                .font(.headline)
                            Image(systemName: "hand.tap")
                        }
                    }
                }
            })
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Text(isRecording ? "Recording ..." : "Start recording")

            RecordButton(isRecording: $isRecording) {
                audioRecorder.askForPermission { granted in
                    guard granted else {
                        showRecordingDeniedAlert.toggle()
                        return
                    }

                    if isRecording {
                        let url = audioRecorder.stopRecording()
                        RecordingFactory.create(
                            title: "Recording \(Date().prettyDate)",
                            project: workingProjectState.workingProject,
                            url: url,
                            context: moc
                        )
                    } else {
                        DispatchQueue.main.async {
                            audioRecorder.startRecording()
                        }
                    }

                    DispatchQueue.main.async {
                        isRecording.toggle()
                    }
                }
            }

            Spacer()
        }
        .actionSheet(isPresented: $showProjectSheet) {
            ActionSheet(
                title: Text("Projects"),
                message: Text("Select a project to record audio in"),
                buttons: actionSheetButtons
            )
        }
        .alert(isPresented: $showRecordingDeniedAlert, content: {
            let title = "Microphone usage denied"
            let message =
                "Composify does not have access " +
                "to your microphone. Please enable " +
                "it in Settings to record audio."

            return Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: .default(Text("Settings"), action: viewModel.openSettings),
                secondaryButton: .cancel()
            )
        })
        .onAppear {
            workingProjectState.fetchWorkingProject(moc: moc)
        }
    }

    var actionSheetButtons: [Alert.Button] {
        let projects = projects.map { project in
            Alert.Button.default(Text(project.title ?? "")) {
                workingProjectState.workingProject = project
                UserDefaults.standard.set(project.id?.uuidString, forKey: "project.id")
            }
        }

        let newProject = Alert.Button.default(Text("Create new project")) {
            let project = ProjectFactory.create(
                title: "Project \(Date().prettyDate)",
                context: PersistenceController.shared.container.viewContext
            )
            workingProjectState.workingProject = project
            UserDefaults.standard.set(project.id?.uuidString, forKey: "project.id")
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
    }
}
