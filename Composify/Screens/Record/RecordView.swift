//
//  RecordView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 01/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

struct RecordView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject private var audioRecorder = AudioRecorder()
    @State private var isRecording = false

    var body: some View {
        VStack {
            Text(isRecording ? "Recording ..." : "Start recording")

            RecordButton(isRecording: $isRecording) {
                if isRecording {
                    let url = audioRecorder.stopRecording()
                    RecordingFactory.create(
                        title: Date().description,
                        url: url,
                        context: moc
                    )
                } else {
                    audioRecorder.startRecording()
                }

                isRecording.toggle()
            }
        }
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}
