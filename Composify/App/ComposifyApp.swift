//
//  ComposifyApp.swift
//  Composify
//
//  Created by Eirik Vale Aase on 14/11/2020.
//  Copyright © 2020 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

@main
struct ComposifyApp: App {
    @Environment(\.scenePhase) var scenePhase

    private let persistenceController = PersistenceController.shared
    private let audioPlayer = AudioPlayer()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(audioPlayer)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
