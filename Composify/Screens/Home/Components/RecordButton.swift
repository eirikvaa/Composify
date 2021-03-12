//
//  RecordButton.swift
//  Composify
//
//  Created by Eirik Vale Aase on 13/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

struct RecordButton: View {
    var body: some View {
        Button(action: {
            print("Hei")
        }, label: {
            Text("Record")
                .padding()
                .foregroundColor(.white)
        })
        .frame(width: 200)
        .background(Color.red)
        .cornerRadius(4.0)
    }
}

struct RecordButton_Previews: PreviewProvider {
    static var previews: some View {
        RecordButton()
    }
}
