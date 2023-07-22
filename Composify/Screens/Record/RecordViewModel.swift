//
//  RecordViewModel.swift
//  Composify
//
//  Created by Eirik Vale Aase on 19/06/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftData
import SwiftUI

@MainActor
@Observable
class RecordViewModel {
    var isRecording = false
    var showRecordingDeniedAlert = false
    var showProjectSheet = false

    private var onRecordTapTask: Task<Void, Never>?

    func openSettings() {
        if let settings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settings)
        }
    }

    func onRecordButtonTap(
        audioRecorder: AudioRecorder,
        workingProjectState: WorkingProjectState,
        modelContext: ModelContext
    ) {
        onRecordTapTask = Task {
            guard await audioRecorder.askForPermission() else {
                await MainActor.run {
                    self.showRecordingDeniedAlert.toggle()
                }
                return
            }

            await MainActor.run {
                if self.isRecording {
                    let id = audioRecorder.stopRecording()
                    let recording = Recording(
                        id: id,
                        title: "Recording \(Date().prettyDate)",
                        project: workingProjectState.workingProject
                    )
                    modelContext.insert(recording)
                    workingProjectState.workingProject?.recordings.append(recording)
                    do {
                        try modelContext.save()
                    } catch {
                        print("###", error.localizedDescription)
                    }
                } else {
                    audioRecorder.startRecording()
                }

                self.isRecording.toggle()
            }
        }
    }

    func onProjectSheetTap() {
        showProjectSheet.toggle()
    }

    func onAppear(workingProjectState: WorkingProjectState, modelContext: ModelContext) {
        workingProjectState.fetchWorkingProject(modelContext: modelContext)
    }
}
