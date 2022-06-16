//
//  RecordViewModel.swift
//  Composify
//
//  Created by Eirik Vale Aase on 19/06/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import CoreData
import SwiftUI

class RecordViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var showRecordingDeniedAlert = false
    @Published var showProjectSheet = false

    private var onRecordTapTask: Task<Void, Never>?

    func openSettings() {
        if let settings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settings)
        }
    }

    func onRecordButtonTap(
        audioRecorder: AudioRecorder,
        workingProjectState: WorkingProjectState,
        moc: NSManagedObjectContext
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
                    let url = audioRecorder.stopRecording()
                    RecordingFactory.create(
                        title: "Recording \(Date().prettyDate)",
                        project: workingProjectState.workingProject,
                        url: url,
                        context: moc
                    )
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

    func onAppear(workingProjectState: WorkingProjectState, moc: NSManagedObjectContext) {
        workingProjectState.fetchWorkingProject(moc: moc)
    }
}
