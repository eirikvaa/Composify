//
//  ComposifyApp.swift
//  Composify
//
//  Created by Eirik Vale Aase on 14/11/2020.
//  Copyright © 2020 Eirik Vale Aase. All rights reserved.
//

import SwiftData
import SwiftUI

@main
struct ComposifyApp: App {
    @Environment(\.scenePhase) var scenePhase

    private let audioPlayer = AudioPlayer()
    private let workingProjectState = WorkingProjectState()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(audioPlayer)
                .environmentObject(workingProjectState)
        }
        .modelContainer(for: [Project.self, Recording.self])
    }
}
