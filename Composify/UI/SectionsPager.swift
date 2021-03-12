//
//  SectionsPager.swift
//  Composify
//
//  Created by Eirik Vale Aase on 14/11/2020.
//  Copyright © 2020 Eirik Vale Aase. All rights reserved.
//

import SwiftUI
import SwiftUIPager

struct SectionsPager: View {
    @State private var page: Page = .first()
    private var items = Array(0..<5)
    private var recordings = Array(0..<5)
    private var sections = ["Intro", "Verse", "Solo", "Chorus", "Outro"]

    var body: some View {
        Pager(page: page, data: items, id: \.self) { index in
            VStack(alignment: .leading) {
                HStack {
                    Text(sections[index])
                        .font(.title)
                        .bold()
                        .padding()
                    Spacer()
                }
                ForEach(recordings, id: \.self) { index in
                    HStack {
                        Button(action: {
                            print("Play button was tapped.")
                        }, label: {
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding()
                                .foregroundColor(.red)
                        })
                        .buttonStyle(PlainButtonStyle())

                        Text("Recording \(index)")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                            .overlay(
                                RoundedRectangle(cornerRadius: 4.0)
                                    .stroke()
                            )
                }
                .padding(.horizontal)
                Spacer()
            }
        }
    }
}

struct SectionsPager_Previews: PreviewProvider {
    static var previews: some View {
        SectionsPager()
    }
}
