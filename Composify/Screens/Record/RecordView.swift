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
    @ObservedObject private var audioRecorder = AudioRecorder()
    @State private var isRecording = false
    @State private var workingProject: Project?
    @State private var showProjectSheet = false
    @State private var showRecordingDeniedAlert = false

    @FetchRequest(
        entity: Project.entity(),
        sortDescriptors: []
    ) var projects: FetchedResults<Project>

    private var actionSheetButtons: [Alert.Button] {
        let projects = projects.map { project in
            Alert.Button.default(Text(project.title ?? "")) {
                self.workingProject = project
                UserDefaults.standard.set(project.id?.uuidString, forKey: "project.id")
            }
        }

        let newProject = Alert.Button.default(Text("Create new project")) {
            let project = ProjectFactory.create(
                title: "Project \(Date().prettyDate)",
                context: PersistenceController.shared.container.viewContext
            )
            workingProject = project
            UserDefaults.standard.set(project.id?.uuidString, forKey: "project.id")
        }

        let reset = Alert.Button.destructive(Text("Reset working project")) {
            workingProject = nil
            UserDefaults.standard.set(nil, forKey: "project.id")
        }

        let cancel = Alert.Button.cancel()

        return projects + [newProject, reset, cancel]
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
                guard audioRecorder.canRecord else {
                    showRecordingDeniedAlert.toggle()
                    return
                }

                if isRecording {
                    let url = audioRecorder.stopRecording()
                    RecordingFactory.create(
                        title: "Recording \(Date().prettyDate)",
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
        .alert(isPresented: $showRecordingDeniedAlert, content: {
            let title = "Microphone usage denied"
            let message =
                "Composify does not have access " +
                "to your microphone. Please enable " +
                "it in Settings to record audio."

            return Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: Alert.Button.default(Text("Settings"), action: {
                    if let settings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settings)
                    }
                }),
                secondaryButton: Alert.Button.cancel()
            )
        })
        .onAppear {
            if let uuidString = UserDefaults.standard.object(forKey: "project.id") as? String,
               let uuid = UUID(uuidString: uuidString) {
                let fetchRequest = NSFetchRequest<Project>(entityName: "Project")
                fetchRequest.predicate = NSPredicate(format: "%K = %@", "id", uuid as CVarArg)

                do {
                    self.workingProject = try moc.fetch(fetchRequest).first
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}
