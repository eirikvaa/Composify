//
//  EmptyRecordingsView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

struct EmptyRecordingsView: View {
    var body: some View {
        VStack {
            Text("«Music expresses that which cannot be put into words and that which cannot remain silent»")
                .frame(maxWidth: 300)
                .multilineTextAlignment(.center)
                .font(.headline)
                .foregroundColor(.gray)
                .padding()
            Text("- Victor Hugo")
                .frame(maxWidth: 300, alignment: .trailing)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct EmptyRecordingsView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyRecordingsView()
    }
}
