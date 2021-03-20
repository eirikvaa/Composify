//
//  AddButton.swift
//  Composify
//
//  Created by Eirik Vale Aase on 20/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

struct AddButton: View {
    let title: String
    let tapAction: (() -> Void)

    var body: some View {
        Button(action: tapAction, label: {
            Text(title)
                .padding()
                .foregroundColor(.white)
        })
        .background(Color.gray)
        .cornerRadius(10.0)
    }
}

struct AddButton_Previews: PreviewProvider {
    static var previews: some View {
        AddButton(title: "Add project") {}
    }
}
