//
//  DeleteProjectButton.swift
//  Composify
//
//  Created by Eirik Vale Aase on 19/03/2021.
//  Copyright © 2021 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

struct DeleteProjectButton: View {
    var deleteAction: () -> Void

    var body: some View {
        Text("Delete project")
            .bold()
            .frame(maxWidth: .infinity)
            .foregroundColor(.red)
            .onTapGesture(perform: deleteAction)
    }
}

struct DeleteProjectButton_Previews: PreviewProvider {
    static var previews: some View {
        DeleteProjectButton(deleteAction: {})
    }
}
