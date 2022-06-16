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
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var workingProjectState: WorkingProjectState
    @ObservedObject private var audioRecorder = AudioRecorder()
    @ObservedObject private var viewModel = RecordViewModel()
    @State private var isRecording = false
    @State private var showProjectSheet = false
    @State private var showRecordingDeniedAlert = false

    @FetchRequest(sortDescriptors: [])
    var projects: FetchedResults<Project>

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color(UIColor(
                            red: 0.95,
                            green: 0.95,
                            blue: 0.97,
                            alpha: 1.00
                        )),
                        .red
                    ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer().frame(height: 20)

                Button(action: viewModel.onProjectSheetTap, label: {
                    if let workingProject = workingProjectState.workingProject {
                        VStack {
                            Text("Working project")
                                .font(.body)
                            HStack {
                                Text(workingProject.title ?? "")
                                    .font(.title)
                            }
                        }
                    } else {
                        VStack {
                            Text("No working project")
                                .font(.body)
                            HStack {
                                Text("Tap to select working project")
                                    .font(.title)
                            }
                        }
                    }
                })
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

                Image(systemName: "hand.tap")
                    .foregroundColor(.white)

                Spacer()

                Text(viewModel.isRecording ? "Recording ..." : "Start recording")
                    .foregroundColor(.white)
                    .font(.body)

                RecordButton(isRecording: $viewModel.isRecording) {
                    viewModel.onRecordButtonTap(
                        audioRecorder: audioRecorder,
                        workingProjectState: workingProjectState,
                        moc: moc
                    )
                }
                .shadow(radius: 1)

                Spacer()
            }
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
                    primaryButton: .default(Text("Settings"), action: viewModel.openSettings),
                    secondaryButton: .cancel()
                )
            })
            .onAppear {
                viewModel.onAppear(workingProjectState: workingProjectState, moc: moc)
            }
        }
    }

    var actionSheetButtons: [Alert.Button] {
        let projects = projects.map { project in
            Alert.Button.default(Text(project.title ?? "")) {
                workingProjectState.storeWorkingProject(project: project, moc: moc)
            }
        }

        let newProject = Alert.Button.default(Text("Create new project")) {
            let project = ProjectFactory.create(
                title: "Project \(Date().prettyDate)",
                context: PersistenceController.shared.container.viewContext
            )
            workingProjectState.storeWorkingProject(project: project, moc: moc)
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
    }
}
