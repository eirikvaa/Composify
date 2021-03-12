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
    @StateObject private var page: Page = .first()
    private var items = Array(0..<5)
    private var recordings = Array(0..<Int.random(in: 0..<5))
    private var sections = ["Intro", "Verse", "Solo", "Chorus", "Outro"]

    var body: some View {
        Pager(page: page, data: items, id: \.self) { index in
            ScrollView {
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
                                    .frame(width: 30, height: 30)
                            })
                            .buttonStyle(PlainButtonStyle())

                            Text("Recording \(index)")
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
        .loopPages()
    }
}

struct SectionsPager_Previews: PreviewProvider {
    static var previews: some View {
        SectionsPager()
    }
}
