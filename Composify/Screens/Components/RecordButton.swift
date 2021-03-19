//
//  RecordButton.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

struct RecordButton: View {
    @Binding var isRecording: Bool

    let tapAction: (() -> Void)

    var body: some View {
        Button(action: {
            tapAction()
        }, label: {
            if isRecording {
                Image(systemName: "stop.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.red)
            } else {
                Image(systemName: "record.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.red)
            }
        })
        .clipShape(Circle())
    }
}

struct RecordButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RecordButton(isRecording: .constant(false)) {
                print("Start recording!")
            }
            RecordButton(isRecording: .constant(true)) {
                print("Start recording!")
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
