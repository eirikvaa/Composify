//
//  LibraryViewModel.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16/06/2022.
//  Copyright © 2022 Eirik Vale Aase. All rights reserved.
//

import Foundation
import SwiftData

@MainActor
class LibraryViewModel {
    func onProjectAddTap(modelContext: ModelContext) {
        let project = Project(
            title: "Project \(Date().prettyDate)"
        )
        modelContext.insert(project)
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    func move(standaloneRecording recording: Recording, to project: Project, moc: ModelContext) {
        recording.project = project
        try! moc.save()
    }

    func onRecordingTap(recording: Recording, audioPlayer: AudioPlayer) {
        audioPlayer.play(recording: recording)
    }
}
