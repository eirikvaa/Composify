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
        audioRecorder.askForPermission { granted in
            guard granted else {
                self.showRecordingDeniedAlert.toggle()
                return
            }

            if self.isRecording {
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
