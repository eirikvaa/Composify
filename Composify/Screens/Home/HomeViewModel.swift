//
//  HomeViewModel.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation

class HomeViewModel: ObservableObject, SongRepositoryInjectable {
    func createRecording(for url: URL) {
        let recording = Recording(
            title: url.lastPathComponent,
            url: url.absoluteString
        )

        let (_, currentSection) = songRepository.getCurrentProjectAndSection()

        if let currentSection = currentSection {
            songRepository.save(recording: recording, to: currentSection)
        }
    }
}
