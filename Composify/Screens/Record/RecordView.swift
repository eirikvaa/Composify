//
//  RecordView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

struct RecordView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject private var audioRecorder = AudioRecorder()
    @State private var isRecording = false
    @State private var workingProject: Project?
    @State private var showProjectSheet = false

    @FetchRequest(
        entity: Project.entity(),
        sortDescriptors: []
    ) var projects: FetchedResults<Project>

    private var actionSheetButtons: [Alert.Button] {
        let projects = projects.map { project in
            Alert.Button.default(Text(project.title ?? "")) {
                self.workingProject = project
            }
        }

        let reset = Alert.Button.destructive(Text("Reset working project")) {
            workingProject = nil
        }

        let cancel = Alert.Button.cancel()

        return projects + [reset, cancel]
    }

    var body: some View {
        VStack {
            Spacer().frame(height: 20)

            Button(action: {
                showProjectSheet.toggle()
            }, label: {
                if let workingProject = workingProject {
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
                if isRecording {
                    let url = audioRecorder.stopRecording()
                    RecordingFactory.create(
                        title: Date().description,
                        project: workingProject,
                        url: url,
                        context: moc
                    )
                } else {
                    audioRecorder.startRecording()
                }

                isRecording.toggle()
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
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}
