//
//  LibraryViewModel.swift
//  Composify
//
//  Created by Eirik Vale Aase on 16/06/2022.
//  Copyright © 2022 Eirik Vale Aase. All rights reserved.
//

import CoreData
import Foundation

class LibraryViewModel: ObservableObject {
    func onProjectAddTap() {
        ProjectFactory.create(
            title: "Project \(Date().prettyDate)",
            context: PersistenceController.shared.container.viewContext
        )
    }

    func move(standaloneRecording recording: Recording, to project: Project, moc: NSManagedObjectContext) {
        recording.project = project
        try! moc.save()
    }

    func onRecordingTap(recording: Recording, audioPlayer: AudioPlayer) {
        audioPlayer.play(recording: recording)
    }
}
