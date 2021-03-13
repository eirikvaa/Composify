//
//  PagerPage.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation
import SwiftUI

struct RecordingsView: View {
    @StateObject private var audioPlayer = AudioPlayer()
    var recordings: [Recording]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(recordings, id: \.self) { recording in
                    HStack {
                        Button(action: {
                            audioPlayer.play(recording: recording)
                        }, label: {
                            if audioPlayer.recording == recording {
                                Image(systemName: audioPlayer.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                            } else {
                                Image(systemName: "play.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                            }
                        })
                        .buttonStyle(PlainButtonStyle())

                        Text(recording.title)
                            .foregroundColor(.white)
                            .font(.body)

                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.7))
                    .cornerRadius(10.0)
                }
                .padding(.horizontal)
            }
        }
    }
}
