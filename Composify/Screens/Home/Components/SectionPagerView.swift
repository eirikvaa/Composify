//
//  PagerPage.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import Foundation
import SwiftUI

struct SectionPagerView: View {
    var section: Section
    var recordings: [Recording]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(recordings, id: \.self) { recording in
                    HStack {
                        Button(action: {
                            print("Play button was tapped.")
                        }, label: {
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
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
