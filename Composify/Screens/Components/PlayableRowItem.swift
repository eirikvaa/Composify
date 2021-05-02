//
//  PlayableRowItem.swift
//  Composify
//
//  Created by Eirik Vale Aase on 02/05/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

struct PlayableRowItem: View {
    @Binding var isPlaying: Bool

    let title: String
    let tapAction: () -> Void

    private var leadingImage: Image {
        isPlaying ?
            Image(systemName: "pause.circle.fill") :
            Image(systemName: "play.circle.fill")
    }

    var body: some View {
        Button(action: {
            tapAction()
        }, label: {
            HStack {
                leadingImage
                Text(title)
            }
        })
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlayableRowItem_Previews: PreviewProvider {
    static var previews: some View {
        PlayableRowItem(
            isPlaying: .constant(true),
            title: "Recording #1"
        ) {}
    }
}
