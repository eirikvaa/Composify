//
//  OrphanedRecordingsView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import CoreData
import SwiftUI

struct OrphanedRecordingsView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject private var audioPlayer = AudioPlayer()
    @FetchRequest(
        entity: Recording.entity(),
        sortDescriptors: []
    ) var recordings: FetchedResults<Recording>

    var body: some View {
        List {
            ForEach(recordings, id: \.id) { recording in
                Text(recording.title ?? "")
                    .onTapGesture {
                        audioPlayer.play(recording: recording)
                    }
            }
            .onDelete(perform: { indexSet in
                removeRecordings(at: indexSet)
            })
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Orphaned recordings")
    }

    func removeRecordings(at indexes: IndexSet) {
        for index in indexes {
            let recording = recordings[index]
            moc.delete(recording)
        }

        try! moc.save()
    }
}

struct OrphanedRecordingsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        NavigationView {
            OrphanedRecordingsView()
                .environment(\.managedObjectContext, context)
        }
    }
}
